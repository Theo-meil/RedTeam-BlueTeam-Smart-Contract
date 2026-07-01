// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract VulnerableRewardSystem {
    mapping(address => uint256) public stakes;
    mapping(address => bool) public hasClaimed;

    uint256 public constant MINIMUM_STAKE = 1 ether;
    uint256 public constant REWARD_AMOUNT = 0.2 ether;

    event Staked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardPoolFunded(address indexed from, uint256 amount);

    // Users stake ETH to become eligible for a reward.
    function stake() external payable {
        require(msg.value > 0, "stake required");
        stakes[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    // Anyone can fund the contract so rewards can be paid.
    function fundRewardPool() external payable {
        require(msg.value > 0, "funding required");
        emit RewardPoolFunded(msg.sender, msg.value);
    }

    function claimReward() external {
        // LOGIC FLAW 1: This condition uses >= correctly for eligibility,
        // but the function forgets to enforce one-time claiming.
        require(stakes[msg.sender] >= MINIMUM_STAKE, "stake too low");

        // LOGIC FLAW 2: The contract defines hasClaimed but never uses it.
        // Missing checks:
        // require(!hasClaimed[msg.sender], "already claimed");
        // hasClaimed[msg.sender] = true;
        require(address(this).balance >= REWARD_AMOUNT, "insufficient reward pool");

        payable(msg.sender).transfer(REWARD_AMOUNT);
        emit RewardClaimed(msg.sender, REWARD_AMOUNT);
    }
}
