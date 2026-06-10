const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Reentrancy attack demo", function () {
  it("drains funds from the vulnerable bank", async function () {
    const [deployer, user, attackerEOA] = await ethers.getSigners();

    const Bank = await ethers.getContractFactory("VulnerableBank");
    const bank = await Bank.deploy();
    await bank.waitForDeployment();
    const bankAddress = await bank.getAddress();

    await (await bank.connect(deployer).deposit({ value: ethers.parseEther("5") })).wait();
    await (await bank.connect(user).deposit({ value: ethers.parseEther("5") })).wait();

    const Attacker = await ethers.getContractFactory("ReentrancyAttacker");
    const attacker = await Attacker.connect(attackerEOA).deploy(bankAddress);
    await attacker.waitForDeployment();
    const attackerAddress = await attacker.getAddress();

    expect(await ethers.provider.getBalance(bankAddress)).to.equal(ethers.parseEther("10"));

    await (await attacker.connect(attackerEOA).attack({ value: ethers.parseEther("1") })).wait();

    const bankBalanceAfter = await ethers.provider.getBalance(bankAddress);
    const attackerContractBalance = await ethers.provider.getBalance(attackerAddress);

    expect(bankBalanceAfter).to.equal(0n);
    expect(attackerContractBalance).to.be.greaterThanOrEqual(ethers.parseEther("11"));
  });
});
