// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BridgeDestination} from "../src/BridgeDestination.sol";

contract BridgeDestinationScript is Script {
    BridgeDestination public counter;

    function setUp() public {}

    function run() public {
        vm.loadEnv("../vlayer/.env.relayer");
        vm.startBroadcast();

        address relayer = vm.envAddress("RELAYER_ADDRESS");
        counter = new BridgeDestination(address relayer);

        vm.stopBroadcast();
    }
}
