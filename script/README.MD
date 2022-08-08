# Polygon Edge Deployment
This repository will allow you to create 4-Node Polygon Edge network, launching only one script - `build_reinstall.ps1` or `build.ps1`.
Requirements:
- Kubernetes Cluster (AKS/EKS/GKE)
- Container Registry (ACR/ECR/GCR/)
- Kubens + Kubectx (!OPTIONAL!) Installation guide: `https://github.com/ahmetb/kubectx`
- Docker Engine (Local)
- Bash shell (I used Git Bash on Windows)
---
Description of files, which are used by `ps1` scripts:
- build.ps1 - Build everything from scratch, it does not allow "Rebuilding" Polygon Edge network with new Data
- build_reinstall.ps1 - Delete old Data from PVC on Kubernetes, and generate new genesis file with data-dirs for nodes.
- Dockerfile - Contains Docker container definition, which launches ./launch.sh on startup
- init_nodes.sh - Create all 4 nodes data in `./temp` directory, and save 
- polygon-edge.yaml - Manifest responsible for creating:
    - 4 Deployments, named: `polygon-edge-node-X` (X ∈ <1,4>)
        - limits:
            - memory: 350Mi
            - cpu: 600m
        - requests:
            - memory: 250Mi
            - cpu: 450m
    - 4 Services - `LoadBalancers` with static IP, addressed in following manner:
        - polygon-edge-node-1 : `172.17.0.120`
            - Open ports : `1478 - libp2p` / `10001 - jsonrpc` / `9632 - grpc`
        - polygon-edge-node-2 : `172.17.0.121`
            - Open ports : `1478 - libp2p` / `10001 - jsonrpc` / `9632 - grpc`
        - polygon-edge-node-3 : `172.17.0.122`
            - Open ports : `1478 - libp2p` / `10001 - jsonrpc` / `9632 - grpc`
        - polygon-edge-node-4 : `172.17.0.123`
            - Open ports : `1478 - libp2p` / `10001 - jsonrpc` / `9632 - grpc`
    - PVCs (Persistent Volume Claims):
        - genesis-pvc:
            - Storage Class: `default`
            - Size: `1 Gi`
            - accesModes: `ReadWriteOnce`
        - Node PVC `node-pvc-X` (X ∈ <1,4>)
            - Storage Class: `azurefile-csi`
            - Size: `1 Gi`
            - accesModes: `ReadWriteMany`
