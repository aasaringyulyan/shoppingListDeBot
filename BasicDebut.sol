pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "base/Debot.sol";
import "base/Terminal.sol";
import "base/Menu.sol";
import "base/AddressInput.sol";
import "base/ConfirmInput.sol";
import "base/Sdk.sol";

import 'AInitListDebot.sol';
import 'FillShoppingListDebot.sol';
import 'DoShoppingDebot.sol';

contract BasicDebut is Debot, AInitListDebot, FillShoppingListDebot {

    bytes m_icon;

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key", false);
    }

   function getDebotInfo() public functionID(0xDEB) override
   view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) 
    {
        name = "Shoping list DeBot";
        version = "0.1.0";
        publisher = "KatawaS";
        key = "Shoping list manager";
        author = "KatawaS";
        support = address.makeAddrStd(0, 0x4d4ae6f05bdca8da3d26c5931c797fc5b933e3d2c9554c2108ef0943c1caebb6);
        hello = "Hi, i'm a Shoping list DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID ];
    }

    function _menu() override(AInitListDebot, FillShoppingListDebot) internal {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (paidItems/unpaidItems/totalPaid) purchases.",
                    m_status.paidItems,
                    m_status.unpaidItems,
                    m_status.paidItems + m_status.unpaidItems
            ),
            sep,
            [
                 MenuItem("Display a shopping list","",tvm.functionId(showShoppingList)),
                MenuItem("Add a new product","",tvm.functionId(createPurchase)),
                MenuItem("Delete a purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }
}
