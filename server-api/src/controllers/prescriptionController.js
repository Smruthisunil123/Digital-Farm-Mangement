const { admin, db } = require('../config/firebase');
const blockchainService = require('../services/blockchainService');

const prescriptionController = {
  addPrescription: async (req, res) => {
    // ✅ 1. ADD 'diagnosis' TO THE FIELDS WE EXPECT
    const { vetId, farmerId, animalTagId, diagnosis, withdrawalDays, medications } = req.body;

    if (!vetId || !farmerId || !medications || !Array.isArray(medications) || !diagnosis) {
      return res.status(400).send({ message: 'Missing required fields: vetId, farmerId, diagnosis, or medications.' });
    }

    try {
      const newPrescriptionRef = db.collection('prescriptions').doc();
      
      const prescriptionData = {
        prescriptionId: newPrescriptionRef.id,
        vetId,
        farmerId,
        animalTagId,
        diagnosis: diagnosis, // ✅ 2. SAVE THE DIAGNOSIS TO THE DATABASE
        withdrawalDays: parseInt(withdrawalDays) || 0,
        medications: medications,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await newPrescriptionRef.set(prescriptionData);

      const primaryMedicationName = medications[0].medicationName || 'multiple';
      // We can also pass the diagnosis to the blockchain log
      const blockchainResult = await blockchainService.logPrescriptionEvent(
        prescriptionData.prescriptionId, 
        vetId, 
        farmerId,
        primaryMedicationName
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
    // This function remains the same. It already sends the *entire* document,
    // so the new 'diagnosis' field will be automatically included.
    const { farmerId } = req.query;
    if (!farmerId) {
      return res.status(400).send({ message: 'Missing farmerId query parameter.' });
    }
    try {
      const snapshot = await db.collection('prescriptions')
        .where('farmerId', '==', farmerId)
        .get();
      const history = snapshot.docs.map(doc => doc.data());
      res.status(200).send(history);
    } catch (error) {
      console.error('Error fetching history:', error);
      res.status(500).send({ message: 'Failed to fetch prescription history.', error: error.message });
    }
  }
};

module.exports = prescriptionController;