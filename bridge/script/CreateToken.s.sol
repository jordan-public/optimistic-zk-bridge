// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "../src/vlayer/MockERC20.sol";

contract CreateToken is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        MockERC20 token = new MockERC20("Mock Token", "MTK");
        
        console.log("MockERC20 deployed at:", address(token));

        token.mint(
            msg.sender,
            100 * 10 ** 18 // Mint 100 tokens to the deployer
        );
        console.log("Deployer address:", msg.sender);
        console.log("Deployer token balance:", token.balanceOf(msg.sender));

        token.mint(
            vm.envAddress("RELAYER_ADDRESS"),
            10000 * 10 ** 18 // Mint 10,000 tokens to the relayer
        );
        console.log("Relayer address:", vm.envAddress("RELAYER_ADDRESS"));
        console.log("Relayer token balance:", token.balanceOf(vm.envAddress("RELAYER_ADDRESS")));

        vm.stopBroadcast();
    }
}
