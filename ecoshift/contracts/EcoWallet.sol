pragma solidity >=0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APIConsumer.sol";

//contract EcoWallet is APIConsumer, ERC721, Ownable{
contract EcoWallet is ERC721, Ownable{
    uint256 public tokenCounter;

    // GET this from https://bafkreia6cfsedzwyk2aclxzn47zssiexwfqjaz3fq7maivizp7xmlmdonm.ipfs.dweb.link/
    //address[] public charities;

    address[] public charities = [
    0x2c7e2252061A1DBEa274501Dc4c901E3fF80ef8B,
    0x76A28E228ee922DB91cE0952197Dc9029Aa44e65,
    0x55B86Ea5ff4bb1E674BCbBe098322C7dD3f294BE,
    0xC157f383DC5Fc9301CDB2FEb958Ba394EF79f6e5,
    0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A];

    mapping(uint8 => string) public tierToWalletURI;
    mapping(uint256 => uint256) private tokenIdToBalance;

    constructor (
            address _oracle,
            bytes32 _jobId,
            uint256 _fee,
            address _link
        ) 
        ERC721("EcoWallet", "ECO")
    {
        //int[5] memory data 
        //= [int(50), -63, 77, -28, 90];

        tokenCounter = 0;
        tierToWalletURI[1] = "URI1"; // .01 ETH
        tierToWalletURI[2] = "URI2"; // .1  ETH
        tierToWalletURI[3] = "URI3"; // .5  ETH
        tierToWalletURI[4] = "URI4"; //  1  ETH
        tierToWalletURI[5] = "URI5"; //  5  ETH
    }

    function tokenURI(uint256 tokenId) public view override (ERC721) returns (string memory){
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tierToWalletURI[ getTier(tokenId) ];
    }

    function getTier(uint256 tokenId) public view returns (uint8) {
        require(_exists(tokenId), "EcoWallet Tier: nonexistent token");
        
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
            tier = 5; 
        }
        return tier;
    }

    function createWallet() public onlyOwner{
        _safeMint(msg.sender, tokenCounter);
        tokenIdToBalance[tokenCounter]= 0;
        tokenCounter = tokenCounter+1;
    }

    // fund an EcoWallet
    function fund(uint256 tokenId) public payable {
        tokenIdToBalance[tokenId] += msg.value;
    }

    function pay(uint256 tokenId, address payable recipient) public payable{
        require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: You are not the owner");
        require(tokenIdToBalance[tokenId] >= msg.value, "EcoWallet: Insufficient funds");
        recipient.transfer(address(this).balance);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        //TODO
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
    }
}
