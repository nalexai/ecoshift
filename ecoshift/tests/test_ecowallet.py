import pytest
from brownie import EcoWallet, network, config, accounts
from scripts.utils import get_account, get_contract
from scripts.utils import LOCAL_BLOCKCHAIN_ENVIRONMENTS as LOCAL_CHAINS
from random import randint
import web3

# NOTE: charity address start with 0 balance
@pytest.fixture
def get_charities():
    charity_addr = {
            "0x2c7e2252061A1DBEa274501Dc4c901E3fF80ef8B",
            "0x76A28E228ee922DB91cE0952197Dc9029Aa44e65",
            "0x55B86Ea5ff4bb1E674BCbBe098322C7dD3f294BE",
            "0xC157f383DC5Fc9301CDB2FEb958Ba394EF79f6e5",
            "0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A"}
    charities = [acct for acct in accounts if acct.address in charity_addr]
    return charities

@pytest.fixture
def deploy_ecowallet():
    # chainlink stuff doesn't matter for wallet test
    if len(EcoWallet) > 0:
        return EcoWallet[-1] 

    ecowallet = EcoWallet.deploy(
            get_contract("oracle").address, 
            0,
            1000000000000000000,
            get_contract("link_token").address,
            {"from": get_account()},
            publish_source=False)
    return ecowallet

# wallet with a random name
@pytest.fixture
def test_walletID():
    wallet_name = "testwallet" + str(randint(0,2**12))
    #name hash tokenID
    return int.from_bytes(
        web3.Web3.keccak(text=wallet_name), 
        byteorder='big') 


def test_ecowallet_basic(deploy_ecowallet, test_walletID):
    if network.show_active() not in LOCAL_CHAINS:
        pytest.skip()
    acct = get_account()
    ecowallet = deploy_ecowallet 
    tokenId = test_walletID

    # mint and fund a wallet
    ecowallet.createWallet(tokenId, {"from": acct})
    assert ecowallet.tokenCounter() == 1

    amt = 10000000000
    ecowallet.fund(tokenId, {"from": acct, "value": amt})
    balance = EcoWallet[0].getBalance(tokenId, {"from": acct})
    assert balance == amt

def test_ecowallet_split(deploy_ecowallet, test_walletID, get_charities):
    if network.show_active() not in LOCAL_CHAINS:
        pytest.skip()
    acct = get_account()
    recipient = get_account(index=1)

    tokenId = test_walletID
    amt = 10000000000
    default_balance = recipient.balance()

    ecowallet = deploy_ecowallet
    ecowallet.createWallet(tokenId, {"from": acct})
    ecowallet.fund(tokenId, {"from": acct, "value": amt})
    ecowallet.pay(tokenId, recipient, {"from": acct, "value": amt })

    # 5% given to charities 
    assert recipient.balance() == default_balance + (amt * 95)//100

    community_share = amt - (amt * 95)//100 
    charities = get_charities 
    for charity in charities:
        assert charity.balance() == community_share//len(charities) 


def test_ecowallet_whitelist(deploy_ecowallet, test_walletID, get_charities):
    acct = get_account()
    tokenId = test_walletID
    amt = 700000000000

    charities = get_charities
    charity = charities[0]
    default_balance = charity.balance()

    ecowallet = deploy_ecowallet
    ecowallet.createWallet(tokenId, {"from": acct})
    ecowallet.fund(tokenId, {"from": acct, "value": amt})

    # charity is whitelisted by default
    for _ in range(7):
        ecowallet.pay(tokenId, charity.address, {"from": acct, "value": amt//7})
    
    assert charity.balance() == amt + default_balance 

    # should be tier 3 now
    assert EcoWallet[0].getTier(tokenId) == 3
