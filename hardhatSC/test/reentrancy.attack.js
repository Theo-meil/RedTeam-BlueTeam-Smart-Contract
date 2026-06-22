import { describe, it } from "node:test";
import assert from "node:assert/strict";
import hre from "hardhat";
import { parseEther } from "viem";

describe("Reentrancy attack demo", async () => {
  it("drains funds from the vulnerable bank", async () => {
    const { viem } = await hre.network.connect({ network: "localhost" });

    const [deployer, user, attackerEOA] = await viem.getWalletClients();
    const publicClient = await viem.getPublicClient();

    const bank = await viem.deployContract("VulnerableReentrancy");
    const bankAddress = bank.address;

    let hash = await bank.write.deposit([], {
      account: deployer.account,
      value: parseEther("5"),
    });
    await publicClient.waitForTransactionReceipt({ hash });

    hash = await bank.write.deposit([], {
      account: user.account,
      value: parseEther("5"),
    });
    await publicClient.waitForTransactionReceipt({ hash });

    const attacker = await viem.deployContract("ReentrancyAttacker", [bankAddress], {
      walletClient: attackerEOA,
    });
    const attackerAddress = attacker.address;

    const balanceBefore = await publicClient.getBalance({ address: bankAddress });
    assert.equal(balanceBefore, parseEther("10"));

    hash = await attacker.write.attack([], {
      account: attackerEOA.account,
      value: parseEther("1"),
    });
    await publicClient.waitForTransactionReceipt({ hash });

    const bankBalanceAfter = await publicClient.getBalance({ address: bankAddress });
    const attackerContractBalance = await publicClient.getBalance({ address: attackerAddress });

    assert.equal(bankBalanceAfter, 0n);
    assert.ok(attackerContractBalance >= parseEther("11"));
  });
});
