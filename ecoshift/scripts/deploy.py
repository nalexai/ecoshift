#!/usr/bin/env python3
from brownie import APIConsumer, config, network
from web3 import Web3
from scripts.utils import get_account, get_contract, JOB_IDS

def deploy_api_consumer():
    #jobId = config["networks"][network.show_active()]["jobId"]

    #jobId = JOB_IDS[network.show_active()]["GET"]["uint256"]
    jobId = "d5270d1c311941d0b08bead21fea7747"

    fee = config["networks"][network.show_active()]["fee"]
    account = get_account()
    oracle = "0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8" #get_contract("oracle").address
    link_token = get_contract("link_token").address
    api_consumer = APIConsumer.deploy(
            oracle,
            Web3.toHex(text=jobId),
            fee,
            link_token,
            {"from": account},
            publish_source=False  # config["networks"][network.show_active()].get("verify", False),
    )
    print(f"API Consumer deployed to {api_consumer.address}")
    return api_consumer

def main():
    deploy_api_consumer()
