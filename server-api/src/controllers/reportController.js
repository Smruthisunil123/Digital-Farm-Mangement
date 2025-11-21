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
      const mlResponse = await axios.post(`${ML_SERVICE_URL}/chat`, req.body);
      
      // ✅ FIX: Ensure keys match exactly what Flutter is looking for
      res.status(200).send({
        text_response: mlResponse.data.text_response,
        audio_response: mlResponse.data.audio_response
      });

    } catch (error) {
      console.error('[Node Server] Chatbot Error:', error.message);
      res.status(500).send({ message: 'Failed to get chatbot response.' });
    }
  },

  /**
   * ✅ NEW FUNCTION: Bridge to Python for Withdrawal Calculation
   */
  calculateWithdrawal: async (req, res) => {
    const { medications } = req.body; // Expects array of strings ["Med1", "Med2"]
    
    if (!medications || !Array.isArray(medications)) {
        return res.status(400).send({ message: 'Invalid medications list.' });
    }

    try {
        console.log('[Node Server] Asking Python AI for withdrawal period...');
        // Call the Python endpoint
        const mlResponse = await axios.post(`${ML_SERVICE_URL}/calculate-withdrawal`, { 
            medications 
        });
        // Send result back to Flutter
        res.status(200).send(mlResponse.data);
    } catch (error) {
        console.error('[Node Server] Error calculating withdrawal:', error.message);
        // Fail gracefully -> 0 days
        res.status(200).send({ withdrawal_days: 0 }); 
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

