import hre from "hardhat";
import { formatEther } from "viem";

async function main() {
  const connection = await hre.network.connect({ network: "localhost" });
  const { viem } = connection;

  const publicClient = await viem.getPublicClient();
  const walletClients = await viem.getWalletClients();

  console.log("Local Hardhat account balances");
  console.log("----------------------------------------");

  for (let i = 0; i < walletClients.length; i++) {
    const address = walletClients[i].account.address;
    const balance = await publicClient.getBalance({ address });

    console.log(`Account ${i}: ${address}`);
    console.log(`Balance: ${balance.toString()} wei`);
    console.log(`Balance: ${formatEther(balance)} ETH`);
    console.log("----------------------------------------");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
