import pytest
from brownie import EcoWallet, network, config
from scripts.utils import get_account, get_contract
from scripts.utils import LOCAL_BLOCKCHAIN_ENVIRONMENTS as LOCAL_CHAINS

@pytest.fixture
def charity_addresses():
    return ["0x2c7e2252061A1DBEa274501Dc4c901E3fF80ef8B",
            "0x76A28E228ee922DB91cE0952197Dc9029Aa44e65",
            "0x55B86Ea5ff4bb1E674BCbBe098322C7dD3f294BE",
            "0xC157f383DC5Fc9301CDB2FEb958Ba394EF79f6e5",
            "0x77fEb8B21ffe0D279791Af78eb07Ce452cf1a51A"]

@pytest.fixture
def deploy_ecowallet():
    # chainlink stuff doesn't matter for wallet test
    ecowallet = EcoWallet.deploy(
            get_contract("oracle").address, 
            0,
            1000000000000000000,
            get_contract("link_token").address,
            {"from": get_account()},
            publish_source=False)
    return ecowallet


def test_ecowallet_local(deploy_ecowallet):
    if network.show_active() not in LOCAL_CHAINS:
        pytest.skip()
    acct = get_account()
    ecowallet = deploy_ecowallet 

    # mint and fund a wallet
    ecowallet.createWallet({"from": acct})
    assert ecowallet.tokenCounter() == 1

    tokenId = 0
    amt = 10000000000
    ecowallet.fund(tokenId, {"from": acct, "value": amt})
    balance = EcoWallet[0].getBalance(tokenId, {"from": acct})

    assert balance == amt


