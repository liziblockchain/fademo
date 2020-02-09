docker-compose -f ./docker-peer.yaml up -d

docker exec cli peer channel create -o orderer.hunangrid.com.cn:7050 -c mychannel -t 50s -f ./chainel-artifacts/mychannel.tx

DELAY=2S
sleep $DELAY
docker exec cli peer channel join -b mychannel.block

sleep $DELAY
docker exec cli peer chaincode install -n mychannel -p github.com/hyperledger/fabric/hunan/chaincode/go -v 1.0

sleep $DELAY
docker exec cli peer chaincode instantiate -o orderer.hunangrid.com.cn:7050 -C mychannel -n mychannel -c '{"Args":["init", "A", "10", "B", "20"]}' -P "OR ('ShaoyangMSP.member')" -v 1.0

sleep $DELAY
docker exec cli peer chaincode query -C mychannel -n mychannel -c '{"Args":["query", "B"]}'

sleep $DELAY
docker exec cli peer chaincode query -C mychannel -n mychannel -c '{"Args":["query", "A"]}'

sleep $DELAY
docker-compose -f ./docker-peer.yaml down

docker rm $(docker ps -aq)

docker ps -aq
