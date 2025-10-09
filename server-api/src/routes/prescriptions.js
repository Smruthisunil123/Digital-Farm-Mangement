const express = require('express');
const router = express.Router();
const prescriptionController = require('../controllers/prescriptionController');
const reportController = require('../controllers/reportController');

// Prescription management
router.post('/add', prescriptionController.addPrescription); // Vet submits new prescription
router.get('/history', prescriptionController.getPrescriptionHistory); // Farmer/Vet views history

// ML/Report routes tied to prescription ecosystem
router.post('/scan/ocr', reportController.handleOcrScan); // Mobile app sends image for OCR
router.post('/chatbot', reportController.handleChatbotQuery); // Mobile app sends chatbot message

module.exports = router;
