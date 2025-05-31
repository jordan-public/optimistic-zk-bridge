#!/bin/zsh
set -ex
# Usage: ./transfer_token.sh <TOKEN_ADDRESS> <TO_ADDRESS> <AMOUNT> <PRIVATE_KEY> <RPC_URL>

. ./.env

TOKEN_ADDRESS=$1
TO_ADDRESS=$2
AMOUNT=$3

cast send $TOKEN_ADDRESS "transfer(address,uint256)" $TO_ADDRESS $AMOUNT \
  --private-key $DEPLOYER_SOURCE_PRIVATE_KEY \
  --rpc-url "http://127.0.0.1:8545"