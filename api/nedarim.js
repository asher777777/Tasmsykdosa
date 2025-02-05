import express from 'express';
import fetch from 'node-fetch';

const router = express.Router();

// Nedarim Plus iframe endpoint
router.post('/api/nedarim', async (req, res) => {
  console.log('Received Nedarim iframe request:', req.body);

  try {
    // Handle iframe initialization
    if (req.body.type === 'init') {
      return res.json({ success: true, height: 600 });
    }

    const nedarimResponse = await fetch('https://matara.pro/nedarimplus/iframe/', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache'
      },
      body: new URLSearchParams(req.body).toString()
    });

    if (!nedarimResponse.ok) {
      throw new Error(`Nedarim API responded with status: ${nedarimResponse.status}`);
    }

    const responseText = await nedarimResponse.text();
    console.log('Nedarim raw response:', responseText);

    try {
      const data = JSON.parse(responseText);
      res.json(data);
    } catch (parseError) {
      console.error('Error parsing Nedarim response:', parseError);
      res.json({ 
        success: false, 
        error: 'Invalid response from Nedarim',
        rawResponse: responseText 
      });
    }
  } catch (error) {
    console.error('Error in Nedarim iframe proxy:', error);
    res.status(500).json({ 
      error: 'Error communicating with Nedarim Plus',
      details: error.message 
    });
  }
});

// Nedarim Plus management API endpoint
router.post('/proxy/nedarim', async (req, res) => {
  console.log('Received Nedarim management request:', req.body);

  try {
    const response = await fetch('https://matara.pro/nedarimplus/Reports/Manage3.aspx', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache'
      },
      body: JSON.stringify(req.body)
    });

    if (!response.ok) {
      throw new Error(`Nedarim management API responded with status: ${response.status}`);
    }

    const data = await response.json();
    console.log('Received Nedarim management response:', data);
    return res.json(data);
  } catch (error) {
    console.error('Error in Nedarim management proxy:', error);
    return res.status(500).json({ 
      error: 'Internal Server Error',
      details: error.message 
    });
  }
});

export default router;
