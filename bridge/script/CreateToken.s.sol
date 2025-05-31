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
            vm.envAddress("DEPLOYER_ADDRESS"),
            100 * 10 ** 18 // Mint 1 million tokens to the deployer
        );
        console.log("Deployer address:", vm.envAddress("DEPLOYER_ADDRESS"));
        console.log("Deployer balance:", token.balanceOf(vm.envAddress("DEPLOYER_ADDRESS")));

        token.mint(
            vm.envAddress("RELAYER_ADDRESS"),
            10000 * 10 ** 18 // Mint 1 million tokens to the relayer
        );
        console.log("Relayer address:", vm.envAddress("RELAYER_ADDRESS"));
        console.log("Relayer balance:", token.balanceOf(vm.envAddress("RELAYER_ADDRESS")));

        vm.stopBroadcast();
    }
}
