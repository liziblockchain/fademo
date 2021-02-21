this has tested on fabric v1.4.9

Usage:
./run.sh up    // start it
./run.sh down  // stop it

Note:
1. use etcdRaft consensus
2. worked on multi hosts
3. Java client works
4. if Re-build cert files, must update CA peer cert files, otherwise, Java Client cann't work
5. WARNING: the IP Address of filed: extra_hosts in docker-compose-peer0org1.yaml & docker-compose-peer1org1.yaml maybe cause it CANN't work, change it accordingly.

---------------------------------------------------------------------------
commands list:

docker cp liziblockchainchannel.tx  aaaaaaaa:
/opt/gopath/src/github.com/hyperledger/fabric/peer/liziblockchainchannel.block

# create channel
docker exec cli peer channel create -o orderer.liziblockchain.com:7050 -c liziblockchainchannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

# join channel
docker exec cli peer channel join -b liziblockchainchannel.block

# package chaincode
docker exec cli peer chaincode package -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go  myccpack.out

# install chaincode¡
docker exec cli peer chaincode install myccpack.out

# instantiate chaincode
docker exec cli peer chaincode instantiate -o orderer.liziblockchain.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem -C liziblockchainchannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'
# -P "OR ('Org1MSP.peer','Org2MSP.peer')"

# query chaincode
docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "a"]}'

# query chaincode
docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "b"]}'

# invoke chaincode method to change it's state
docker exec cli peer chaincode invoke -C liziblockchainchannel -n mycc  -c '{"Args":["invoke", "a", "b", "1"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

# another command to install chaincode
#docker exec cli peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go
