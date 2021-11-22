#!/usr/bin/env python3

import json

if __name__ == "__main__":
    with open("tier_imgs.json",'r') as f:
        imgs = json.load(f)

    for tier, img_url in imgs.items():
        metadata = {
            "name": "Eco Wallet",
            "description": "Wallets to drive community action",
            "image": img_url,
            "attributes": [ {"tier": int(tier)} ]
        }

        metadata_file = f"tier-{tier}-uri.json"
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f)

