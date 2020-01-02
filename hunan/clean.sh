rm -rf crypto-config
rm -rf channel-artifacts
mkdir channel-artifacts

export FABRIC_CFG_PATH=$PWD
cryptogen generate --config=./crypto-config.yaml
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel
