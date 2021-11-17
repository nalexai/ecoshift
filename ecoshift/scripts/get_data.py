#!/usr/bin/env python3
from brownie import APIConsumer, config, network
from scripts.utils import fund_with_link, get_account

def main():
   api_contract = APIConsumer[-1]
   print("Reading data from {}".format(api_contract.address))
   print(api_contract.volume())
   print(api_contract.oracle())
   print(api_contract.jobId())
