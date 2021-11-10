pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'base/Debot.sol';
import 'base/Terminal.sol';
import 'base/Menu.sol';
import 'base/Sdk.sol';
import 'base/AddressInput.sol';

import 'AInitListDebot.sol';
import 'IShoppingList.sol';
import 'DoShoppingDebot.sol';

contract FillShoppingListDebot is DoShoppingDebot {

    string m_purchaseName;

    function _menu() virtual  internal override{}

    function createPurchase(uint64 index) public{
        index = index;
        Terminal.input(tvm.functionId(setPurchaseName), "Enter purchase name: ", false);
    }


    function setPurchaseName(string value) public{
        m_purchaseName = value;

        Terminal.input(tvm.functionId(setPurchaseQuantity), "Enter purchase quantity: ", false);
    }

    function setPurchaseQuantity(string value) public {
        (uint purchaseQuantity, bool status) = stoi(value);

        if(status) {
            createPurchase_(uint64(purchaseQuantity));
        } else {
            Terminal.print(0, "Amount must be integer!");
            createPurchase(1);
        }

    }

    function createPurchase_(uint64 purchaseQuantity) public view {
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).addPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseName, purchaseQuantity);
    }

    function showShoppingList(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShoppingList(m_address).getPurchasesAndStatus{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showShoppingList_),
            onErrorId: 0
        }();
    }

    function showShoppingList_(Purchase[] purchases, Status statusGet) public {
        uint32 i;
        if (!purchases.empty()) {
            Terminal.print(0, "Your Shopping List list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isBuy) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("id: {} Name: {} Quantity: {} Completed: {} Data: {} Price: {}", 
                purchase.id, purchase.name, purchase.quantity, completed, purchase.date, purchase.price));
            }
        } else {
            Terminal.print(0, "Your tasks list is empty.");
        }
        _menu();
    }

    function deletePurchase() public {
        if (m_status.paidItems + m_status.unpaidItems > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number id:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchase to delete.");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num, bool status) = stoi(value);

        if(status) {
            optional(uint256) pubkey = 0;
        IShoppingList(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
        } else {
            Terminal.print(0, "Id must be integer!");
            deletePurchase();
        }
    }
}   
