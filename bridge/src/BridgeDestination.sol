// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract BridgeDestination {
    address public relayer;
    uint256 public reserve;
    IERC20 public token;

    event ReserveDeposited(address indexed relayer, uint256 amount);
    event Claimed(address indexed depositor, uint256 amount, uint256 bonus);

    constructor(address _token) {
        relayer = msg.sender;
        token = IERC20(_token);
    }

    // Relayer deposits reserve funds to cover potential slashing
    function depositReserve(uint256 amount) external {
        require(msg.sender == relayer, "Only relayer");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        reserve += amount;
        emit ReserveDeposited(msg.sender, amount);
    }

    // Mock proof verification (replace with real Vlayer Teleport verification)
    function verifyProof(bytes calldata /*proof*/, uint256 /*blockId*/, uint256 /*amount*/, address /*depositor*/) internal pure returns (bool) {
        /* In production, call Vlayer Teleport proof verification here */
        return true;
    }

    // Called by user if funds not received on destination chain
    function claimWithProof(bytes calldata proof, uint256 blockId, uint256 amount, address depositor) external {
        require(verifyProof(proof, blockId, amount, depositor), "Invalid proof");
        uint256 payout = (amount * 110) / 100; // 110% of deposited amount
        require(reserve >= payout, "Insufficient reserve");
        reserve -= payout;
        require(token.transfer(depositor, payout), "Token transfer failed");
        emit Claimed(depositor, amount, payout - amount);
    }
}
