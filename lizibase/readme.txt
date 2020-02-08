this has tested on fabric v1.4.4

note:
1. this version derived from e2e_cli example from fabric ver1.1.1
2. tested on fabric 1.4.4
3. worked on two computers, and the java client work

However, 
if remove channel-artifacts and crypto-config folder
1. generate those folders by ver1.4.4 tools, it can't work during create channel
2. generate those folders by ver1.1.1 tools, it works fine

---------------------------------------------------------------------------
v1.4.4 

docker cp mychannel.tx  aaaaaaaa:
/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block

docker exec cli peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker exec cli peer channel join -b mychannel.block

docker exec cli peer chaincode package -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go  myccpack.out

docker exec cli peer chaincode install myccpack.out

docker exec cli peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'

# -P "OR ('Org1MSP.peer','Org2MSP.peer')" 

docker exec cli peer chaincode query -C mychannel -n mycc -c '{"Args":["query", "a"]}'

docker exec cli peer chaincode query -C mychannel -n mycc -c '{"Args":["query", "b"]}'

docker exec cli peer chaincode invoke -C mychannel -n mycc  -c '{"Args":["invoke", "a", "b", "1"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# another command to install chaincode
#docker exec cli peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go
