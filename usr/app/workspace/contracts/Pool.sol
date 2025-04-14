// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./LPToken.sol";

contract Pool is LPToken, ReentrancyGuard {
    IERC20 immutable i_token0;
    IERC20 immutable i_token1;

    address immutable i_token0_address;
    address immutable i_token1_address;

    uint256 constant INITIAL_RATIO = 2; // token0:token1 = 1:2

    mapping(address => uint256) public tokenBalances;

    event AddedLiquidity(
        uint256 indexed lpToken,
        address token0,
        uint256 indexed amount0,
        address token1,
        uint256 indexed amount1
    );

    event Swapped(
        address tokenIn,
        uint256 indexed amountIn,
        address tokenOut,
        uint256 indexed amountOut
    );

    constructor(address token0, address token1) LPToken("LPToken", "LPT") {
        i_token0 = IERC20(token0);
        i_token1 = IERC20(token1);

        i_token0_address = token0;
        i_token1_address = token1;

        // Initialize tokenBalances for each token
        tokenBalances[token0] = 0;
        tokenBalances[token1] = 0;
    }

    // Added getReserves function expected by your tests
    function getReserves() public view returns (uint256 reserve0, uint256 reserve1) {
        reserve0 = tokenBalances[i_token0_address];
        reserve1 = tokenBalances[i_token1_address];
    }

    function getAmountOut(address tokenIn, uint256 amountIn, address tokenOut) public view returns (uint256) {
        uint256 balanceOut = tokenBalances[tokenOut];
        uint256 balanceIn = tokenBalances[tokenIn];
        uint256 amountOut = (balanceOut * amountIn) / (balanceIn + amountIn);
        return amountOut;
    }

    function swap(address tokenIn, uint256 amountIn, address tokenOut) public nonReentrant {
        // Input validity checks
        require(tokenIn != tokenOut, "Same tokens");
        require(tokenIn == i_token0_address || tokenIn == i_token1_address, "Invalid token");
        require(tokenOut == i_token0_address || tokenOut == i_token1_address, "Invalid token");
        require(amountIn > 0, "Zero amount");

        uint256 amountOut = getAmountOut(tokenIn, amountIn, tokenOut);

        // Transfer tokens from sender to pool
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "Swap Failed");
        // Transfer tokens from pool to sender
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "Swap Failed");

        // Update pool balances
        tokenBalances[tokenIn] += amountIn;
        tokenBalances[tokenOut] -= amountOut;

        emit Swapped(tokenIn, amountIn, tokenOut, amountOut);
    }

    function addLiquidity(uint256 amount0) public nonReentrant {
        require(amount0 > 0, "Amount must be greater than 0");

        // Calculate required amount of token1 and LP token amount
        uint256 amount1 = getRequiredAmount1(amount0);
        uint256 amountLP;
        if (totalSupply() > 0) {
            amountLP = (amount0 * totalSupply()) / tokenBalances[i_token0_address];
        } else {
            amountLP = amount0;
        }
        _mint(msg.sender, amountLP);

        // Deposit token0
        require(i_token0.transferFrom(msg.sender, address(this), amount0), "Transfer Alpha failed");
        tokenBalances[i_token0_address] += amount0;

        // Deposit token1
        require(i_token1.transferFrom(msg.sender, address(this), amount1), "Transfer Beta failed");
        tokenBalances[i_token1_address] += amount1;

        emit AddedLiquidity(amountLP, i_token0_address, amount0, i_token1_address, amount1);
    }

    function getRequiredAmount1(uint256 amount0) public view returns (uint256) {
        uint256 balance0 = tokenBalances[i_token0_address];
        uint256 balance1 = tokenBalances[i_token1_address];

        if (balance0 == 0 || balance1 == 0) {
            return amount0 * INITIAL_RATIO;
        }
        return (amount0 * balance1) / balance0;
    }
}