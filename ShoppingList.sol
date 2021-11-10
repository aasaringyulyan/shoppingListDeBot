pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import 'Objects.sol';
import 'IShoppingList.sol';

contract ShoppingList is IShoppingList {
    
    modifier onlyOwner() {
        require(msg.pubkey() == ownerPubkey, 101);
        _;
    }

    uint32 count;

    mapping (uint32=>Purchase) purchases;
    
    uint256 ownerPubkey;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();

        ownerPubkey = pubkey;
    }

    function getPurchasesAndStatus() public override returns(Purchase[] purchasesGet, Status statusGet) {
        string name;
        uint64 quantity;
        uint64 date;
        bool   isBuy;
        uint   price;

        for((uint32 id, Purchase purchase) : purchases) {
            name = purchase.name;
            quantity = purchase.quantity;
            date = purchase.date;
            isBuy = purchase.isBuy;
            price = purchase.price;
            purchasesGet.push(Purchase(id, name, quantity, date, isBuy, price));
       }

        uint64 paidItems;
        uint64 unpaidItems;
        uint   totalPaid = 0;

        for((, Purchase purchase) : purchases) {
            if  (purchase.isBuy) {
                 paidItems++;
                 totalPaid += purchase.price;
            } else {
                 unpaidItems++;
            }
        }

        statusGet = Status(paidItems, unpaidItems, totalPaid);
    }

    function addPurchase(string name, uint64 quantity) public override onlyOwner {
        tvm.accept();

        count++;
        purchases[count] = Purchase(count, name, quantity ,now , false, 0);
    }

    function deletePurchase(uint32 id) public override onlyOwner {
        require(purchases.exists(id), 102);
        tvm.accept();

        delete purchases[id];
    }

    function buy(uint32 id, uint price) public override onlyOwner { 
        optional(Purchase) purchase = purchases.fetch(id);

        require(purchase.hasValue(), 102);
        tvm.accept();

        Purchase thisPurchase = purchase.get(); 

        thisPurchase.isBuy = true;
        thisPurchase.price = price;

        purchases[id] = thisPurchase;
    }
}