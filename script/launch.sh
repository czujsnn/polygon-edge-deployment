#!/bin/bash
sleep 60
polygon-edge server --price-limit 10000000000 --data-dir ./data-dir --chain genesis/genesis.json  --libp2p 0.0.0.0:1478 --jsonrpc 0.0.0.0:10001 --grpc-address 0.0.0.0:9632 --nat $(hostname -i) --log-level INFO --seal