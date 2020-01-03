this example has tested on fabric version 1.1.1

生成项目所需的文件
cryptogen generate --config=./crypto-config.yaml

export FABRIC_CFG_PATH=$PWD

创建 orderer genesis block
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

peer node创建channel的配置文件
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel



boot the sample
docker-compose -f ./docker-peer.yaml up -d

shutdown
docker-compose -f ./docker-peer.yaml down

docker exec -it cli /bin/bash

create channel
#peer channel create -o orderer.example.com:7050 -c mychannel -t 50 -f ./chainel-artifacts/mychannel.tx
#peer channel create -o orderer.example.com:7050 -c mychannel -t 50s -f ./chainel-artifacts/mychannel.tx
peer channel create -o orderer.hunangrid.com.cn:7050 -c mychannel -t 50s -f ./chainel-artifacts/mychannel.tx


join channel
peer channel join -b mychannel.block

install chaincode
peer chaincode install -n mychannel -p github.com/hyperledger/fabric/hunan/chaincode/go -v 1.0

instantiate chaincode
#peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mychannel -c '{"Args":["init", "A", "10", "B", "20"]}' -P "OR ('ShaoyangMSP.member')" -v 1.0
peer chaincode instantiate -o orderer.hunangrid.com.cn:7050 -C mychannel -n mychannel -c '{"Args":["init", "A", "10", "B", "20"]}' -P "OR ('ShaoyangMSP.member')" -v 1.0

query
peer chaincode query -C mychannel -n mychannel -c '{"Args":["query", "B"]}'
