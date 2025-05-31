# Demo and Video

The demo video can be found [here]() and on [YouTube]().

## Deployment

## How to test

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