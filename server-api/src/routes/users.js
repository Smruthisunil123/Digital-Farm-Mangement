const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

const userController = require('../controllers/userController');

// Authentication routes
router.post('/register', authController.register);
router.post('/login', authController.login);

router.get('/farmers', userController.getAllFarmers);
// Placeholder for profile update (requires auth middleware)
// router.put('/profile', authMiddleware, userController.updateProfile);

module.exports = router;
