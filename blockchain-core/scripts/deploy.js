// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

async function main() {
  // Get the contract factory for our PrescriptionLog contract
  const PrescriptionLog = await hre.ethers.getContractFactory("PrescriptionLog");

  // Deploy the contract
  console.log("Deploying PrescriptionLog contract...");
  const prescriptionLog = await PrescriptionLog.deploy();

  // Wait for the deployment to be confirmed
  await prescriptionLog.deployed();

  // Log the address of the deployed contract
  console.log(`PrescriptionLog deployed to: ${prescriptionLog.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exit(1);
});