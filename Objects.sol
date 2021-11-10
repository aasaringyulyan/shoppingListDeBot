pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase {
    uint32 id;
    string name;
    uint64 quantity;
    uint64 date;
    bool   isBuy;
    uint   price;
}

struct Status {
    uint64 paidItems;
    uint64 unpaidItems;
    uint   totalPaid;
}
