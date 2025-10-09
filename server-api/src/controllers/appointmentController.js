const { db } = require('../config/firebase');

const appointmentController = {
  // Fetches all appointments from the Firestore collection
  getAllAppointments: async (req, res) => {
    try {
      const snapshot = await db.collection('appointments').get();
      
      if (snapshot.empty) {
        return res.status(200).send([]); // Return empty array if no appointments
      }

      const appointments = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      res.status(200).send(appointments);

    } catch (error) {
      console.error('Error fetching appointments:', error);
      res.status(500).send({ message: 'Failed to fetch appointments.', error: error.message });
    }
  },

  // Placeholder for creating a new appointment
  createAppointment: async (req, res) => {
    // We will build this feature later
    res.status(501).send({ message: 'Feature not implemented yet.' });
  }
};

module.exports = appointmentController;
