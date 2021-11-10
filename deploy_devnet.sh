#!/bin/bash

echo "Run deploying scripts Debot"
./deploy_debot.sh AInitListDebot.tvc | tee Addresses.log
AINIT_DEBOT_ADDRESS=$(cat Addresses.log | grep "Done!" | cut -d ' ' -f 6)

echo "purchaseBuy Debot"
./deploy_debot.sh DoShoppingDebot.tvc | tee Addresses.log
DO_DEBOT_ADDRESS=$(cat Addresses.log | grep "Done!" | cut -d ' ' -f 6)

echo "purchaseBuy Debot"
./deploy_debot.sh FillShoppingListDebot.tvc | tee Addresses.log
FILL_DEBOT_ADDRESS=$(cat Addresses.log | grep "Done!" | cut -d ' ' -f 6)

echo "purchaseBuy Debot"
./deploy_debot.sh BasicDebut.tvc | tee Addresses.log
BASE_DEBOT_ADDRESS=$(cat Addresses.log | grep "Done!" | cut -d ' ' -f 6)

echo "Debot addresses:"
echo "purchaseList: $Add_DEBOT_ADDRESS"
# echo "purchaseBuy: $Buy_DEBOT_ADDRESS"
read -p 'Exit? ' inputvar