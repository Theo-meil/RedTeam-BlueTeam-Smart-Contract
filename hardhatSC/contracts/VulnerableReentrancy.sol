// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * #title VulnerableReentrancy
 * #notice Demonstrates a reentrancy vulnerability.
 * inspired by Alchini's fabric-vuln-benchmarks and consensysdiligence.github.io.
 *      The vulnerability: state (balances) is updated AFTER the external call,
 *      allowing a malicious contract to re-enter withdraw() before balance is zeroed.
 *
 * VULNERABILITY: Classic reentrancy 
 * ATTACK VECTOR: Malicious fallback() calls withdraw() again before balance[msg.sender] = 0
 * SEVERITY: Critical — full drain of contract funds possible
 */
contract VulnerableReentrancy {

    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    /// #notice Deposit ETH into the contract
    function deposit() external payable {
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// #notice Withdraw all ETH - VULNERABLE: external call before state update
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // VULNERABILITY: ETH is sent before the balance is zeroed.
        // A malicious contract's fallback() can call withdraw() again here.
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // State update happens too late - reentrancy already exploited above
        balances[msg.sender] = 0;

        emit Withdrawn(msg.sender, amount);
    }

    /// #notice Get contract ETH balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}