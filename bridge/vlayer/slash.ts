import { createVlayerClient } from "@vlayer/sdk";
import proverSpec from "../out/MisbehaviorProver.sol/MisbehaviorProver";
import verifierSpec from "../out/BridgeDestination.sol/BridgeDestination";
import { createPublicClient, createWalletClient, defineChain, http } from "viem";
import { anvil } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";

const vlayer = createVlayerClient({
  url: "http://127.0.0.1:3000",
  // token: config.token,
});

// const { prover, verifier } = await deployVlayerContracts({
//   proverSpec,
//   verifierSpec,
//   proverArgs: [],
//   verifierArgs: [whaleBadgeNFTAddress],
// });
const prover = "0x663e903Ff15A0e911258cEA2116b2071e80fED68";
const verifier = "0xED7EC2d4d4d9a6a702769679FB5A36f55EBf197B";

const proofHash = await vlayer.prove({
  address: prover,
  proverAbi: proverSpec.abi,
  functionName: "didNotBridge",
  // address relayer, address _token, address _tokenDest, address _owner, uint256 depositBlockId
  args: ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "0x851356ae760d987E095750cCeb3bC6014560891C", "0x1D55838a9EC169488D360783D65e6CD985007b72", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 44],
  chainId: 31338,
  // gasLimit: config.gasLimit,
});
const result = await vlayer.waitForProvingResult({ hash: proofHash });
console.log("Proof:", result[0]);
console.log("⏳ Verifying...");

export const anvil2 = /*#__PURE__*/ defineChain({
  id: 31_338,
  name: 'Anvil',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: {
      http: ['http://127.0.0.1:8545'],
      webSocket: ['ws://127.0.0.1:8545'],
    },
  },
})

const publicClient = createPublicClient({
  chain: anvil2,
  transport: http("http://127.0.0.1:8546"),
});


const account =  privateKeyToAccount("0xb6b15c8cb491557369f3c7d2c287b053eb229daa9c22138887752191c9520659"); // DEPLOYER_PRIVATE_KEY

const walletClient = createWalletClient({
  account,
  chain: anvil2,
  transport: http("http://127.0.0.1:8546"),
});

// Workaround for viem estimating gas with `latest` block causing future block assumptions to fail on slower chains like mainnet/sepolia
const gas = await publicClient.estimateContractGas({
  address: verifier,
  abi: verifierSpec.abi,
  functionName: "slashWithProof",
  args: result,
  account,
  blockTag: "pending",
});

const verificationHash = await walletClient.writeContract({
  address: verifier,
  abi: verifierSpec.abi,
  functionName: "slashWithProof",
  args: result,
  account,
  gas,
});

const receipt = await publicClient.waitForTransactionReceipt({
  hash: verificationHash,
  confirmations: 1, //confirmations,
  retryCount: 60,
  retryDelay: 1000,
});

console.log(`✅ Verification result: ${receipt.status}`);
