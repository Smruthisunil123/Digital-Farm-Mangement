const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointmentController');

// Defines the route to get all appointments
// GET /api/v1/appointments/
router.get('/', appointmentController.getAllAppointments);

module.exports = router;
