#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
set -e

CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/ca.crt
CHANNEL_NAME=mychannel

function operate() {
	echo "============ 切换到Org3MSP"
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.crt
    CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.key
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
	CORE_PEER_ADDRESS=peer0.org3.example.com:8051
	CORE_PEER_LOCALMSPID=Org3MSP
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
	
	echo "============ peer channel join -b mychannel.block"
	peer channel join -b mychannel.block
	sleep 2
	echo "============ peer channel update -o orderer1.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile $CAFILE"
	peer channel update -o orderer1.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org3MSPanchors.tx --tls --cafile $CAFILE
	

	echo "============ 切换到Org3MSP"
	CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.crt
    CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.key
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
	CORE_PEER_ADDRESS=peer0.org3.example.com:8051
	CORE_PEER_LOCALMSPID=Org3MSP
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp

	echo "============ peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/"
	peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

	echo "============ peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'"
	peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

	echo "============ peer chaincode invoke -o orderer1.example.com:7050 --tls true --cafile $CAFILE -C $CHANNEL_NAME -n mycc"
	peer chaincode invoke -o orderer1.example.com:7050 --tls true --cafile $CAFILE -C $CHANNEL_NAME -n mycc  -c '{"Args":["invoke","a","b","10"]}'
	sleep 5
	echo "============ peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'"
	peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

	echo "=================test offical cc down=================="
}
operate
exit 0
