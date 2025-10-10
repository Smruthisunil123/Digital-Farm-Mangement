const { admin, db } = require('../config/firebase');
const blockchainService = require('../services/blockchainService'); // Commented out for now

const prescriptionController = {
  // Renamed to addPrescription to match intent
  addPrescription: async (req, res) => {
    // ✅ FIX: Use field names that match the Flutter form
    const {
      vetId,
      farmerId,
      animalTagId,
      medicationName,
      dosage,
      withdrawalDays
    } = req.body;

    if (!vetId || !farmerId || !medicationName) {
      return res.status(400).send({ message: 'Missing required prescription fields.' });
    }

    try {
      const newPrescriptionRef = db.collection('prescriptions').doc();
      
      const prescriptionData = {
        id: newPrescriptionRef.id,
        vetId,
        farmerId,
        animalTagId, // ✅ FIX: Correct field name
        medicationName, // ✅ FIX: Correct field name
        dosage,
        withdrawalDays: parseInt(withdrawalDays) || 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };

      // 1. Save to Firestore
      await newPrescriptionRef.set(prescriptionData);

     
      const blockchainResult = await blockchainService.logPrescriptionEvent(
        prescriptionData.id, vetId, farmerId
      );

      res.status(201).send({
         message: 'Prescription created and logged to blockchain.',

        // ✅ 3. INCLUDE THE TRANSACTION HASH from your service in the response

        blockchainTxHash: blockchainResult.transactionHash, 

        prescription: prescriptionData,
      });

    } catch (error) {
      console.error('Error creating prescription:', error);
      res.status(500).send({ message: 'Failed to create prescription.', error: error.message });
    }
  },

  // Your getPrescriptionHistory function looks fine
  getPrescriptionHistory: async (req, res) => {
    const { farmerId } = req.query; 
    if (!farmerId) {
      return res.status(400).send({ message: 'Missing farmerId query parameter.' });
    }
    try {
      const snapshot = await db.collection('prescriptions').where('farmerId', '==', farmerId).get();
      const history = snapshot.docs.map(doc => doc.data());
      res.status(200).send(history);
    } catch (error) {
      console.error('Error fetching history:', error);
      res.status(500).send({ message: 'Failed to fetch prescription history.', error: error.message });
    }
  }
};

module.exports = prescriptionController;

