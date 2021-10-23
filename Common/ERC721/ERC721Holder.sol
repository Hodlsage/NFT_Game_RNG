pragma solidity 0.4.25;

// ----------------------------------------------------------------------------
// --- Name        : CropClash - [Crop SHARE]
// --- Symbol      : Format - {CRP}
// --- Total supply: Generated from minter accounts
// --- @Legal      : 
// --- @title for 01101101 01111001 01101100 01101111 01110110 01100101
// --- BlockHaus.Company - EJS32 - 2018-2021
// --- @dev pragma solidity version:0.8.0+commit.661d1103
// --- SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

import "./ERC721Receiver.sol";

// ----------------------------------------------------------------------------
// --- Contract ERC721Holder 
// ----------------------------------------------------------------------------

contract ERC721Holder is ERC721Receiver {
    function onERC721Received(address, address, uint256, bytes) public returns(bytes4) {
        return this.onERC721Received.selector;
    }
}
