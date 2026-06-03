pragma solidity ^0.8.20;

contract AdminVault {
    address public owner;
    mapping(address => uint256) public balances;
    bool public isVaultPaused;

    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Erreur : Tu n'es pas l'owner !");
        _;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // ==========================================
    // FAILLE 1 : La fonction d'initialisation fantôme
    // ==========================================
    // Souvent oubliée dans les contrats modulaires ou proxies. 
    // N'importe qui peut l'appeler pour réinitialiser l'owner à son profit.
    function initializeVault(address _newOwner) public {
        owner = _newOwner;
    }

    // ==========================================
    // FAILLE 2 : L'oubli de modificateur (Le grand classique)
    // ==========================================
    // Le développeur a créé le modifier 'onlyOwner', mais a tout simplement
    // oublié de l'écrire dans la signature de cette fonction ultra-critique.
    function emergencyWithdrawAll() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}