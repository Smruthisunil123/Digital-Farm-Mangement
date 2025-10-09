const axios = require('axios');
require('dotenv').config();

const ML_SERVICE_URL = process.env.ML_SERVICE_URL;

// Placeholder for communicating with the Python ML Backend
const mlService = {
  // Endpoint to send a medicine sachet image/text for OCR
  processOcr: async (imageData) => {
    try {
      // Assuming the ML service expects a POST request with image data
      const response = await axios.post(`${ML_SERVICE_URL}/ocr/process`, { image: imageData });
      return response.data; // Should return extracted text data
    } catch (error) {
      console.error(`ML Service (OCR) communication error: ${error.message}`);
      // Return a default error structure or rethrow
      throw new Error('Failed to communicate with ML OCR service.');
    }
  },

  // Endpoint to communicate with the farmer chatbot model
  getChatbotResponse: async (userId, message) => {
    try {
      const response = await axios.post(`${ML_SERVICE_URL}/chatbot/ask`, { userId, message });
      return response.data; // Should return text response and potentially TTS audio link
    } catch (error) {
      console.error(`ML Service (Chatbot) communication error: ${error.message}`);
      throw new Error('Failed to communicate with ML Chatbot service.');
    }
  }
};

module.exports = mlService;
