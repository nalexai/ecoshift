pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/payment/PaymentSplitter.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./APIConsumer.sol"

contract EcoWallet is APIConsumer, PaymentSplitter, ERC721, Ownable{
    uint256 public tokenCounter;

    mapping(string => string) public tierToWalletURI;

    constructor public (
            address[] memory _payees, 
            uint256[] memory _shares,
            address _oracle,
            bytes32 _jobId,
            uint256 _fee,
            address _link
        ) 
        PaymentSplitter(_payees, _shares)
        APIConsumer(_oracle, _jobId, _fee, _link)
        ERC721("EcoWallet", "ECO")
    {
        tokenCounter = 0;
    }

    function tokenURI(uint256 tokenId) public view override (ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        //TODO
        return "THE URI"
    }

    function createWallet() public onlyOwner{
        _safeMint(msg.sender, tokenCounter)
        tokenCounter = tokenCounter+1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        //TODO
    }
}


