// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {MisbehaviorProver} from "./MisbehaviorProver.sol";
import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Verifier} from "vlayer-0.1.0/Verifier.sol";

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract BridgeDestination is Verifier {
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

    // Called by user if funds not received on destination chain
    function slashWithProof(Proof calldata, uint256 blockId, address depositor, uint256 amount, address relayer, address token, address tokenDest)
    public onlyVerified(_prover, MisbehaviorProver.didNotBridge.selector) {
        require(!processedBlocks[blockId], "Block already processed");
        processedBlocks[blockId] = true;
        require(token == _token, "Invalid token");
        require(tokenDest == _tokenDest, "Invalid destination token");
        uint256 payout = (amount * 110) / 100; // 110% of deposited amount
        require(IERC20(tokenDest).balanceOf(relayer) >= payout, "Insufficient reserve");
        require(IERC20(tokenDest).transfer(depositor, payout), "Token transfer failed");
        emit Claimed(depositor, amount, payout - amount);
    }
}
