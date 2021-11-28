#!/usr/bin/env python3
from brownie import EcoWallet, APIConsumer, config, network
from scripts.utils import fund_with_link, get_account
from .deploy import deploy_ecowallet, deploy_api_consumer

def main():
    if len(EcoWallet) == 0:
        deploy_ecowallet()
    ecw = EcoWallet[-1]
    account = get_account()

    print(f"Requesting from {ecw.address}")
    tx = fund_with_link(
        ecw.address, 
        amount=config["networks"][network.show_active()]["fee"]
    )
    tx.wait(1)
    request_tx = ecw.requestData({"from": account})
    request_tx.wait(1)

    print(ecw.gotAddress())
    # str_response = api_contract.resp_str().lstrip('\x00')
    # if not str_response:
        # print("Data not found")
    # else:
        # print(str_response)
