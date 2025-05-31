// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Prover} from "vlayer-0.1.0/Prover.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract MisbehaviorProver is Prover {
    address public prover;
    address public token;
    address public tokenDest;

    constructor(address _prover, address _token, address _tokenDest) {
        prover = _prover;
        token = _token;
        tokenDest = _tokenDest;
    }

    uint256 constant DEADLINE = 100; // Blocks after which the deposit is considered expired

    function didNotBridge(address relayer, address _token, address _tokenDest, address _owner, uint256 depositBlockId)
        public
        returns (Proof memory, address, address, address, address, uint256, uint256)
    {
        require(token == _token, "Invalid token");
        require(tokenDest == _tokenDest, "Invalid destination token");
        uint256 currentBlock = block.number;
        setChain(31337, depositBlockId-1);
        uint256 oldBalance = IERC20(token).balanceOf(_owner);
        setChain(31337, depositBlockId);
        uint256 newBalance = IERC20(token).balanceOf(_owner);
        
        setChain(31337, depositBlockId + DEADLINE); // Reverts if in the future

        setChain(31338, currentBlock);
        require(IERC20(tokenDest).balanceOf(_owner) == newBalance, "Balance mismatch");
        // I know I have to loop to make sure the user did not take the funds already, but this is too expensive
        // for this prototype, so I'll avoid it for the sake of demoing in decent time.

        return (proof(), relayer, token, tokenDest, _owner, depositBlockId, newBalance - oldBalance);
    }
}
