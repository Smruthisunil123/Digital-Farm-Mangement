const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Authentication routes
router.post('/register', authController.register);
router.post('/login', authController.login);

// Placeholder for profile update (requires auth middleware)
// router.put('/profile', authMiddleware, userController.updateProfile);

module.exports = router;
