export FABRIC_CFG_PATH=$PWD
mkdir channel-artifacts

cryptogen generate --config=./crypto-config.yaml
configtxgen -profile HunanGridsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile HunanGridsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel
