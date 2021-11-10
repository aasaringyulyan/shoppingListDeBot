pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'base/Debot.sol';
import 'base/Terminal.sol';
import 'base/Menu.sol';
import 'base/Sdk.sol';
import 'base/AddressInput.sol';

import 'Objects.sol';
import 'ITransactable.sol';
import 'AShopingList.sol';
import 'IShoppingList.sol';

abstract contract AInitListDebot {

    TvmCell m_shoppingListCode; 
    TvmCell m_shopingListData;
    TvmCell m_shopingListStateInit;

    address m_address;  
    Status m_status;          
    uint256 m_masterPubKey; 
    address m_msigAddress; 

    uint32 INITIAL_BALANCE =  200000000; 

    function setShoppingListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shoppingListCode = code;
        m_shopingListData = data;
        m_shopingListStateInit = tvm.buildStateInit(m_shoppingListCode, m_shopingListData); 
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x" + value);

        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a ShoppingList list...");
            // TvmCell deployState = tvm.insertPubkey(m_shoppingListCode, m_masterPubKey);
            TvmCell deployState = tvm.insertPubkey(m_shopingListStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format("Info: your TODO contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);
        } else {
            Terminal.input(tvm.functionId(savePublicKey), "Wrong public key. Try again!\nPlease enter your public key.", false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) {
            _getStat(tvm.functionId(setStat));
        } else if (acc_type == -1) {
            Terminal.print(0, "You don't have a TODO list yet, so a new contract with an initial balance of 0.2 tokens will be deployed.");
            AddressInput.get(tvm.functionId(creditAccount), "Select a wallet for payment. We will ask you to sign two transactions.");
        } else if (acc_type == 0) {
            Terminal.print(0, format("Deploying new contract. If an error occurs, check if your ShoppingList contract has enough tokens on its balance."));
            deploy();
        } else if (acc_type == 2) {
            Terminal.print(0, format("Can not continue: account {} is frozen.", m_address));
        }
    }

    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;

        ITransactable(m_msigAddress).sendTransaction {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        sdkError = sdkError;
        exitCode = exitCode;
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));

        creditAccount(m_msigAddress);
    }   

    function waitBeforeDeploy() public {
        Terminal.print(0, "We'll have to wait!");
         Sdk.getAccountType(tvm.functionId(checkIfStatusIs0), m_address);
    }

    function checkIfStatusIs0(int8 acc_type) public {
        if (acc_type == 0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
        // TvmCell image = tvm.insertPubkey(m_shoppingListCode, m_masterPubKey);
        TvmCell image = tvm.insertPubkey(m_shopingListStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {AShopingList, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public {
        sdkError = sdkError;
        exitCode = exitCode;
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        
        deploy();
    }

    function onSuccess() public {
        _getStat(tvm.functionId(setStat));
    }

    function _getStat(uint32 answerId) private view {
        optional(uint256) none;
        IShoppingList(m_address).getPurchasesAndStatus{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function _menu() virtual internal;

    function setStat(Status status) public {
        m_status = status;
        _menu();
    }

     function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }
}

