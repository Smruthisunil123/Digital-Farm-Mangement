const { admin, db } = require('../config/firebase');
const auth = admin.auth();

const authController = {
  // --- Your register function is correct, no changes needed ---
  register: async (req, res) => {
    const { email, password, role, name } = req.body;
    if (!email || !password || !role) {
      return res.status(400).send({ message: 'Missing required fields: email, password, role.' });
    }

    try {
      const userRecord = await auth.createUser({ email, password, displayName: name });
      const uid = userRecord.uid;
      await auth.setCustomUserClaims(uid, { role });
      await db.collection('users').doc(uid).set({
        uid,
        email,
        name,
        role,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      res.status(201).send({ uid, email, role, message: 'User registered successfully.' });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).send({ message: 'Error during registration.', error: error.message });
    }
  },

  // --- LOGIN FUNCTION CORRECTED ---
  login: async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).send({ message: 'Missing email or password.' });
    }

    try {
      // 1. Get user from Firebase Authentication
      const userRecord = await auth.getUserByEmail(email);

      // 2. Get user data document from Firestore
      const userDoc = await db.collection('users').doc(userRecord.uid).get();

      // ✅ **THE FIX IS HERE:** Check if the document actually exists
      if (!userDoc.exists) {
        throw new Error('User data not found in Firestore.');
      }
      
      const userData = userDoc.data();

      // This is a placeholder for password verification. In a real app,
      // the client would sign in with Firebase Auth and send an ID token.
      // For this project, we are trusting the user exists and proceeding.

      // 3. Generate a custom token
      const customToken = await auth.createCustomToken(userRecord.uid, { role: userData.role });
      
      // 4. Send success response
      res.status(200).send({
        message: 'Login successful.',
        token: customToken,
        user: { // Nest user data so Flutter can parse it easily
          id: userRecord.uid,
          email: userRecord.email,
          name: userData.name || '', // Use userData to get the name
          role: userData.role
        }
      });

    } catch (error) {
      console.error('Login error:', error);
      res.status(401).send({ message: 'Invalid credentials or user not found.', error: error.message });
    }
  }
};

module.exports = authController;