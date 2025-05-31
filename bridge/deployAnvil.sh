#!/bin/sh
# Run anvil.sh in another shell before running this
set -e

# To load the variables in the .env file
. ./.env

# To deploy and verify our contract
forge script script/BridgeDestination.s.sol:Deploy --rpc-url "http://127.0.0.1:8546/" --sender $DEPLOYER_ADDRESS --private-key $DEPLOYER_PRIVATE_KEY --broadcast -v
