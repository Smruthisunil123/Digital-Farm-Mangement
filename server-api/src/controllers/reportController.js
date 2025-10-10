const axios = require('axios');

// The URL where your Python ML service is running
const ML_SERVICE_URL = 'http://localhost:5001';

const reportController = {
  /**
   * Receives a base64 encoded image, forwards it to the Python OCR service,
   * and returns the extracted text.
   */
  handleOcrScan: async (req, res) => {
    // The Flutter app will send a JSON object with a key named 'image'
    const { image } = req.body;

    if (!image) {
      return res.status(400).send({ message: 'No image data provided.' });
    }

    try {
      console.log('[Node Server] Received image scan request. Forwarding to Python ML service...');

      // Make a POST request to the Python OCR endpoint at http://localhost:5001/ocr
      const ocrResponse = await axios.post(`${ML_SERVICE_URL}/ocr`, {
        image: image, // Forward the base64 string in the request body
      });

      console.log('[Node Server] Received response from Python service.');

      // Send the extracted text from the Python service back to the Flutter app
      res.status(200).send({
        message: 'OCR processing successful.',
        text: ocrResponse.data.text,
      });

    } catch (error) {
      console.error('[Node Server] Error calling Python ML service:', error.message);
      res.status(500).send({ message: 'Failed to process image with ML service.' });
    }
  },

  /**
   * Placeholder for your chatbot logic.
   */
  handleChatbotQuery: async (req, res) => {
    // Get the 'query' and 'role' from the request body sent by Flutter
    const { query, role } = req.body;

    if (!query || !role) {
      return res.status(400).send({ message: 'Missing query or role in request.' });
    }

    try {
      console.log(`[Node Server] Received chatbot query: "${query}". Forwarding to Python...`);

      // Make a POST request to the Python /chat endpoint
      const chatbotResponse = await axios.post(`${ML_SERVICE_URL}/chat`, {
        query: query,
        role: role,
      });

      console.log('[Node Server] Received response from Python chatbot.');
      
      // Send the text response from the Python service back to the Flutter app
      res.status(200).send({
        response: chatbotResponse.data.response,
      });

    } catch (error) {
      console.error('[Node Server] Error calling Python chatbot service:', error.message);
      res.status(500).send({ message: 'Failed to get chatbot response.' });
    }
  },

  /**
  * Placeholder for analytics logic
  */
  getAnalytics: async (req, res) => {
    res.status(501).send({ message: 'Analytics feature not implemented yet.'});
  }
};

module.exports = reportController;
