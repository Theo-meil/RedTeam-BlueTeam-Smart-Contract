// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract VulnerableAccessControl {
    address public owner;
    mapping(address => bool) public admins;
    uint256 public treasuryBalance;

    event Initialized(address indexed owner);
    event AdminAdded(address indexed admin);
    event Withdrawn(address indexed to, uint256 amount);

    // VULNERABILITY (SWC-118): No guard — anyone can call this and overwrite the owner.
    // Fix: add require(owner == address(0), "already initialized")
    function initialize(address _owner) external {
        owner = _owner;
        emit Initialized(_owner);
    }

    // VULNERABILITY (SWC-115): tx.origin tracks the original wallet, not the direct caller.
    // A phishing contract can call withdrawFunds() on behalf of the real owner
    // because tx.origin is still the owner's address.
    // Fix: replace tx.origin with msg.sender
    modifier onlyOwnerViaTxOrigin() {
        require(tx.origin == owner, "not owner");
        _;
    }

    // VULNERABILITY (SWC-106): The if-block is empty — the modifier does nothing.
    // Every address passes this check, making addAdmin() open to anyone.
    // Fix: revert("not admin") inside the if-block
    modifier onlyAdminBroken() {
        if (admins[msg.sender] == false) {
            // missing: revert("not admin")
        }
        _;
    }

    // Unprotected in practice — onlyAdminBroken never reverts (see above).
    function addAdmin(address _admin) external onlyAdminBroken {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    // Safe — no access control needed for deposits.
    function depositTreasury() external payable {
        treasuryBalance += msg.value;
    }

    // Exposed to the tx.origin phishing attack via onlyOwnerViaTxOrigin.
    // An attacker's contract can drain the full treasury without touching the owner's key.
    function withdrawFunds(address payable _to, uint256 _amount) external onlyOwnerViaTxOrigin {
        require(_amount <= treasuryBalance, "insufficient treasury");
        treasuryBalance -= _amount;
        (bool ok,) = _to.call{value: _amount}("");
        require(ok, "transfer failed");
        emit Withdrawn(_to, _amount);
    }
}
