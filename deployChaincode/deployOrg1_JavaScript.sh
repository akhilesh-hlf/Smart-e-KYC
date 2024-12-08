#!/usr/bin/env bash

chaincodeInfo() {
  export CHANNEL_NAME="mychannel"
  export CC_RUNTIME_LANGUAGE="node"
  export CC_VERSION="1"
  export CC_SRC_PATH=../chaincodes/javascript
  export CC_NAME="eKYCjs"
  export CC_SEQUENCE="1"

}
preSetupJavaScript() {

  pushd ../chaincodes/javascript
  #npm install
  #npm run build
  popd

}
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../orderer/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/../org1/crypto-config-ca/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config

setGlobalsForPeer0Org1() {
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/../org1/crypto-config-ca/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
}

packageChaincode() {

  rm -rf ${CC_NAME}.tar.gz

  peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION}

}

installChaincode() {

  peer lifecycle chaincode install ${CC_NAME}.tar.gz

}

queryInstalled() {

  peer lifecycle chaincode queryinstalled >&log.txt

  cat log.txt

  PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)

  echo PackageID is ${PACKAGE_ID}
}
approveForMyOrg1() {

  setGlobalsForPeer0Org1

  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} --init-required

}

getblock() {
  peer channel getinfo -c mychannel -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA
}

checkCommitReadyness() {

  peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --init-required --output json

}
commitChaincodeDefination() {

  peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --init-required

}
queryCommitted() {

  peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} --output json

}
chaincodeInvokeInit() {

  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --isInit -c '{"function": "initLedger","Args":[]}'

}

insertTransaction() {
  echo "Writing  transactions"
  #---------------------Code Used in smart e-KYC -------------------------------#
	# c=1
	# while [ $c -le 10 ];
	# do 

  # #peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA -c '{"function": "createeKYC", "Args":["eKYC101","TechMahindra","co-operative","MH04123456", "mhmob98462c"]}'
	# peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA -c '{"function": "createeKYC", "Args":["eKYC101","AKHILESH SHARMA","BBBBB","05-09-2002", "ICG1234567", "CGRR5678W123", "H.N.-128, GE ROAD XXXX 495001", "1234567890"]}'
	# (( c++ ))
	# done
  #---------------------End of Code Used in smart e-KYC -------------------------------#

  random_numbers=$(shuf -i 1-100000 -n 10000)  # Insert 10000 random records from/out of 1 to 100000
  #random_numbers=$(shuf -i 1-5 -n 5) 
  for KYC_NUM in $random_numbers
  do
    KYC="eKYC${KYC_NUM}"
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA -c '{"function": "createeKYC", "Args":["'"$KYC"'","AKHILESH SHARMA","BBBBB","05-09-2002", "ICG1234567", "CGRR5678W123", "H.N.-128, GE ROAD XXXX 495001", "1234567890"]}'
  done
  sleep 2
}
#insertTransaction() {

  #peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA -c '{"function": "createeKYC", "Args":[]}'

  #sleep 2
#}
readTransaction() {
  echo "Reading  transactions"
  #-------All lines are commentted in smart eKYC-------#
  # Query all eKYC Records 

  #peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAlleKYCs"]}'

  # Query User by KYC Id
  random_numbers=$(shuf -i 1-100000 -n 10)  #Serch 100,200,300,...,1000 records from the 10000 records inserted between 1 to 100000
  #random_numbers=$(shuf -i 1-5 -n 5)
  for KYC_NUM in $random_numbers
  do
    KYC="eKYC${KYC_NUM}"
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryeKYC","Args":["'"$KYC"'"]}'
  done
  #echo "Transactions save successfully"
}

lifecycleCommands() {
  packageChaincode
  sleep 2
  installChaincode
  sleep 2
  queryInstalled
  sleep 2
  approveForMyOrg1
  sleep 2
  getblock
  checkCommitReadyness
  sleep 2
  commitChaincodeDefination
  sleep 2
  queryCommitted
  sleep 2
  chaincodeInvokeInit
  sleep 10
}
getInstallChaincodes() {

  peer lifecycle chaincode queryinstalled

}

preSetupJavaScript
chaincodeInfo
setGlobalsForPeer0Org1
lifecycleCommands
insertTransaction
#readTransaction
getInstallChaincodes
