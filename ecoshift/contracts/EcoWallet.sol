pragma solidity >=0.8.7;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APIConsumer.sol";

contract EcoWallet is APIConsumer, PaymentSplitter, ERC721, Ownable{
    uint256 public tokenCounter;

    mapping(uint8 => string) public tierToWalletURI;
    mapping(uint256 => address) public tokenIdToOwner;
    mapping(uint256 => uint256) public tokenIdToBalance;

    constructor (
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
        tierToWalletURI[1] = "URI1"; // grunt tier environmental activist   .01 ETH
        tierToWalletURI[2] = "URI2"; // warrior tier vegan recyclist        .1  ETH
        tierToWalletURI[3] = "URI3"; // commander tier activist mobilizer   .5  ETH
        tierToWalletURI[4] = "URI4"; // emperor tier global warming sage    1   ETH
        tierToWalletURI[5] = "URI5"; // God tier woke climate legend        5   ETH
    }

    function tokenURI(uint256 tokenId) public view override (ERC721) returns (string memory){
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tierToWalletURI[ getTier(tokenId)];
    }

    function getTier(uint256 tokenId) public view returns (uint8) {
        require(tokenIdToOwner[tokenId] != address(0x0), "EcoWallet Tier: nonexistent token");
        
        // determine the tiers
        // 1 ETH = 1000000000000000000 wei
        uint8 tier;
        if (tokenIdToBalance[tokenId] < 10000000000000000){
            tier = 1;
        } else if (tokenIdToBalance[tokenId] < 100000000000000000){
            tier = 2;
        } else if (tokenIdToBalance[tokenId] < 500000000000000000){
            tier = 3;
        } else if (tokenIdToBalance[tokenId] < 1000000000000000000){
            tier = 4;
        } else if (tokenIdToBalance[tokenId] < 5000000000000000000){
            tier = 5; //UR A GODD
        }
        return tier;
    }

    function createWallet() public onlyOwner{
        _safeMint(msg.sender, tokenCounter);
        tokenIdToOwner[tokenCounter] = msg.sender;
        tokenIdToBalance[tokenCounter]= 0;
        tokenCounter = tokenCounter+1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        //TODO
    }
}