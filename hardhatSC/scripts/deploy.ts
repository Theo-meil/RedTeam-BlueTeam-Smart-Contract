import { network } from "hardhat";

async function main() {
  const connection = await network.connect({ network: "localhost" });
  const { viem } = connection;

  const [walletClient] = await viem.getWalletClients();
  const publicClient = await viem.getPublicClient();

  const bank = await viem.deployContract("VulnerableBank");
  const access = await viem.deployContract("VulnerableAccessControl");

  console.log("Deployer:", walletClient.account.address);
  console.log("VulnerableBank:", bank.address);
  console.log("VulnerableAccessControl:", access.address);

  const hash1 = await bank.write.deposit([], { value: 1000000000000000000n });
  await publicClient.waitForTransactionReceipt({ hash: hash1 });

  const bankBalance = await bank.read.getContractBalance();
  console.log("Bank seeded with:", bankBalance.toString(), "wei");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
