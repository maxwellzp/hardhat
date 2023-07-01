// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventApp {
    // require
    // revert
    // assert

    address owner;

    // Событие
    event Paid(address indexed _from, uint _amount, uint _timestamp);

    constructor() {
        // владелец тот, кто разворачивает смарт-контракт
        owner = msg.sender;
    }

    // Функция receive() вызывается автоматические если на смартконтракт приходят 
    // какие-то средства
    receive() external payable {
        pay();
    }

    function pay() public  payable  {
        // создать событие
        // события сохраняются в специально журнале, рядом с блокчейном
        // дешевое хранение информации
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

    address demoAddr; // 0x000000000000000000

    // можно создавать свои собственные модификаторы вроде payable
    modifier onlyOwner(address _to) {
        require(msg.sender == owner, "you are not an owner");
        require(_to != address(0), "incorrect address");
        _;
    }

    function withdrawal(address payable _to) external onlyOwner(_to) {
        // ты не можешь снять деньги, если ты не владелец
        // require(msg.sender == owner, "you are not an owner");

        // для реверта нужно писать условие самостоятельно, в отличие от require
        // revert("you are not an owner");

        //if (msg.sender != owner) {
        //    revert("you are not an owner");
        //} else {
        //    // ...
        //}

        // Создает панику с стандартным сообщением
        // assert(msg.sender != owner);


        _to.transfer(address(this).balance);
    }
}