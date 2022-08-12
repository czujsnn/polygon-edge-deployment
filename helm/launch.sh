#!/bin/bash
sleep 10
if compgen -G "/genesis/genesis.json" > /dev/null; then
   echo "Genesis File already exists, launching server."
    polygon-edge server --price-limit 10000000000 --data-dir ./data-dir --chain genesis/genesis.json  --libp2p 0.0.0.0:1478 --jsonrpc 0.0.0.0:10001 --grpc-address 0.0.0.0:9632 --nat $(hostname -i) --log-level INFO --seal

else
    node1_public_key=$(cat /public-node/public_key_node-polygon-edge-node-1.txt)
    node2_public_key=$(cat /public-node/public_key_node-polygon-edge-node-2.txt)
    node3_public_key=$(cat /public-node/public_key_node-polygon-edge-node-3.txt)
    node4_public_key=$(cat /public-node/public_key_node-polygon-edge-node-4.txt)
    node1_node_id=$(cat /public-node/node_id_node-polygon-edge-node-1.txt)
    node2_node_id=$(cat /public-node/node_id_node-polygon-edge-node-2.txt)
    multiaddr_node1="/ip4/172.17.0.120/tcp/1478/p2p/${node1_node_id}"
    multiaddr_node2="/ip4/172.17.0.121/tcp/1478/p2p/${node2_node_id}"

    polygon-edge genesis --chain-id 19831608 --name polygon-edge-chain --consensus ibft --premine 0x710E74EcBa975e1103A6862bd5Eb24364d9c36D9:0x3635C9ADC5DEA00000 --premine 0x2Af099E8ac70e249FAd823fB7478753526fef5ff:0x1B1AE4D6E2EF500000 --ibft-validator=${node1_public_key} --ibft-validator=${node2_public_key} --ibft-validator=${node3_public_key} --ibft-validator=${node4_public_key} --bootnode=$multiaddr_node1 --bootnode=$multiaddr_node2
    mv ./genesis.json /genesis
    sleep 5
    polygon-edge server --price-limit 10000000000 --data-dir ./data-dir --chain genesis/genesis.json  --libp2p 0.0.0.0:1478 --jsonrpc 0.0.0.0:10001 --grpc-address 0.0.0.0:9632 --nat $(hostname -i) --log-level INFO --seal
fi