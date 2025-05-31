# Demo and Video

The demo video can be found [here]() and on [YouTube]().

## Deployment

## How to test

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
