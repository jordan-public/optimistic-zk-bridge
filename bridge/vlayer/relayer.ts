import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config({ path: ".env.relayer" });

const RELAYER_PRIVATE_KEY = process.env.RELAYER_PRIVATE_KEY!;
const SOURCE_RPC = process.env.SOURCE_RPC!;
const DEST_RPC = process.env.DEST_RPC!;
const SOURCE_CHAIN_ID = Number(process.env.SOURCE_CHAIN_ID!);
const DEST_CHAIN_ID = Number(process.env.DEST_CHAIN_ID!);
const SOURCE_ERC20_ADDRESS = process.env.SOURCE_ERC20_ADDRESS!;
const DESTINATION_ERC20_ADDRESS = process.env.DESTINATION_ERC20_ADDRESS!;

const providerSource = new ethers.WebSocketProvider(SOURCE_RPC, SOURCE_CHAIN_ID);
const providerDest = new ethers.JsonRpcProvider(DEST_RPC, DEST_CHAIN_ID);
const relayerWalletDest = new ethers.Wallet(RELAYER_PRIVATE_KEY, providerDest);

const ERC20_ABI = [
  "event Transfer(address indexed from, address indexed to, uint256 value)",
  "function transfer(address to, uint256 value) external returns (bool)"
];

const relayerAddress = relayerWalletDest.address;
const erc20Source = new ethers.Contract(SOURCE_ERC20_ADDRESS, ERC20_ABI, providerSource);
const erc20Dest = new ethers.Contract(DESTINATION_ERC20_ADDRESS, ERC20_ABI, relayerWalletDest);

console.log(`Relayer running. Watching for deposits to ${relayerAddress} on source chain...`);

erc20Source.on("Transfer", async (from, to, value, event) => {
  if (to.toLowerCase() !== relayerAddress.toLowerCase()) return;
  // Display source chain tx and block
  const sourceTxHash = event.log.transactionHash;
  const sourceBlockNumber = event.log.blockNumber;
  console.log(
    `Deposit detected: from ${from}, amount ${value.toString()}\n` +
    `Source tx: ${sourceTxHash}, block: ${sourceBlockNumber}`
  );
  try {
    const tx = await erc20Dest.transfer(from, value);
    const receipt = await tx.wait();
    // Display destination chain tx and block
    console.log(
      `Transferred ${value.toString()} tokens to ${from} on destination chain.\n` +
      `Destination tx: ${tx.hash}, block: ${receipt.blockNumber}`
    );
  } catch (err) {
    console.error("Transfer failed:", err);
  }
});