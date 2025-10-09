const admin = require('firebase-admin');
const path = require('path');
require('dotenv').config();

// FIX: Resolve the path relative to the project's root working directory (process.cwd())
// This correctly handles the path defined in .env (e.g., './src/config/serviceAccountKey.json')
const serviceAccountPath = path.resolve(process.cwd(), process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './src/config/serviceAccountKey.json');

try {
  // Check if the app is already initialized (important for nodemon/hot reload)
  if (!admin.apps.length) {
    // Attempt to load the service account key
    // NOTE: This will crash if the file is missing, but it is necessary for security.
    const serviceAccount = require(serviceAccountPath);
    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log("Firebase Admin SDK initialized successfully.");
  }
  
  const db = admin.firestore();
  module.exports = { admin, db };

} catch (error) {
  // If the error is MODULE_NOT_FOUND (i.e., the JSON file is missing), display a clear message.
  if (error.code === 'MODULE_NOT_FOUND' && error.message.includes('serviceAccountKey.json')) {
      console.error("\n*** FATAL ERROR: FIREBASE SERVICE KEY MISSING ***");
      console.error("Please place your Firebase service account JSON key at:");
      console.error(serviceAccountPath);
  } else {
      console.error("FIREBASE INITIALIZATION ERROR: Ensure .env path is correct and the service account file exists.");
  }
  
  // Export dummy objects to prevent the entire server from crashing during development if the database is down.
  module.exports = { admin: { auth: () => ({}) }, db: { collection: () => ({}) } };
}
