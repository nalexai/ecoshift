pragma solidity >=0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APIConsumer.sol";

/**
 * EcoWallet determines how funds are spent across a community
 */

contract EcoWallet is ERC721, Ownable {
    uint256 public tokenCounter; // Keeps track of the number of tokens (NFTs) that have been minted

    // TODO: Get charities from https://bafkreia6cfsedzwyk2aclxzn47zssiexwfqjaz3fq7maivizp7xmlmdonm.ipfs.dweb.link/
    // TODO: make tokenId the hash of a human readable name, similar to ENS
    // TODO: seperate community fund contract that determines splits between each charity which is based on community vote
    // TODO: ability to create a contract and fund it and give ownership to another person

    address[] public charities; // charities that will be paid if money isn't sent to a whitelist address

    // TODO: Make a token class with holds the address, balance, and 'goodness' value

    mapping(uint8 => string) public tierToWalletURI;
    mapping(uint8 => uint8) public tierToCommunityFundShare;
    mapping(uint256 => uint256) private tokenIdToBalance;
    mapping(uint256 => uint256) private tokenIdToCommunityValue;
    mapping(address => bool) public whitelist; //mapping of whitelist addresses, lists arent good because large lists use lots of gas to run through

    constructor(
        address _oracle,
        bytes32 _jobId,
        uint256 _fee,
        address _link
    ) ERC721("EcoWallet", "ECO") {
        tokenCounter = 0;
        // set tier URIs
        tierToWalletURI[1] = "URI1"; // .01 ETH
        tierToWalletURI[2] = "URI2"; // .1  ETH
        tierToWalletURI[3] = "URI3"; // .5  ETH
        tierToWalletURI[4] = "URI4"; //  1  ETH
        tierToWalletURI[5] = "URI5"; //  5  ETH

        // set tier community amounts
        tierToCommunityFundShare[1] = 5; // 5%
        tierToCommunityFundShare[2] = 4; // 4%
        tierToCommunityFundShare[3] = 3; // 3%
        tierToCommunityFundShare[4] = 2; // 2%
        tierToCommunityFundShare[5] = 1; // 1%

        charities = [
            0x2c7e2252061A1DBEa274501Dc4c901E3fF80ef8B,
            0x76A28E228ee922DB91cE0952197Dc9029Aa44e65,
            0x55B86Ea5ff4bb1E674BCbBe098322C7dD3f294BE,
            0xC157f383DC5Fc9301CDB2FEb958Ba394EF79f6e5,
            0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A
        ];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return tierToWalletURI[getTier(tokenId)];
    }

    // determines tier of ecowallet which determines their nft image and
    // charge costs
    function getTier(uint256 tokenId) public view returns (uint8) {
        require(_exists(tokenId), "EcoWallet: tier query for nonexistent token");

        // determine the tiers
        // 1 ETH = 1000000000000000000 wei
        uint8 tier;
        if (tokenIdToCommunityValue[tokenId] < 1) {
            tier = 1;
        } else if (tokenIdToCommunityValue[tokenId] < 5) {
            tier = 2;
        } else if (tokenIdToCommunityValue[tokenId] < 10) {
            tier = 3;
        } else if (tokenIdToCommunityValue[tokenId] < 20) {
            tier = 4;
        } else {
            tier = 5;
        }
        return tier;
    }

    function createWallet() public {
        _safeMint(msg.sender, tokenCounter);
        tokenIdToBalance[tokenCounter] = 0;
        tokenCounter = tokenCounter + 1;
    }

    // fund an EcoWallet
    function fund(uint256 tokenId) public payable {
        require( _exists(tokenId) );
        tokenIdToBalance[tokenId] += msg.value;
    }

    // Withdraw funds from an EcoWallet. 
    // This should only be to the owner of the NFT and shouldn't have any charges
    function withdraw(uint256 tokenId, uint256 amount) public payable {
        require( _exists(tokenId) );
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: You are not approved or the owner."
        );
        require(
            tokenIdToBalance[tokenId] >= msg.value,
            "EcoWallet: Insufficient funds"
        );
        payable(msg.sender).transfer( amount );
        tokenIdToBalance[tokenId] -= amount;
    }

    // pays an account with EcoWallet
    function pay(uint256 tokenId, address payable recipient) public payable {
        require( _exists(tokenId) );
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: You are not approved or the owner."
        );
        require(
            tokenIdToBalance[tokenId] >= msg.value,
            "EcoWallet: Insufficient funds."
        );

        // check if address is in the whitelist
        bool whitelistAddress = inWhitelist(recipient);
        if (whitelistAddress) {
            recipient.transfer(msg.value);
            tokenIdToCommunityValue[tokenId] += 1;
            return;
        }

        // as not sending to a whitelist address or to another ecowallet then take away from goodness
        if (tokenIdToCommunityValue[tokenId] > 0) {
            tokenIdToCommunityValue[tokenId] -= 1;
        }

        // calculate costs based on tier
        uint8 tier = getTier(tokenId);
        uint256 community_share = tierToCommunityFundShare[tier];
        uint256 community_amount = (msg.value * community_share) / 100;
        uint256 recipient_amount = msg.value - community_amount; 

        // transfer money to recipient
        recipient.transfer(recipient_amount);

        // transfer money to charities
        uint256 charity_amount = community_amount / charities.length;
        for (uint256 i = 0; i < charities.length; i++) {
            // TODO: Casting to payable below but this could be done during array initilization
            // TODO: remainder isn't used, but this is probably neglible 
            payable(charities[i]).transfer(charity_amount);
        }
    }

    function inWhitelist(address _add) public returns (bool) {
        return whitelist[_add];
    }
}
