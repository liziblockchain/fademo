
UP_DOWN="$1"
CH_NAME="$2"
CLI_TIMEOUT="$3"
IF_COUCHDB="$4"

: ${CLI_TIMEOUT:="10000"}

#COMPOSE_FILE=docker-compose-cli.yaml
# COMPOSE_FILE=docker-compose-orderer.yaml
COMPOSE_FILE=docker-compose-etcdraft2.yaml
COMPOSE_FILE_PEER0ORG1=docker-compose-peer0org1.yaml
# COMPOSE_FILE_COUCH=docker-compose-couch.yaml
#COMPOSE_FILE=docker-compose-e2e.yaml

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
#    else
      #Generate all the artifacts that includes org certs, orderer genesis block,
      # channel configuration transaction
#      source generateArtifacts.sh $CH_NAME
    fi


#    CHANNEL_NAME=$CH_NAME TIMEOUT=$CLI_TIMEOUT docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_PEER0ORG1 up -d 2>&1
    #CHANNEL_NAME=$CH_NAME TIMEOUT=$CLI_TIMEOUT 
    docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_PEER0ORG1 up -d


#     if [ "${IF_COUCHDB}" == "couchdb" ]; then
   
#       echo "11111" $CH_NAME $CLI_TIMEOUT "--------" $COMPOSE_FILE "--------"  $COMPOSE_FILE_COUCH 
# #       CHANNEL_NAME=$CH_NAME TIMEOUT=$CLI_TIMEOUT docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up -d 2>&1
#     else
#       echo "222" $CH_NAME $CLI_TIMEOUT "--------" $COMPOSE_FILE 
# #       CHANNEL_NAME=$CH_NAME TIMEOUT=$CLI_TIMEOUT docker-compose -f $COMPOSE_FILE up -d 2>&1
#     fi
    if [ $? -ne 0 ]; then
	echo "ERROR !!!! Unable to pull the images "
	exit 1
    fi
#    docker logs -f cli
}


function startTest () {

    DELAY=2S
    echo "lizitime-----------:  create channel"
    docker exec cli peer channel create -o orderer.lizitime.com:7050 -c lizitimechannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lizitime.com/orderers/orderer.lizitime.com/msp/tlscacerts/tlsca.lizitime.com-cert.pem

    sleep $DELAY
    echo "lizitime-----------:  join channel"
    # docker exec cli peer channel join -b mychannel.block
    docker exec cli peer channel join -b lizitimechannel.block

    sleep $DELAY
    echo "lizitime-----------:  install chaincode"
    docker exec cli peer chaincode package -n mycc -v 1.0 -p github.com/hyperledger/fabric/chaincode/go  myccpack.out

    #    sleep $DELAY
    #    echo "lizitime-----------:  "
    docker exec cli peer chaincode install myccpack.out

    sleep $DELAY
    echo "lizitime-----------:  instantiate chaincode"
    docker exec cli peer chaincode instantiate -o orderer.lizitime.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lizitime.com/orderers/orderer.lizitime.com/msp/tlscacerts/tlsca.lizitime.com-cert.pem -C lizitimechannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}'

        # -P "OR ('Org1MSP.peer','Org2MSP.peer')" 

    sleep $DELAY
    echo "lizitime-----------:  query a"
    docker exec cli peer chaincode query -C lizitimechannel -n mycc -c '{"Args":["query", "a"]}'
    echo "lizitime-----------:  query b"
    docker exec cli peer chaincode query -C lizitimechannel -n mycc -c '{"Args":["query", "b"]}'

    echo "lizitime-----------:  invoke chaincode"
    docker exec cli peer chaincode invoke -C lizitimechannel -n mycc  -c '{"Args":["invoke", "a", "b", "1"]}' --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lizitime.com/orderers/orderer.lizitime.com/msp/tlscacerts/tlsca.lizitime.com-cert.pem

    sleep $DELAY
    echo "lizitime-----------:  query a"
    docker exec cli peer chaincode query -C lizitimechannel -n mycc -c '{"Args":["query", "a"]}'
    echo "lizitime-----------:  query b"
    docker exec cli peer chaincode query -C lizitimechannel -n mycc -c '{"Args":["query", "b"]}'

}

function networkDown () {
#    docker-compose -f $COMPOSE_FILE down
#    docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH if $COMPOSE_FILE_PEER0ORG1 down
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
    # sleep 15
	# startTest
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
