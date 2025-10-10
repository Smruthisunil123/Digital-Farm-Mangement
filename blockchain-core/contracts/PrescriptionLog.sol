// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PrescriptionLog
 * @dev A smart contract to log veterinary prescriptions for tamper-proof traceability.
 */
contract PrescriptionLog {
    // A counter to assign a unique ID to each prescription
    uint256 private _prescriptionCounter;

    // Defines the data structure for a prescription
    struct Prescription {
        uint256 id;
        address vetAddress; // Address of the veterinarian's wallet
        string farmerId;
        string animalId;
        string medicineName;
        string dosage;
        uint256 withdrawalPeriod; // In days
        uint256 timestamp;
    }

    // An event that is emitted every time a new prescription is logged
    event PrescriptionLogged(
        uint256 indexed id,
        address indexed vetAddress,
        string farmerId,
        uint256 timestamp
    );

    // A mapping to store prescriptions by their unique ID
    mapping(uint256 => Prescription) public prescriptions;

    /**
     * @dev Logs a new prescription to the blockchain.
     * @param _vetAddress The wallet address of the prescribing vet.
     * @param _farmerId A unique identifier for the farmer.
     * @param _animalId A unique identifier for the animal.
     * @param _medicineName The name of the prescribed medicine.
     * @param _dosage The prescribed dosage instructions.
     * @param _withdrawalPeriod The required withdrawal period in days.
     */
    function logPrescription(
        address _vetAddress,
        string memory _farmerId,
        string memory _animalId,
        string memory _medicineName,
        string memory _dosage,
        uint256 _withdrawalPeriod
    ) public {
        uint256 currentId = _prescriptionCounter;
        
        // Store the new prescription in the mapping
        prescriptions[currentId] = Prescription({
            id: currentId,
            vetAddress: _vetAddress,
            farmerId: _farmerId,
            animalId: _animalId,
            medicineName: _medicineName,
            dosage: _dosage,
            withdrawalPeriod: _withdrawalPeriod,
            timestamp: block.timestamp
        });

        // Emit an event to notify off-chain services
        emit PrescriptionLogged(currentId, _vetAddress, _farmerId, block.timestamp);
        
        // Increment the counter for the next prescription
        _prescriptionCounter++;
    }
}