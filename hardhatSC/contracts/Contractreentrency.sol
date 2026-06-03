contract EtherVault {
    mapping(address => uint256) public balances;

    // ETH
    function deposit() public payable {
        require(msg.value > 0, "Il faut envoyer des ETH");
        balances[msg.sender] += msg.value;
    }

    // Faille de Réentrance
    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Solde insuffisant");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Echec du transfert");

      
        balances[msg.sender] = 0;
    }

    //  voir le solde
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}