#!/usr/bin/env python3
from brownie import EcoWallet, config, network
from scripts.utils import fund_with_link, get_account

def main():
   ecw = EcoWallet[-1]
   print("Reading data from {}".format(ecw.address))
   print(ecw.gotAddress())
