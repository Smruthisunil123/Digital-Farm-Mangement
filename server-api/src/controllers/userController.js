const { db } = require('../config/firebase');

const userController = {
  getAllFarmers: async (req, res) => {
    try {
      // Fetch all users who have the role 'farmer'
      const snapshot = await db.collection('users').where('role', '==', 'farmer').get();
      
      if (snapshot.empty) {
        return res.status(200).send([]);
      }

      const farmers = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      res.status(200).send(farmers);
    } catch (error) {
      console.error('Error fetching farmers:', error);
      res.status(500).send({ message: 'Failed to fetch farmers.' });
    }
  }
};

module.exports = userController;