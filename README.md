[This project, (Acrozz: OptZKBridge)](https://ethglobal.com/showcase/acrozz-optzkbridge-tgpfi) won the following prizes at the [ETHGlobal Prague 2025](https://ethglobal.com/events/prague) hackathon:

🏆 [vlayer - Best use of Time Travel OR Teleport](https://ethglobal.com/showcase/acrozz-optzkbridge-tgpfi)

🏆 [Rootstock - Freestyle Track 1st place](https://ethglobal.com/showcase/acrozz-optzkbridge-tgpfi)

# Optimistic ZK Bridge

The demo and video are [here](./demo/README.md)

## Abstract

This is a prototype of a new kind of bridge, which currently works for asset transfers across Ethereum L1 and L2s, and in the future across
other different EVMs and other blockchains, pending implementation of the dependent technologies.

This bridge is the least expensive, the fastest and the safest of all bridges. Such hard claim is obvious from its implementation:
- the assets transferred in a centralized manner achieving unprecedented speed, and the cost of a single ERC-20 transfer, yet economic incentive/disincentive optimistically keeps the bridge operator(s) honest,
- the extremely unlikely case of misbehavior of the bridge, whether intentionally or not, can be detected by the interested party which can trigger a sk proof of misbehavior, which verification would result in automatic punishment for delay and/or slashing for transfer failure.

## Introduction

The function of a bridge is to transfer messages, notably assets across different blockchains. There are several different bridges that rely on technologies/operations that have inherent pros and cons. Let us consider those, arguably:

|            | Centralized | Consensus | Multisig | Multiparty Computation | Zero Knowledge |
|------------|-------------|-----------|----------| --- | --- |
| **Speed**      | High 👍    | Low 👎  | Medium | Low 👎 | Low 👎 |
| **Security**     | Low 👎    | Medium   | Medium | High 👍 | High 👍  |
| **Cost**       | Low 👍     | High 👎  | Medium     | High 👎 | High 👎 |



Using the above we can classify different bridges, for example:

***Wormhole***: works with multisig of validators and we can consider it as medium speed, medium security, and high cost. Note that the attack on 2/3 of the validator keys is the reason for the medium security classification:

![wormhole](./docs/wormhole.png)

***LayerZero***: works with consensus based oracle plus relayers that move Merkle Proofs across blockchains. Because of the consensus based oracles, we can consider this bridge low speed, medium security and high cost:

![layer0](./docs/layer0.png)

***Across***: works with centralized transfers and claims of correctness to an optimistic oracle (UMA). In the mist likely case, bundles of claims are relative low cost. In the very unlikely case of misbehavior,
a costly dispute and voting process is triggered. In addition, the claims of correctness are bundled for multiple transactions to save on cost, somewhat sacrificing speed. This would be considered high speed, medium security and low cost. Because of this low cost, the 1inch aggregator often puts this bridge first in the preference list,
although some competition has appeared lately:

![across](./docs/across.png)

As our goal is to improve on speed, security and cost, we build on the idea of Across, but replace the less favorable aspects with
improved technologies.

***ZK bridges*** (fictitious): A ZK bridge would create a proof on one blockchain that the assets were deposited, take the proof to the recipient blockchain, verify it and deposit the counter-value there. This would be safe but slow and expensive. *This solution would be churning
on unnecessary proofs even when the transfer behaves as expected.*
It would be nice to act only upon misbehavior, and that's what we 
shall do.

## Solution

The idea of centralized transfers in Across is great. It gives it 
great speed and low cost. Yet security is imposed by the UMA optimistic oracle. 

### What if

What if we can keep the optimistic expectation of good behavior in
Across, but use ZK only when misbehavior is detected in order to rectify it.

![imporove](./docs/improve.png)

With this replacement, we would not even need to make assertions of
correct behavior - this can be detected by the dissatisfied participant or one or a multitude of watchguard processes. Nice - this eliminates the assertion expenses. 

![solution](./docs/acrozz.png)

The resulting solution gains on all fonts:
- It is at least as fast as Across, as an off-chain process(es) is performing the transfers not wasting time on assertions (even if bundled), in addition to the transfers.
- It is most inexpensive. The only cost most of the time is the
gas cost of the asset transfers. There is no other on-chain operation. 
- It is the most secure, as in the unlikely misbehavior, the on-chain
remediation is triggered by the on-chain verification of the ZK proof
of misbehavior.

## Economic Incentive

The bridge (Relayer) shall charge a nominal fee for the transfer. Part of that fee would go to the protocol.

If the transfer does not occur, the Relayer should be slashed. This means that
a forceful fund transfer from the Relayer's committed reserves would be automatically transferred to the user, in addition to the slashing fee that would be shared between the user as damages and the protocol as profit.

In addition, to improve on speed, we would punish the bridge operator(s) for delays depending on the delay of transfer. Finally, if the time limit is reached, a final slashing would occur as well. All this
is governed by a single ZK proof:

![delaypunishment](./docs/delaypunishment.png)

### Vlayer Incentive for Hope of Never to be Used

Part of the protocol fees would be distributed to Vlayer. The purpose of this is to make sure Vlayer is compensated for operating their network even though
they are hopefully never used.

### Not dealt with

We have omitted the details of rebalancing of the assets, but this is not something relevant to the properties of our bridge. The assets
that need rebalancing between blockchains are property of the bridge
operator(s) and we let them deal with this issue. 

Yet, bridges that operate by locking hard assets on the input blockchain and minting equal amount of equivalent assets on the other side, have been vulnerable to attacks, notably the Wormhole hack. We find dealing with hard assets on both sides safer, as done in Across.

## Implementation

The implementation uses Vlayer, specifically its Teleport feature. This creates a proof that on the input blockchain the asset was deposited. Then,
on the destination blockchain the proof is verified, the balance after
the desired number of blocks was not deposited and if so, the Relayer is punished.

The code is written in solidity and JavaScript/TypeScript.

## User Interface

There is no need for a web front end. Each pair of input/output assets corresponds to a deployed contract, which can be displayed to the user 
as a destination address / QR code for deposit of input funds. The user can send
the funds to the address shown in the QR code, using any wallet, preferably
on a mobile device. As soon as the funds are received, the destination funds
should appear on the same wallet address, but on the destination blockchain.

If the funds do not arrive timely on the destination chain the affected user can
initiate punishment or slashing after the deadline:
```
complain <bridge contract address> <user address>
```

Shortly, this is how the user interface looks:

Bridge:

From: Ethereum

To: Optimism

Source token: 0x851356ae760d987E095750cCeb3bC6014560891C

Destination token: 0x1D55838a9EC169488D360783D65e6CD985007b72

![qrsample](./docs/qrsample.png)
Deposit address: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8


## Future Work

General messages can be transferred, not just assets. As it is hard to determine the value of such messages, a reserve or even insurance can be provided, up to a pre-specified cap of value. This would give the message owners a limit on the potential loss of recovery, but make the generic message passing feasible.

If the bridge needs to use lock-and-mint schema instead of hard assets on both sides, this can also be achieved by imposing limits
on the transfer value (per given time period), by the bridge operators.
