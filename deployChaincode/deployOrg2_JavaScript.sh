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
export PEER0_ORG2_CA=${PWD}/../org2/crypto-config-ca/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config

setGlobalsForPeer0Org2() {
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/../org2/crypto-config-ca/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
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
approveForMyOrg2() {

  setGlobalsForPeer0Org2

  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} --init-required

}

insertTransaction() {

  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA -c '{"function": "createKYC", "Args":["eKYC102","Ambuja","corporate","CG04123456", "ddrrn9705a", "ZZZZZ", "WWWWW", "YYYY"]}'

  sleep 2
}
readTransaction() {
  #echo "Query transactions"
  echo "verifying a transaction"

  #Call verify e-KYC record chaincode
  #peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "verifyKYC","Args":["eKYC101", "1c1d42deef6be58f15807a959f50cea3b7efad90ba4011f2cd42c15452c76029"]}'
  #c=1
	#while [ $c -le 1	 ];
	#do   
  	#peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "verifyKYC","Args":["eKYC101", "QmbPapwoiMnTbDC2et8XEBHSH5Vrk5ohbiw7Wxp6WmG7Sh"]}'
 	#(( c++ ))
	#done
  
  


  #peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAlleKYC"]}'

#-------------------- Smart e-KYC used code --------------------------------#
  # Query User by eKYC Id
  # 	c=1
	# while [ $c -le 1	 ];
	# do 
  # 	peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryeKYC","Args":["eKYC101"]}'
  # 	(( c++ ))
	# done
#--------------------End of  Smart e-KYC used code --------------------------------#


  random_numbers=$(shuf -i 1-100000 -n 1000)  #Serch 100,200,300,...,1000 records from the 10000 records inserted between 1 to 100000
  #random_numbers=$(shuf -i 1-5-n 1)
  for KYC_NUM in $random_numbers
  do
    KYC="eKYC${KYC_NUM}"
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "query","Args":["'"$KYC"'"]}'
  done

  
  
}

lifecycleCommands() {
  packageChaincode
  sleep 2
  installChaincode
  sleep 2
  queryInstalled
  sleep 2
  approveForMyOrg2

}
getInstallChaincodes() {

  peer lifecycle chaincode queryinstalled

}
preSetupJavaScript
chaincodeInfo
setGlobalsForPeer0Org2
lifecycleCommands
#insertTransaction
readTransaction
getInstallChaincodes
