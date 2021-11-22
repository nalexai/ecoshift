#!/usr/bin/env python3
import requests
import json
import os 
import sys
from datetime import datetime
from dotenv import load_dotenv
import argparse

parser = argparse.ArgumentParser(description="script to use nft.storage API")
parser.add_argument("command", choices=("upload", "list"))

load_dotenv()
API_KEY = os.getenv("NFTSTORAGE_KEY")
HEADER = {"Authorization": f"Bearer {API_KEY}"}

def green(string):
    return "\033[32m"+string+"\033[0m"

def CID_to_URL(cid):
    return f"https://ipfs.io/ipfs/{cid}"

def list():
    resp = requests.get("http://api.nft.storage/",headers=HEADER)
    if resp.status_code > 299:
        raise RuntimeError(f"API call failed: {resp.json()['error']['message']}")
    data = resp.json()

    print(f"=================================== UPLOADS ====================================")
    for upload in data["value"]:
        url = CID_to_URL(upload["cid"])
        timestamp = datetime.fromisoformat(upload["created"])
        timefmt = timestamp.strftime("%m-%d-%y %H:%M:%S")

        print(f"{green(url)}\t{timefmt}")

def upload():
    parser = argparse.ArgumentParser(description="upload file")
    parser.add_argument("file")
    args = parser.parse_args(sys.argv[2:])

    if not os.path.exists(args.file):
        raise ValueError(f"{args.file} does not exist")

    with open(args.file, 'rb') as f:
        data = f.read()
    params = {"data-binary": data }
    resp = requests.post(
            "http://api.nft.storage/upload",
            headers=HEADER,
            data=data,
        )
    if resp.status_code > 299:
        raise RuntimeError(f"API call failed: {resp.json()['error']['message']}")

if __name__ == "__main__":
    args = parser.parse_args(sys.argv[1:2])
    if args.command == "list":
        list()
    elif args.command == "upload":
        upload()

