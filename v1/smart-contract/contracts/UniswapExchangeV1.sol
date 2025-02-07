// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV1Exchange {
    IERC20 public token;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event TokenSwap(address indexed user, uint256 ethSold, uint256 tokenBought);
    event EthSwap(address indexed user, uint256 tokenSold, uint256 ethBought);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function addLiquidity(uint256 tokenAmount) public payable {
        require(msg.value > 0 && tokenAmount > 0, "Invalid amounts");
        token.transferFrom(msg.sender, address(this), tokenAmount);
        liquidity[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit LiquidityAdded(msg.sender, msg.value, tokenAmount);
    }

    function removeLiquidity(uint256 amount) public {
        require(liquidity[msg.sender] >= amount, "Insufficient liquidity");
        uint256 ethAmount = amount;
        uint256 tokenAmount = (token.balanceOf(address(this)) * amount) / totalLiquidity;

        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender, tokenAmount);

        liquidity[msg.sender] -= amount;
        totalLiquidity -= amount;
        emit LiquidityRemoved(msg.sender, ethAmount, tokenAmount);
    }

    function getPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) private pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * 997; // 0.3% fee
        return (inputAmountWithFee * outputReserve) / (inputReserve * 1000 + inputAmountWithFee);
    }

    function ethToTokenSwap() public payable {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokensBought = getPrice(msg.value, address(this).balance - msg.value, tokenReserve);
        token.transfer(msg.sender, tokensBought);
        emit TokenSwap(msg.sender, msg.value, tokensBought);
    }

    function tokenToEthSwap(uint256 tokenAmount) public {
        uint256 ethReserve = address(this).balance;
        uint256 ethBought = getPrice(tokenAmount, token.balanceOf(address(this)), ethReserve);
        token.transferFrom(msg.sender, address(this), tokenAmount);
        payable(msg.sender).transfer(ethBought);
        emit EthSwap(msg.sender, tokenAmount, ethBought);
    }
}
