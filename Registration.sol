


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PatientRegistry {
    struct Patient {
        string name;
        uint age;
        string gender;
        string bloodGroup;
        string phone;
        string email;
        string addressInfo;
        string healthcardId;
        string emergencyContactName;
        string emergencyContactPhone;
        string medicalHistoryHash;
        bytes32 passwordHash;
        bool isRegistered;
    }

    mapping(address => Patient) private patients;
    mapping(string => bool) private healthcardUsed; // Ensure unique healthcard IDs

    event PatientRegistered(address indexed patientAddress, string name, uint age, string healthcardId);

    // ✅ Using a struct input to avoid "Stack too deep" error
    function registerPatient(
        Patient memory newPatient,
        string memory newPassword,
        string memory confirmPassword
    ) public {
        require(!patients[msg.sender].isRegistered, "Patient already registered");
        require(!healthcardUsed[newPatient.healthcardId], "Healthcard ID already in use");
        require(keccak256(abi.encodePacked(newPassword)) == keccak256(abi.encodePacked(confirmPassword)), "Passwords do not match");

        newPatient.passwordHash = keccak256(abi.encodePacked(newPassword)); // Hash the password
        newPatient.isRegistered = true;
        
        patients[msg.sender] = newPatient;
        healthcardUsed[newPatient.healthcardId] = true; // Mark healthcard ID as used
        
        emit PatientRegistered(msg.sender, newPatient.name, newPatient.age, newPatient.healthcardId);
    }

    // Function to retrieve patient details (without exposing password)
    function getPatientDetails(address _patientAddress) public view returns (
        string memory, uint, string memory, string memory, string memory, string memory, string memory,
        string memory, string memory, string memory, string memory
    ) {
        require(patients[_patientAddress].isRegistered, "Patient not found");

        Patient memory p = patients[_patientAddress];
        return (
            p.name, p.age, p.gender, p.bloodGroup, p.phone, p.email, p.addressInfo,
            p.healthcardId, p.emergencyContactName, p.emergencyContactPhone, p.medicalHistoryHash
        );
    }
}