// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BridgeDestination} from "../src/BridgeDestination.sol";

contract Deploy is Script {
    BridgeDestination public bridgeDestination;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        if (vm.envAddress("RELAYER_ADDRESS").balance < 100 ether) {
            payable(vm.envAddress("RELAYER_ADDRESS")).transfer(
                100 ether
            );
        }

        if (vm.envAddress("RELAYER_ADDRESS").balance < 100 ether) {
            payable(vm.envAddress("RELAYER_ADDRESS")).transfer(
                100 ether
            );
        }

        // Print the balanve of the deployer (currently the script runner)
        console.log("Deployer address:", vm.envAddress("DEPLOYER_ADDRESS"));
        console.log("Deployer balance:", vm.envAddress("DEPLOYER_ADDRESS").balance);
        console.log("Relayer address:", vm.envAddress("RELAYER_ADDRESS"));
        console.log("Relayer balance:", vm.envAddress("RELAYER_ADDRESS").balance);

        address relayer = vm.envAddress("RELAYER_ADDRESS");
        bridgeDestination = new BridgeDestination(relayer, vm.envAddress("SOURCE_ERC20_ADDRESS"), vm.envAddress("DESTINATION_ERC20_ADDRESS"));

        console.log("BridgeDestination deployed at:", address(bridgeDestination));

        vm.stopBroadcast();
    }
}
