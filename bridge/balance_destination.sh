#!/bin/zsh
set -ex
# Usage: ./transfer_token.sh <TOKEN_ADDRESS> <TO_ADDRESS> <AMOUNT> <PRIVATE_KEY> <RPC_URL>

. ./.env

TOKEN_ADDRESS=$1
BAL_ADDRESS=$2

cast call $TOKEN_ADDRESS "balanceOf(address)" $BAL_ADDRESS \
  --rpc-url "http://127.0.0.1:8546"