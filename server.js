import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import ezcountRouter from './api/ezcount.js';
import nedarimRouter from './api/nedarim.js';

dotenv.config();

const app = express();
const PORT = 5000;

// Configure CORS with all needed origins
app.use(cors({
  origin: [
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    'http://localhost:5174',
    'http://192.168.137.1:5173',
    'https://www.matara.pro',
    'https://tasmsykdosa.vercel.app' // Add the new origin here
  ],
  credentials: true
}));

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Use the new routers
app.use('/api', ezcountRouter);
app.use('/api', nedarimRouter);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ 
    error: 'Internal Server Error',
    details: err.message 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('Available endpoints:');
  console.log('- POST /api/nedarim (Nedarim Plus iframe integration)');
  console.log('- POST /proxy/nedarim (Nedarim Plus management API)');
  console.log('- POST /api/ezcount (EZCount integration)');
  console.log('- GET /api/health (Server health check)');
});
