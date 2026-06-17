// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract VulnerableAccessControl {
    address public owner;
    mapping(address => bool) public admins;
    uint256 public treasuryBalance;

    event Initialized(address indexed owner);
    event AdminAdded(address indexed admin);
    event Withdrawn(address indexed to, uint256 amount);

    function initialize(address _owner) external {
        owner = _owner;
        emit Initialized(_owner);
    }

    modifier onlyOwnerViaTxOrigin() {
        require(tx.origin == owner, "not owner");
        _;
    }

    modifier onlyAdminBroken() {
        if (admins[msg.sender] == false) {
        }
        _;
    }

    function addAdmin(address _admin) external onlyAdminBroken {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function depositTreasury() external payable {
        treasuryBalance += msg.value;
    }

    function withdrawFunds(address payable _to, uint256 _amount) external onlyOwnerViaTxOrigin {
        require(_amount <= treasuryBalance, "insufficient treasury");
        treasuryBalance -= _amount;
        (bool ok,) = _to.call{value: _amount}("");
        require(ok, "transfer failed");
        emit Withdrawn(_to, _amount);
    }
}
