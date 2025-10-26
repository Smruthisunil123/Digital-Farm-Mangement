const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { protect } = require('../middleware/authMiddleware');

// Route for the new "Scan-to-Speak" feature
router.post('/scan-and-speak', protect, reportController.handleScanAndSpeak);

// Route for the general purpose chatbot
router.post('/chatbot', protect, reportController.handleChatbotQuery);

module.exports = router;