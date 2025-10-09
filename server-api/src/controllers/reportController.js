const { db } = require('../config/firebase');
const mlService = require('../services/mlService');

const reportController = {
  // Handler for OCR API from the mobile app
  handleOcrScan: async (req, res) => {
    const { imageBase64 } = req.body;
    if (!imageBase64) {
      return res.status(400).send({ message: 'Missing imageBase64 data.' });
    }

    try {
      // Forward the image data to the Python ML service
      const mlResponse = await mlService.processOcr(imageBase64);

      // mlResponse should contain extracted text like: { medication: "Amoxicillin", dosage: "50mg" }
      res.status(200).send(mlResponse); 
    } catch (error) {
      console.error('Error handling OCR scan:', error);
      res.status(503).send({ message: 'ML service unavailable or failed to process OCR.', error: error.message });
    }
  },

  // Handler for chatbot queries from the mobile app
  handleChatbotQuery: async (req, res) => {
    const { userId, message } = req.body;
    if (!userId || !message) {
      return res.status(400).send({ message: 'Missing user ID or message.' });
    }

    try {
      // Forward the query to the Python ML service
      const mlResponse = await mlService.getChatbotResponse(userId, message);

      // mlResponse should contain chatbot text response and potentially TTS link
      res.status(200).send(mlResponse);
    } catch (error) {
      console.error('Error handling chatbot query:', error);
      res.status(503).send({ message: 'ML service unavailable or failed to generate response.', error: error.message });
    }
  },

  // Generates aggregate data for the Web Dashboard
  getAnalytics: async (req, res) => {
    // Placeholder for actual complex aggregation logic (e.g., MongoDB aggregation pipeline)
    try {
      // Simulate fetching general analytics
      const analyticsData = {
        totalPrescriptions: 1500,
        activeVets: 55,
        newFarmersLastMonth: 120,
        medicationTrends: [
            { name: "Amoxicillin", count: 300 },
            { name: "Ivermectin", count: 250 }
        ]
      };
      res.status(200).send(analyticsData);
    } catch (error) {
      console.error('Error generating analytics:', error);
      res.status(500).send({ message: 'Failed to generate analytics data.', error: error.message });
    }
  }
};

module.exports = reportController;
