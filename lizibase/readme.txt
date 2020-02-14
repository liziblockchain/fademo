this has tested on fabric v1.4.4

note:
1. use etcdRaft consensus
2. worked on multi hosts
3. Java client works
4. if Re-build cert files, must update CA peer cert files, otherwise, Java Client cann't work

---------------------------------------------------------------------------
commands list:

docker cp lizitimechannel.tx  aaaaaaaa:
/opt/gopath/src/github.com/hyperledger/fabric/peer/lizitimechannel.block

# create channel
docker exec cli peer channel create -o orderer.lizitime.com:7050 -c lizitimechannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lizitime.com/orderers/orderer.lizitime.com/msp/tlscacerts/tlsca.lizitime.com-cert.pem

# join channel
docker exec cli peer channel join -b lizitimechannel.block

# package chaincode
docker exec cli peer chaincode package -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go  myccpack.out

# install chaincode
docker exec cli peer chaincode install myccpack.out

# instantiate chaincode
docker exec cli peer chaincode instantiate -o orderer.lizitime.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lizitime.com/orderers/orderer.lizitime.com/msp/tlscacerts/tlsca.lizitime.com-cert.pem -C lizitimechannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'
# -P "OR ('Org1MSP.peer','Org2MSP.peer')" 

# query chaincode
docker exec cli peer chaincode query -C lizitimechannel -n mycc -c '{"Args":["query", "a"]}'

# query chaincode
docker exec cli peer chaincode query -C lizitimechannel -n mycc -c '{"Args":["query", "b"]}'

# invoke chaincode method to change it's state
docker exec cli peer chaincode invoke -C lizitimechannel -n mycc  -c '{"Args":["invoke", "a", "b", "1"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lizitime.com/orderers/orderer.lizitime.com/msp/tlscacerts/tlsca.lizitime.com-cert.pem

# another command to install chaincode
#docker exec cli peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go
