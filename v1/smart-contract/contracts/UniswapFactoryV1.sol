// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./UniswapExchangeV1.sol";

constract UniswapFactoryV1{
    mapping(address => address) public tokenToExchange;
    address[] public allExchanges;

    event ExchangeCreated(address indexed token, address indexed exchange);

    function createExchange(address token) public returns (address) {
        require(tokenToExchange[token] == address(0), "Exchange already exists");

        UniswapExchangeV1 exchange = new UniswapExchangeV1(token);
        tokenToExchange[token] = address(exchange);
        allExchanges.push(address(exchange));

        emit ExchangeCreated(token, address(exchange));
        return address(exchange);
    }

    function getExchange(address token) public view returns (address) {
        return tokenToExchange[token];
    } 
}