import express from 'express';
import fetch from 'node-fetch';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();

// EZCount API endpoint
router.post('/ezcount', async (req, res) => {
  const requestBody = req.body;
  console.log('Received request:', requestBody);

  const apiUrl = process.env.VITE_EZY_API_URL;
  if (!apiUrl) {
    return res.status(500).json({ error: 'EZCount API URL is not defined' });
  }

  try {
    const ezcountResponse = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    });

    if (!ezcountResponse.ok) {
      const errorText = await ezcountResponse.text();
      console.error(`EZCount API responded with status: ${ezcountResponse.status}, body: ${errorText}`);
      throw new Error(`EZCount API responded with status: ${ezcountResponse.status}, body: ${errorText}`);
    }

    const data = await ezcountResponse.json();
    console.log('Received EZCount response:', data);
    res.json(data);
  } catch (error) {
    console.error('Error in EZCount API proxy:', error);
    res.status(500).json({ 
      error: 'Error communicating with EZCount API',
      details: error.message 
    });
  }
});

export default router;
