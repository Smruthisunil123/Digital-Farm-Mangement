const express = require('express');
const router = express.Router();
const prescriptionController = require('../controllers/prescriptionController');
const reportController = require('../controllers/reportController');

// --- Prescription Management ---
router.post('/add', prescriptionController.addPrescription);
router.get('/history', prescriptionController.getPrescriptionHistory);

// --- ML Service Routes ---
// ✅ THE FIX: The route is updated to '/scan-and-speak' and calls the new function.
router.post('/scan-and-speak', reportController.handleScanAndSpeak);

// The chatbot route is also updated to use the correct function
router.post('/chatbot', reportController.handleChatbotQuery);

// Use reportController for calculation, not prescriptionController (to keep ML logic together)
router.post('/calculate-withdrawal', reportController.calculateWithdrawal);

module.exports = router;