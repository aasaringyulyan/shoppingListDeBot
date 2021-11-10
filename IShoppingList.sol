pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'Objects.sol';

interface IShoppingList {
    function getPurchasesAndStatus() external returns(Purchase[] purchasesGet, Status statusGet);
    function addPurchase(string name, uint64 quantity) external;
    function deletePurchase(uint32 id) external;
    function buy(uint32 id, uint price) external;
}
