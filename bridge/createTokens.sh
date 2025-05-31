#!/bin/sh
# Run anvil.sh in another shell before running this
set -e

# To load the variables in the .env file
. ./.env

forge script script/CreateToken.s.sol:CreateToken --rpc-url "http://127.0.0.1:8545/" --sender $DEPLOYER_SOURCE_ADDRESS --private-key $DEPLOYER_SOURCE_PRIVATE_KEY --broadcast -v

forge script script/CreateToken.s.sol:CreateToken --rpc-url "http://127.0.0.1:8546/" --sender $DEPLOYER_ADDRESS --private-key $DEPLOYER_PRIVATE_KEY --broadcast -v
