#!/bin/bash

export FABRIC_CFG_PATH=$PWD
export CHANNEL_NAME=mychannel

mkdir channel-artifacts

cryptogen generate --config=./crypto-config.yaml
# configtxgen -profile HunanGridsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
# configtxgen -profile HunanGridsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel

configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

