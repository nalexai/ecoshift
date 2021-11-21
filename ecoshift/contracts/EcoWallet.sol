pragma solidity >=0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APIConsumer.sol";

/**
 * EcoWallet determines how funds are spent across a community
 */

contract EcoWallet is ERC721, Ownable {
    uint256 public tokenCounter; // Keeps track of the number of tokens (NFTs) that have been minted

    // TODO: Get charities from https://bafkreia6cfsedzwyk2aclxzn47zssiexwfqjaz3fq7maivizp7xmlmdonm.ipfs.dweb.link/
    //address[] public charities;
    // TODO: seperate community fund contract that determines splits between each charity which is based on community vote
    // TODO: ability to create a contract and fund it and give ownership to another person
    //address payable[] public charities2 = [
    //    0x2c7e2252061A1DBEa274501Dc4c901E3fF80ef8B
    //];

    address[] public charities; // charities that will be paid if money isn't sent to a whitelist address

    // TODO: Make a token class with holds the address, balance, and 'goodness' value

    mapping(uint8 => string) public tierToWalletURI;
    mapping(uint8 => uint8) public tierToCommunityFundShare;
    mapping(uint256 => address) private tokenIdToAddress; //address of owner of the token ID. TODO: If someone can give their token to someone else should  we be tracking this?
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

        // Example of making an array
        //address[2] memory aa = [
        //    0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A,
        //    0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A
        //];
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
        require(_exists(tokenId), "EcoWallet Tier: nonexistent token");

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
        } else if (tokenIdToCommunityValue[tokenId] < 50) {
            tier = 5;
            // TODO: If in tier 5 then you should get added to the whitelist, how do we ge the address and which address should we be adding
        }
        return tier;
    }

    // TODO: Should this function be an onlyOwnder contract? Desn't this mean the owner of thsi contract also owns all the NFTs?
    function createWallet() public onlyOwner {
        _safeMint(msg.sender, tokenCounter);
        tokenIdToBalance[tokenCounter] = 0;
        tokenCounter = tokenCounter + 1;
    }

    // fund an EcoWallet
    function fund(uint256 tokenId) public payable {
        tokenIdToBalance[tokenId] += msg.value;
    }

    // withdraw funds from an EcoWallet. This should only be to the owner of the NFT and shouldn't have any charges
    function withdraw(uint256 tokenId, address payable owner) public payable {
        // TODO: check if address is nft owner
        owner.transfer(tokenIdToBalance[tokenId]);
    }

    // pays an account with EcoWallet
    function pay(uint256 tokenId, address payable recipient) public payable {
        //check if address is in the ecowallet
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: You are not approved or the owner."
        );
        //check account has enough balance
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

        // TODO: if sending to another ecowallet then don't charge (use tokenIDto Addrress mapping, which should also be used for withdrawals)

        // as not sending to a whitelist address or to another ecowallet then take away from goodness
        tokenIdToCommunityValue[tokenId] -= 1;

        // calculate costs based on tier
        uint8 tier = getTier(tokenId);
        // TODO: Use SafeMath when dealing with money
        uint256 community_share = tierToCommunityFundShare[tier];
        uint256 recipient_amount = msg.value * (100 / community_share);
        uint256 community_amount = msg.value * (100 / community_share);

        // transfer money to recipient
        recipient.transfer(recipient_amount);

        // transfer money to charities
        for (uint256 i = 0; i < charities.length; i++) {
            // TODO: Casting to payable below but this could be done during array initilization
            payable(charities[i]).transfer(community_amount / charities.length);
        }
    }

    function inWhitelist(address _add) public returns (bool) {
        return whitelist[_add];
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        //TODO
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
    }
}
