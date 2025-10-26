const axios = require('axios');

// The URL where your Python ML service is running
const ML_SERVICE_URL = 'http://localhost:5001';

const reportController = {
  /**
   * New function to handle the Scan-to-Speak workflow. 🗣️
   * It receives an image, forwards it to the Python service for processing,
   * and sends the resulting audio file back to the app.
   */
  handleScanAndSpeak: async (req, res) => {
    const { image } = req.body;
    if (!image) {
      return res.status(400).send({ message: 'No image data provided.' });
    }
    try {
      console.log('[Node Server] Received scan-and-speak request. Forwarding to Python...');
      // Call the new '/scan-and-speak' endpoint on the Python service
      const mlResponse = await axios.post(`${ML_SERVICE_URL}/scan-and-speak`, { image });
      
      // Forward the audio response from Python back to the Flutter app
      res.status(200).send({ audio: mlResponse.data.audio });
    } catch (error) {
      console.error('[Node Server] Error in scan-and-speak workflow:', error.message);
      res.status(500).send({ message: 'Failed to process scan-and-speak request.' });
    }
  },

  /**
   * Updated function for the general chatbot, which now handles voice.
   */
  handleChatbotQuery: async (req, res) => {
    const { query, role, audio } = req.body;
    if (!query && !audio) {
      return res.status(400).send({ message: 'Missing query or audio in request.' });
    }
    try {
      console.log(`[Node Server] Received chatbot request. Forwarding to Python...`);
      // Forward the entire request body to the Python service
      const mlResponse = await axios.post(`${ML_SERVICE_URL}/chat`, req.body);
      
      // Forward the text and audio response back to the Flutter app
      res.status(200).send(mlResponse.data);
    } catch (error) {
      console.error('[Node Server] Error calling Python chatbot service:', error.message);
      res.status(500).send({ message: 'Failed to get chatbot response.' });
    }
  },

  /**
   * Placeholder for analytics logic.
   */
  getAnalytics: async (req, res) => {
    res.status(501).send({ message: 'Analytics feature not implemented yet.'});
  }
};

module.exports = reportController;