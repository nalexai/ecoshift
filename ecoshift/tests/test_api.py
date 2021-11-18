import pytest
from brownie import APIConsumer, network, config
from brownie.convert import to_string, to_int, to_bytes
import time
from scripts.utils import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account, get_contract

@pytest.fixture
def deploy_api_contract(get_job_id, chainlink_fee):
    api_consumer = APIConsumer.deploy(
        get_contract("oracle").address,
        get_job_id,
        chainlink_fee,
        get_contract("link_token").address,
        {"from": get_account()},
    )

    return api_consumer

def test_api_request_local(deploy_api_contract, chainlink_fee, get_data):
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    acct = get_account()
    api_contract = deploy_api_contract
    get_contract("link_token").transfer(
        api_contract,
        2 * chainlink_fee,
        {"from": acct},
    )
    txn_hash = api_contract.requestJsonAPI( {"from": acct} )
    requestId = txn_hash.events["ChainlinkRequested"]["id"]

    get_contract("oracle").fulfillOracleRequest(
        requestId, 
        get_data, 
        {"from": acct},
    )

    # read padded string response (32 bytes)
    str_response = api_contract.resp_str().lstrip('\x00')
    print(api_contract.resp_str())
    assert str_response == "testing 123"

    # print(api_contract.volume())
    # assert api_contract.volume() > 0

def test_send_api_request_testnet(deploy_api_contract, chainlink_fee):
    if network.show_active() not in ["kovan", "rinkeby", "mainnet"]:
        pytest.skip("Only for local testing")
    api_contract = deploy_api_contract
    get_contract("link_token").transfer(
        api_contract.address, chainlink_fee * 2, {"from": get_account()}
    )
    # Act
    transaction = api_contract.requestVolumeData({"from": get_account()})
    # Assert
    assert transaction is not None
    transaction.wait(2)
    time.sleep(35)
    assert isinstance(api_contract.volume(), int)
    assert api_contract.volume() > 0

@pytest.fixture
def get_job_id():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return 0
    if network.show_active() in config["networks"]:
        return config["networks"][network.show_active()]["jobId"]
    else:
        pytest.skip("Invalid network/link token specified")

@pytest.fixture
def get_data():
    return bytes("testing 123",'utf-8')

@pytest.fixture
def chainlink_fee():
        return 1000000000000000000