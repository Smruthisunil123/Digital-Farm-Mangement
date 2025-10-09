const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();

// ✅ THIS IS THE FINAL FIX: Manually handle OPTIONS preflight requests
// This block MUST come BEFORE any other routes or cors configuration.
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
  res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  if (req.method === 'OPTIONS') {
    // Respond with 200 OK for preflight requests
    return res.status(200).json({});
  }
  next();
});

// Initialize Firebase
require('./config/firebase');

// --- Routes Imports ---
const usersRoutes = require('./routes/users');
const appointmentsRoutes = require('./routes/appointments');
// ✅ 1. IMPORT THE PRESCRIPTIONS ROUTER
const prescriptionsRoutes = require('./routes/prescriptions');
const router = require('./routes/index');

// We are forcing port 3001 to avoid environment caching issues.
const PORT = 3001;
const MONGO_URI = process.env.MONGO_URI;

// --- Middlewares ---
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

// Debugging Logger
app.use((req, res, next) => {
  console.log(`➡️  Incoming Request: ${req.method} ${req.originalUrl}`);
  next();
});

// --- Database Connection (MongoDB) ---
if (MONGO_URI && MONGO_URI.startsWith('mongodb')) {
    mongoose.connect(MONGO_URI)
        .then(() => console.log('MongoDB connected successfully.'))
        .catch(err => console.error('MongoDB connection error:', err));
} else {
    console.warn("MongoDB URI not set or invalid in .env. Skipping MongoDB connection.");
}

// --- Routes ---
app.use('/api/v1/users', usersRoutes);
app.use('/api/v1/appointments', appointmentsRoutes);
// ✅ 2. USE THE PRESCRIPTIONS ROUTER
app.use('/api/v1/prescriptions', prescriptionsRoutes);
app.use('/api/v1', router);

// --- Error Handling (404) ---
app.use((req, res, next) => {
    res.status(404).send({ message: "Endpoint not found." });
});

// --- Server Start ---
app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n✅ Server API is running on http://0.0.0.0:${PORT}`);
});

module.exports = app;

