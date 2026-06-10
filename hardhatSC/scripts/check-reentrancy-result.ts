import hre from "hardhat";
import { formatEther, parseEther } from "viem";

const VICTIM_ADDRESS = "0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0";
const ATTACKER_ADDRESS = "0xdc64a140aa3e981100a9beca4e685f962f0cf6c9";

async function main() {
  const { viem } = await hre.network.createServer().then(async () => {
    const connection = await hre.network.connect({ network: "localhost" });
    return connection;
  });

  const publicClient = await viem.getPublicClient();

  const victimBalance = await publicClient.getBalance({ address: VICTIM_ADDRESS as `0x${string}` });
  const attackerBalance = await publicClient.getBalance({ address: ATTACKER_ADDRESS as `0x${string}` });

  console.log("Victim contract:", VICTIM_ADDRESS);
  console.log("Victim final balance:", victimBalance.toString(), "wei");
  console.log("Victim final balance:", formatEther(victimBalance), "ETH");
  console.log("Attacker contract:", ATTACKER_ADDRESS);
  console.log("Attacker final balance:", attackerBalance.toString(), "wei");
  console.log("Attacker final balance:", formatEther(attackerBalance), "ETH");

  const victimOk = victimBalance === 0n;
  const attackerOk = attackerBalance >= parseEther("11");

  console.log("Victim drained:", victimOk ? "YES" : "NO");
  console.log("Attacker >= 11 ETH:", attackerOk ? "YES" : "NO");

  if (victimOk && attackerOk) {
    console.log("SUCCESS: Reentrancy drain confirmed on the local Hardhat network.");
  } else {
    console.log("CHECK FAILED: balances do not match the expected drain result.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
