
UP_DOWN="$1"
CH_NAME="$2"
CLI_TIMEOUT="$3"
IF_COUCHDB="$4"

: ${CLI_TIMEOUT:="10000"}

COMPOSE_FILE=docker-compose-etcdraft2.yaml
COMPOSE_FILE_PEER0ORG1=docker-compose-peer0org1.yaml

function printHelp () {
	echo "Usage: ./network_setup <up|down> <\$channel-name> <\$cli_timeout> <couchdb>.\nThe arguments must be in order."
}

function validateArgs () {
	if [ -z "${UP_DOWN}" ]; then
		echo "Option up / down / restart not mentioned"
		printHelp
		exit 1
	fi
	if [ -z "${CH_NAME}" ]; then
		echo "setting to default channel 'mychannel'"
		CH_NAME=mychannel
	fi
}

function clearContainers () {
        CONTAINER_IDS=$(docker ps -aq)
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "---- No containers available for deletion ----"
        else
                docker stop $CONTAINER_IDS
                docker rm -f $CONTAINER_IDS
        fi
}

function removeUnwantedImages() {
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
                echo "---- No images available for deletion ----"
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
}

function networkUp () {
  if [ -d "./crypto-config" ]; then
    echo "crypto-config directory already exists."
  fi

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_PEER0ORG1 up -d

  if [ $? -ne 0 ]; then
		echo "ERROR !!!! Unable to pull the images "
		exit 1
  fi
}

# startTest_v14x 中的命令都是在 v1.4.x中顺利执行的，在v2.2.x也可以顺利执行
function startTest_v14x () {

    DELAY=2S
    echo "liziblockchain-----------:  create channel"
    docker exec cli peer channel create -o orderer.liziblockchain.com:7050 -c liziblockchainchannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

		# docker exec cli peer channel create -o orderer.liziblockchain.com:7050 -c liziblockchainchannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

		# peer channel create -o localhost:7050 -c mychannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile /work/fabric/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


    sleep $DELAY
    echo "liziblockchain-----------:  join channel"
    docker exec cli peer channel join -b liziblockchainchannel.block
    # peer channel join -b ./channel-artifacts/mychannel.block

    sleep $DELAY
    echo "liziblockchain-----------:  install chaincode"
    docker exec cli peer chaincode package -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go  myccpack.out

    docker exec cli peer chaincode install myccpack.out

    sleep $DELAY
    echo "liziblockchain-----------:  instantiate chaincode"
    # docker exec cli peer chaincode instantiate -o orderer.liziblockchain.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem -C liziblockchainchannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'
		docker exec cli peer chaincode instantiate -o orderer.liziblockchain.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem -C liziblockchainchannel -n mycc -v 1.0 -c '{"function":"InitLedger","Args":[]}'

    sleep $DELAY
    # echo "liziblockchain-----------:  query a"
    # docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "a"]}'
    echo "liziblockchain-----------:  query GetAllAssets"
    # docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "b"]}'
		docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["GetAllAssets"]}'

		sleep $DELAY
		echo "liziblockchain-----------:  query asset6"
    # docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "b"]}'
		docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["ReadAsset","asset6"]}'

    echo "liziblockchain-----------:  invoke chaincode, change asset6"
    # docker exec cli peer chaincode invoke -C liziblockchainchannel -n mycc  -c '{"Args":["invoke", "a", "b", "1"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

		docker exec cli peer chaincode invoke -C liziblockchainchannel -n mycc  -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

    # peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'

    sleep $DELAY
    # echo "liziblockchain-----------:  query a"
    # docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "a"]}'
    echo "liziblockchain-----------:  query asset6"
    # docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "b"]}'
		docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["ReadAsset","asset6"]}'

    # peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'

}


