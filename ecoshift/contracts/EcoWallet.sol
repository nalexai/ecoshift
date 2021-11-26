pragma solidity >=0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./APIConsumer.sol";

/**
 * @title Factory contract for EcoWallet NFTs
 * Wallets enforce community values by incentivizing whitelisted transactions. 
 * For non-whitelisted transactions, a fixed percentage is distributed to charities. 
 *
 * @dev tokenIds are the ENS namehash of the human-readable wallet name, e.g. mywallet.eco
 * @dev makes Chainlink API call to update the whitelist (see APIConsumer.sol)
 */
contract EcoWallet is APIConsumer, ERC721, Ownable {
    uint256 public tokenCounter; // Number of tokens (NFTs) that have been minted
    address[] public charities; 

    mapping(uint8 => string) public tierToWalletURI;
    mapping(uint8 => uint8) public tierToCommunityFundShare;
    mapping(uint256 => uint256) private tokenIdToBalance;
    mapping(uint256 => uint256) private tokenIdToCommunityValue;
    mapping(address => bool) public whitelist; 

    /**
      @dev see the APIConsumer contract for Chainlink params
    */
    constructor(
        address _oracle,
        bytes32 _jobId,
        uint256 _fee,
        address _link
    ) 
    ERC721("EcoWallet", "ECO") 
    APIConsumer(_oracle, _jobId, _fee, _link)
    {
        tokenCounter = 0;
        tierToWalletURI[1] = "https://ipfs.io/ipfs/bafkreiaxj7ah6nxnsx7wt5nweg4qrca36evopbaxaxbtcpugvle2git27q"; 
        tierToWalletURI[2] = "https://ipfs.io/ipfs/bafkreigfk7xbomlnnfq4zssgnjsjwq6xsh42elmxmid7hjlhq42cjcy7fu"; 
        tierToWalletURI[3] = "https://ipfs.io/ipfs/bafkreifgfttc6xkirlm7nnqg55ffvbq7uuuw5yb6s4mfruyakvzu46dx2y"; 
        tierToWalletURI[4] = "https://ipfs.io/ipfs/bafkreibyqbka4t4hhpy7a4ogqfcuxzjlutk4uxsyl3fiyob6d6d63badlm"; 
        tierToWalletURI[5] = "https://ipfs.io/ipfs/bafkreifnget24ood6n5lf4if5u7jvwiv2bj5kp545khrookv7eec7d7pbm"; 

        // set community shares for each tier (in percentages)
        tierToCommunityFundShare[1] = 5; 
        tierToCommunityFundShare[2] = 4; 
        tierToCommunityFundShare[3] = 3; 
        tierToCommunityFundShare[4] = 2; 
        tierToCommunityFundShare[5] = 1; 

        charities = [
            0x2c7e2252061A1DBEa274501Dc4c901E3fF80ef8B,
            0x76A28E228ee922DB91cE0952197Dc9029Aa44e65,
            0x55B86Ea5ff4bb1E674BCbBe098322C7dD3f294BE,
            0xC157f383DC5Fc9301CDB2FEb958Ba394EF79f6e5,
            0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A
        ];

        for (uint256 i = 0; i < charities.length; i++) {
            whitelist[ charities[i] ] = true;
        }
    }

    /**
      Mints a new wallet
      @dev tokenId is the ENS namehash of the human-readable wallet name 
    */
    function createWallet(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
        tokenIdToBalance[tokenId] = 0;
        tokenCounter = tokenCounter + 1;
    }

    /** 
      @dev return ERC721 tokenURI for the wallet. 
      @dev dynamically updates based on wallet's tier
    */
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

    /// Get tier of wallet, which determines NFT image and community share 
    function getTier(uint256 tokenId) public view returns (uint8) {
        require(_exists(tokenId), "EcoWallet: tier query for nonexistent token");

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


    ///Pay a wallet
    function fund(uint256 tokenId) public payable {
        require( _exists(tokenId) );
        tokenIdToBalance[tokenId] += msg.value;
    }

    /** 
      Getter for wallet balance 
      @dev Only callable for owner or approved
    */
    function getBalance(uint256 tokenId) public view returns (uint256) {
        require( _exists(tokenId) );
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: You are not approved or the owner."
        );
        return tokenIdToBalance[tokenId]; 
    }

    ///Withdraw funds from a wallet. 
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

    /**
      Pays an external account with EcoWallet
      @dev only callable for owner or approved
    */
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

        // not sending to a whitelisted address, so decrease community value 
        if (tokenIdToCommunityValue[tokenId] > 0) {
            tokenIdToCommunityValue[tokenId] -= 1;
        }

        // calculate costs based on tier
        uint8 tier = getTier(tokenId);
        uint256 community_share = tierToCommunityFundShare[tier];
        uint256 community_amount = (msg.value * community_share) / 100;
        uint256 recipient_amount = msg.value - community_amount; 

        recipient.transfer(recipient_amount);

        // transfer money to charities
        uint256 charity_amount = community_amount / charities.length;
        for (uint256 i = 0; i < charities.length; i++) {
            payable(charities[i]).transfer(charity_amount);
        }
    }

    /// Check if address is in the whitelist
    function inWhitelist(address _addr) public view returns (bool) {
        return whitelist[_addr];
    }

    /**
       Add an address to the whitelist
       @dev this is for testing purposes; whitelist should community governed 
    */
    function addToWhitelist(address _addr) public onlyOwner {
        require(_addr != address(0));
        whitelist[_addr] = true; 
    }

    /**
      Add an address recieved from Chainlink API call
      @dev chainlink request must be already fulfilled (see APIConsumer.sol)
    */
    function addToWhitelistFromAPI() public onlyOwner {
        addToWhitelist(gotAddress);
    }
}
