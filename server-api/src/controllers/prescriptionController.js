const { admin, db } = require('../config/firebase');
const blockchainService = require('../services/blockchainService');

const prescriptionController = {
  addPrescription: async (req, res) => {
    // ✅ FIX: The request body now contains an array of medications
    const { vetId, farmerId, animalTagId, withdrawalDays, medications } = req.body;

    if (!vetId || !farmerId || !medications || !Array.isArray(medications) || medications.length === 0) {
      return res.status(400).send({ message: 'Missing required fields or medications.' });
    }

    try {
      const newPrescriptionRef = db.collection('prescriptions').doc();
      
      const prescriptionData = {
        prescriptionId: newPrescriptionRef.id,
        vetId,
        farmerId,
        animalTagId,
        withdrawalDays: parseInt(withdrawalDays) || 0,
        medications: medications, // Store the entire array of medications
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await newPrescriptionRef.set(prescriptionData);

      // Log the primary medication to the blockchain
      const primaryMedicationName = medications[0].medicationName || 'multiple';
      const blockchainResult = await blockchainService.logPrescriptionEvent(
        prescriptionData.prescriptionId, 
        vetId, 
        farmerId,
        primaryMedicationName // You could add more data to the log if needed
      );

      res.status(201).send({
        message: 'Prescription created and logged to blockchain.',
        blockchainTxHash: blockchainResult.transactionHash,
        prescription: prescriptionData,
      });

    } catch (error) {
      console.error('Error creating prescription:', error);
      res.status(500).send({ message: 'Failed to create prescription.', error: error.message });
    }
  },
  
  getPrescriptionHistory: async (req, res) => {
    // This function remains the same and will work correctly
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