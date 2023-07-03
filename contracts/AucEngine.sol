// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AucEngine {
    // владелец площадки/контракта, не аукциона, который будет получать определенную комиссию
    address public owner;
    // сколько длится аукцион. Значение по умочанию !
    uint constant DURATION = 2 days;
    // комиссия в 10 процентов. Сколько заведение/площадка берет от выручки
    uint constant FEE = 10; 
    
    struct Auction {
        // человек, который продает что-то
        address payable seller;
        // изначальная цена, максимальная цена, за которую мы хотим продавать
        uint startingPrice;
        // за сколько товар ушел
        uint finalPrice; 
        // время начала аукциона
        uint startAt;
        // время окончания аукциона
        uint endsAt;
        // насколько цена будет падать
        uint discountRate;
        // описание предмета
        string item;
        // закончился ли аукцион ?
        bool stopped;
    }

    Auction[] public auctions;

    event AuctionCreated(uint index, string itemName, uint startingPrice, uint duration);
    event AuctionEnded(uint index, uint finalPrice, address winner);

    constructor(){
        // Владелец смарт-контракта и соотвественно платформы. Будет получать прибыль
        owner = msg.sender;
    }

    function createAuction(uint _startingPrice, uint _discountRate, string calldata _item, uint _duration) external {
        uint duration = _duration == 0 ? DURATION : _duration;

        require(_startingPrice >= _discountRate * duration, "incorrect starting price");

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            discountRate: _discountRate,
            startAt: block.timestamp, // now
            endsAt: block.timestamp + duration,
            item: _item,
            stopped: false
        });

        auctions.push(newAuction);

        emit AuctionCreated(auctions.length - 1, _item, _startingPrice, duration);
    }


    function getPriceFor(uint index) public view returns(uint){
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "stopped!");
        uint elapsed = block.timestamp - cAuction.startAt;
        uint discount = cAuction.discountRate * elapsed;
        return cAuction.startingPrice - discount;
    }


    // function stop(uint index) {
    //     Auction storage cAuction = auctions[index];
    //     cAuction.stopped = true;
    // }

    function buy(uint index) external payable {
        Auction storage cAuction = auctions[index];
        require(!cAuction.stopped, "stopped!");
        require(block.timestamp < cAuction.endsAt, "ended!");
        uint cPrice = getPriceFor(index);
        require(msg.value >= cPrice, "not enough funds!");
        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;
        uint refund = msg.value -cPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        // Продавец получает сумму за вычетом 10 процентов
        // Товар стоил = 500
        // Комиссия 10
        // Итого 500 - ((500 * 10) / 100) = 500 - 50 = 450
        cAuction.seller.transfer(
            cPrice - ((cPrice * FEE) / 100)
        ); 

        emit AuctionEnded(index, cPrice, msg.sender);

    }
}