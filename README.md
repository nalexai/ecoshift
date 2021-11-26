# Ecoshift Wallet
![ecowallets](https://user-images.githubusercontent.com/48187500/143511469-b21b5f82-b739-44e1-ad56-ce07932d5d2d.png)

Ecoshift Crypto Wallets (**Ecowallets** for short) are wallets that have ethical rules built in.   

Ecowallets incentivize users to adhere to _community-defined values_ like environmentalism, while offsetting the negative externalities incurred by violating those values.  


## How It Works

An ecowallet is an [NFT](https://ethereum.org/en/nft/) with a unique `.eco` domain that the user recieves and makes payments with.   

Each ecowallet has a tier (1-5) that updates based on the user's contribution to the community. The Ecowallet smart contract tracks each wallet's contribution by maintaining a community-governed whitelist of addresses that align with the community's values. For transactions that don't align with community values, a fixed percentage is redistributed to a set of charities or non-profit organizations.  

Ecowallets also uses [Chainlink](https://chain.link/) oracles to update the community whitelist according to external data.  

## Usage

This project uses [brownie](https://github.com/eth-brownie/brownie) for testing and deploying, but the main contract [`EcoWallet.sol`](https://github.com/nalexai/ecoshift/blob/main/ecoshift/contracts/EcoWallet.sol) can be re-used on its own. 

### Deploy
```shell
# run tests and deploy to a chain
$ brownie test tests/
$ brownie run scripts/deploy.py
```

To use API requests, you need some LINK token (see the [Chainlink docs](https://docs.chain.link/docs/advanced-tutorial/) for more info)

### Wallet API
Ecowallets are identified by a human-readable name like `mywallet.eco`. Similar to the Ethereum Name Service, the numeric ID of the wallet is obtained from its [namehash](https://docs.ens.domains/contract-api-reference/name-processing). 
```python
# the tokenID for "mywallet.eco"
from ens.main import ENS
tokenID = ENS.namehash("mywallet.eco")
tokenID = int.from_bytes(tokenID, byteorder="big")

# create the wallet
from brownie import EcoWallet
ecw = EcoWallet[0]
ecw.createWallet(tokenID, {"from": YOUR_WALLET})

# fund the wallet and pay someone
ecw.fund(tokenID, {"from": YOUR_WALLET, "value": SOME_WEI}) 
ecw.pay(tokenID, RECIPIENT, {"from": YOUR_WALLET, "value": SOME_WEI}) 

# check the wallet's balance and tier
ecw.getTier(tokenID, {"from": YOUR_WALLET})
ecw.getBalance(tokenID, {"from": YOUR WALLET})

# withdraw from the wallet
ecw.withdraw(tokenID, SOME_WEI, {"from": YOUR_WALLET})

```
