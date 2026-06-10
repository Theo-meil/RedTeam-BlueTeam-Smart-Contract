// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "amount=0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "send failed");

        balances[msg.sender] = 0;
        emit Withdrawn(msg.sender, amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
