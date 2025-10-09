const express = require('express');
const router = express.Router();
const usersRoutes = require('./users');
const prescriptionsRoutes = require('./prescriptions');
const reportController = require('../controllers/reportController');

// General Status/Health Check
router.get('/', (req, res) => {
    res.status(200).send({ 
        message: 'Digital Farm Management API is running.',
        status: 'OK',
        version: '1.0'
    });
});

// Analytics route for the web dashboard (Authority/Admin)
router.get('/analytics', reportController.getAnalytics);

// Route handlers
// router.use('/users', usersRoutes);
router.use('/prescriptions', prescriptionsRoutes);

module.exports = router;
