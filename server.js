import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import ezcountRouter from './api/ezcount.js';
import nedarimRouter from './api/nedarim.js';

// Load environment variables
dotenv.config();

// Initialize express
const app = express();

// Use environment port or default to 5000
const PORT = process.env.PORT || 5000;

// Configure CORS with all needed origins
const allowedOrigins = [

 'https://www.matara.pro',
  'https://tasmsykdosa.vercel.app'
];

app.use(cors({
  origin: function(origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.indexOf(origin) === -1) {
      const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
      return callback(new Error(msg), false);
    }
    return callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'OPTIONS', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Parse JSON payloads
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes
app.use('/api', ezcountRouter);
app.use('/api', nedarimRouter);

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error('Error occurred:', err);
  console.error('Stack trace:', err.stack);
  
  // Don't leak error details in production
  const response = {
    error: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : err.message,
    status: err.status || 500,
    timestamp: new Date().toISOString()
  };

  if (process.env.NODE_ENV !== 'production') {
    response.stack = err.stack;
  }

  res.status(response.status).json(response);
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.url}`,
    timestamp: new Date().toISOString()
  });
});

// Start server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log('\nAvailable endpoints:');
    console.log('📍 POST /api/nedarim    (Nedarim Plus iframe integration)');
    console.log('📍 POST /proxy/nedarim  (Nedarim Plus management API)');
    console.log('📍 POST /api/ezcount    (EZCount integration)');
    console.log('📍 GET  /api/health     (Server health check)');
    console.log('\nCORS enabled for:', allowedOrigins);
  });
}

export default app;