# startTest_v22x 中的命令都是在 v2.2.x中顺利执行的
function startTest_v22x () {

    DELAY=2S
    echo "liziblockchain-----------:  create channel"
    # docker exec cli     peer channel create -o orderer.liziblockchain.com:7050 -c liziblockchainchannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

docker exec cli peer channel create -o orderer.liziblockchain.com:7050 -c liziblockchainchannel --ordererTLSHostnameOverride orderer.liziblockchain.com -f ./channel-artifacts/channel.tx --outputBlock ./liziblockchainchannel.block --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem




    sleep $DELAY
    echo "liziblockchain-----------:  join channel"
    docker exec cli peer channel join -b ./liziblockchainchannel.block

    sleep $DELAY
    echo "liziblockchain-----------:  install chaincode"
    # docker exec cli peer chaincode package -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go  myccpack.out
    # peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-go --lang golang --label basic_1.0

    docker exec cli peer lifecycle chaincode package basic.tar.gz --path github.com/hyperledger/fabric/chaincode/go --lang golang --label basic_1.0

    # docker exec cli peer chaincode install myccpack.out
    docker exec cli peer lifecycle chaincode install basic.tar.gz
    # Installing chaincode on peer0.org1
    # peer lifecycle chaincode install basic.tar.gz
    # Install chaincode on peer0.org2...
    # peer lifecycle chaincode install basic.tar.gz

    # Using organization 1
    # peer lifecycle chaincode queryinstalled
    docker exec cli peer lifecycle chaincode queryinstalled


    docker exec cli peer lifecycle chaincode approveformyorg -o orderer.liziblockchain.com:7050 --ordererTLSHostnameOverride orderer.liziblockchain.com --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem --channelID liziblockchainchannel --name basic --version 1.0 --package-id basic_1.0:b8ee3a23493f35e655b3b0bff7c8c0091d5c32a74d692f9a8f8e75f3d7618af2 --sequence 1

    # Using organization 1
    # peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /work/fabric/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:4ec191e793b27e953ff2ede5a8bcc63152cecb1e4c3f301a26e22692c61967ad --sequence 1

    # Using organization 1
    # Checking the commit readiness of the chaincode definition on peer0.org1 on channel 'mychannel'...
    # peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json
    # Using organization 2
    # Checking the commit readiness of the chaincode definition on peer0.org2 on channel 'mychannel'...
    # peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json

    # Using organization 2
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /work/fabric/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:4ec191e793b27e953ff2ede5a8bcc63152cecb1e4c3f301a26e22692c61967ad --sequence 1
    # Using organization 1
    # Checking the commit readiness of the chaincode definition on peer0.org1 on channel 'mychannel'...
    peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json
    # Using organization 2
    # Checking the commit readiness of the chaincode definition on peer0.org2 on channel 'mychannel'...
    peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json



    sleep $DELAY
    echo "liziblockchain-----------:  instantiate chaincode"
    docker exec cli peer chaincode instantiate -o orderer.liziblockchain.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem -C liziblockchainchannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'

    sleep $DELAY
    echo "liziblockchain-----------:  query a"
    docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "a"]}'
    echo "liziblockchain-----------:  query b"
    docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "b"]}'

    echo "liziblockchain-----------:  invoke chaincode"
    docker exec cli peer chaincode invoke -C liziblockchainchannel -n mycc  -c '{"Args":["invoke", "a", "b", "1"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/liziblockchain.com/orderers/orderer.liziblockchain.com/msp/tlscacerts/tlsca.liziblockchain.com-cert.pem

    sleep $DELAY
    echo "liziblockchain-----------:  query a"
    docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "a"]}'
    echo "liziblockchain-----------:  query b"
    docker exec cli peer chaincode query -C liziblockchainchannel -n mycc -c '{"Args":["query", "b"]}'

}

function networkDown () {
    docker-compose -f $COMPOSE_FILE  -f $COMPOSE_FILE_PEER0ORG1 down

    #Cleanup the chaincode containers
    clearContainers

    #Cleanup images
    removeUnwantedImages

    # remove orderer block and other channel configuration transactions and certs
#    rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config
}

validateArgs

#Create the network using docker compose
if [ "${UP_DOWN}" == "up" ]; then
        networkUp
        sleep 15
        startTest_v14x
elif [ "${UP_DOWN}" == "down" ]; then ## Clear the network
	networkDown
elif [ "${UP_DOWN}" == "test" ]; then ## Clear the network
	startTest
elif [ "${UP_DOWN}" == "restart" ]; then ## Restart the network
	networkDown
	networkUp
else
	printHelp
	exit 1
fi
