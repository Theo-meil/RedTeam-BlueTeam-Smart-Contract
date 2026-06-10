const hre = require("hardhat");

async function main() {
  const [deployer, user, attacker] = await hre.ethers.getSigners();

  console.log("Deployer:", deployer.address);
  console.log("User:", user.address);
  console.log("Attacker:", attacker.address);

  const Bank = await hre.ethers.getContractFactory("VulnerableBank");
  const bank = await Bank.deploy();
  await bank.waitForDeployment();

  const bankAddress = await bank.getAddress();
  console.log("VulnerableBank deployed to:", bankAddress);

  const seed1 = await bank.connect(deployer).deposit({ value: hre.ethers.parseEther("5") });
  await seed1.wait();
  const seed2 = await bank.connect(user).deposit({ value: hre.ethers.parseEther("5") });
  await seed2.wait();

  const Attacker = await hre.ethers.getContractFactory("ReentrancyAttacker");
  const attackerContract = await Attacker.connect(attacker).deploy(bankAddress);
  await attackerContract.waitForDeployment();

  console.log("ReentrancyAttacker deployed to:", await attackerContract.getAddress());
  console.log("Bank balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(bankAddress)), "ETH");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
