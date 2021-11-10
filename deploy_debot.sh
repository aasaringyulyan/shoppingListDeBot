#!/bin/bash
set -e

if [[ $1 != *".tvc"  ]] ; then 
    echo "ERROR: contract file name .tvc required!"
    echo ""
    echo "USAGE:"
    echo "  ${0} FILENAME NETWORK"
    echo "    where:"
    echo "      FILENAME - required, debot tvc file name"
    echo "      NETWORK  - optional, network endpoint, default is https://net.ton.dev"
    echo ""
    echo "PRIMER:"
    echo "  ${0} mydebot.tvc https://net.ton.dev"
    exit 1
fi

DEBOT_NAME=${1%.*} # filename without extension
NETWORK="${2:-https://net.ton.dev}"

#
# This is TON OS SE giver address, correct it if you use another giver
#
#GIVER_ADDRESS=0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5

# net.ton.dev
GIVER_ADDRESS=0:66e9adbc2fcfedf9fa7257a106080ecda669221b12fea4e490599b03af266b7f


# Check if tonos-cli installed 
tos=./tonos-cli
if $tos --version > /dev/null 2>&1; then
    echo "OK $tos installed locally."
else 
    tos=tonos-cli
    if $tos --version > /dev/null 2>&1; then
        echo "OK $tos installed globally."
    else 
        echo "$tos not found globally or in the current directory. Please install it and rerun script."
    fi
fi


function giver {
    $tos --url $NETWORK call \
        --abi base/giver.abi.json \
        --sign base/giver.keys.json \
        $GIVER_ADDRESS \
        sendTransaction "{\"dest\":\"$1\",\"value\":2000000000,\"bounce\":false,\"flags\":0,\"payload\":\"\" }" | tee -a logs.log
        
}

function get_address {
    echo $(cat $1.log | grep "Raw address:" | cut -d ' ' -f 3)
}

function genaddr {
    $tos genaddr $1.tvc $1.abi.json --genkey $1.keys.json > $1.log
}

echo "Step 1. Calculating debot address"
genaddr $DEBOT_NAME
DEBOT_ADDRESS=$(get_address $DEBOT_NAME)

echo "Step 2. Send tokens to address: $DEBOT_ADDRESS"
# giver $DEBOT_ADDRESS
read -p 'Done? ' inputvar
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)


echo "Step 3. Deploying contract"
$tos --url $NETWORK deploy $DEBOT_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json | tee -a logs.log

$tos --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json | tee -a logs.log


$tos --url $NETWORK call $DEBOT_ADDRESS setShoppingListCode ShoppingList.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json | tee -a logs.log

echo "Done! Deployed debot with address: $DEBOT_ADDRESS"