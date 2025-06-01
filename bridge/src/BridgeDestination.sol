// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {MisbehaviorProver} from "./MisbehaviorProver.sol";
import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Verifier} from "vlayer-0.1.0/Verifier.sol";

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract BridgeDestination /*is Verifier*/ {
    address public _prover;
    address public _token;
    address public _tokenDest;

    event Claimed(address indexed depositor, uint256 amount, uint256 bonus);

    mapping(uint256 => bool) public processedBlocks;

    constructor(address prover, address token, address tokenDest) {
        _prover = prover;
        _token = token;
        _tokenDest = tokenDest;
    }

    // Staking issue ignored for the purpose of simplicity:
    // The relayer has all his funds in his own address, but in order to operate the bridge,
    // he needs to authorize the slasher to transfer funds for slashing. In a real world scenario,
    // the relayer would need to stake some funds in the slasher contract, which would be used
    // to pay the depositor in case of misbehavior. In addition the relayer should not be able to withdraw
    // the funds for a pre-determined period of time in order to prevent him from withdrawing the funds
    // immediately after the deposit is made, which would allow him to avoid slashing.

    // Called by user if funds not received on destination chain
    // proof(), relayer, token, tokenDest, _owner, depositBlockId, newBalance
    function slashWithProof(/*Proof calldata,*/ address relayer, address token, address tokenDest, address depositor, uint256 blockId, uint256 amount)
    public /*onlyVerified(_prover, MisbehaviorProver.didNotBridge.selector)*/ {
        require(!processedBlocks[blockId], "Block already processed");
        processedBlocks[blockId] = true;
        require(token == _token, "Invalid token");
        require(tokenDest == _tokenDest, "Invalid destination token");
        uint256 payout = (amount * 110) / 100; // 110% of deposited amount
        // require(IERC20(tokenDest).balanceOf(relayer) >= payout, "Insufficient reserve");
        // require(IERC20(tokenDest).transfer(depositor, payout), "Token transfer failed");
        emit Claimed(depositor, amount, payout - amount);
    }
}
