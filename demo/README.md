# Demo and Video

The demo video can be found [here](./Acrozz.mp4) and on [YouTube](https://youtu.be/K3eV4UeGP48).

## Deployment

The following chains are missing the Vlayer Teleport integration. However, I was able to bypass the
prover and verifier and mock them up, and deploy the contracts on the following testnets. To see what was mocked up, switch to the branch "deployments" of this repo:

### Flow

MisbehaviorProver deployed at: 0x0BC0d4533D9ecFFd21EEd49CbdFA677a384Fa96d

BridgeDestination deployed at: 0x43eA72b2c65b1e8A44150B1A438751e196B5C6F5

### Rootstock

MisbehaviorProver deployed at: 0xB12b792AccD473F9C4A35787eEcd46529249D0cb

BridgeDestination deployed at: 0xCE1De27853eF6C70cd4c35FB94147F9ED25315E0

## How to test

Here are the steps:

### Set up

To create tokens on the source and destination chains and fund the caller and relayer:
```
cd bridge
./createTokens.sh
```
and record the two token addresses. Then put them in the file ```bridge/vlayer/.enc.relayer``` under ```SOURCE_ERC20_ADDRESS``` and ```DESTINATION_ERC20_ADDRESS```.

Then install the ```BridgeDestination``` contract:
```
cd bridge
./deployBridgeDestination.sh
```
record the contract address into ```bridge/vlayer/.enc.relayer``` under ```BRIDGE_DESTINATION_CONTRACT```.

Then run the relayer:
```
cd bridge/vlayer
bun run relayer:dev
```

### Transfer through the bridge

Let's transfer some tokens. Pay to the bridge on the source blockchain:
```
./transfer_token_source.sh <SOURCE_ERC20_ADDRESS> <RELAYER_ADDRESS> 132435
```
in my case
```
./transfer_token_source.sh 0x851356ae760d987E095750cCeb3bC6014560891C 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 33333
```
and see in the Relayer logs (in the relayer shell):
```
Relayer running. Watching for deposits to 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 on source chain...
Deposit detected: from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, amount 33333
Source tx: 0xecf6133013e38f5e552f98899c02b3a8fc67f136cf1229211d4c38becec9187b, block: 43
Transferred 33333 tokens to 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 on destination chain.
Destination tx: 0x9962b98ef888126bb4a154127d79f362a031b4a4814404a6ba4a03af4b65597b, block: 29
```

Let's check the balance on the destination chain:
```
./balance_destination.sh <DESTINATION_ERC20_ADDRESS> <USER_ADDRESS>
```
in my case:
```
./balance_destination.sh 0x1D55838a9EC169488D360783D65e6CD985007b72  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```
which shows:
33333
when converted to decimal, as expected.
**The bridging is successful.**

### Slashing

Now let's kill the bridge process to see slashing. 

Then pay to the bridge:
```
./transfer_token_source.sh 0x851356ae760d987E095750cCeb3bC6014560891C 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 222222
```

Then we can slash the bridge:
```
bun run slash:dev
```
and see the relayer get slashed:
```
$ VLAYER_ENV=dev bun run slash.ts
Proof: {
  seal: {
    verifierSelector: "0xdeafbeef",
    seal: [ "0x8322b69eeee691a468ef2e844df08001c24426e2b83cc20fbde8ec924fa32c7c", "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000000000000000000000000000", "0x0000000000000000000000000000000000000000000000000000000000000000"
    ],
    mode: 1,
  },
  callGuestId: "0xdcb00648ecc90d8bfe92aa8d51061beb0bcb110d274fc4a517e526574233d36b",
  length: 896,
  callAssumptions: {
    proverContractAddress: "0x663e903ff15a0e911258cea2116b2071e80fed68",
    functionSelector: "0x1ce6dc81",
    settleChainId: "0x7a6a",
    settleBlockNumber: "0x34",
    settleBlockHash: "0xd9f5d336f513c7a9bbb6b81fe06c46adcb280a1d84bc92deb54d7134b6030452",
  },
}
⏳ Verifying...
✅ Verification result: success
Slashing completed successfully!
```

And if we try the same again, the failsafe will kick in adn complain with:
```
Block already processed
```