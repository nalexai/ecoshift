#!/usr/bin/env python3
from brownie import APIConsumer, config, network
from scripts.utils import fund_with_link, get_account
from .deploy import deploy_api_consumer

def main():
    if len(APIConsumer) == 0:
        deploy_api_consumer()
    api_contract = APIConsumer[-1]
    account = get_account()

    print(f"Requesting from {api_contract.address}")
    tx = fund_with_link(
        api_contract.address, 
        amount=config["networks"][network.show_active()]["fee"]
    )
    tx.wait(1)
    request_tx = api_contract.requestVolumeData({"from": account})
    request_tx.wait(1)

    print(api_contract.volume())
    # str_response = api_contract.resp_str().lstrip('\x00')
    # if not str_response:
        # print("Data not found")
    # else:
        # print(str_response)
