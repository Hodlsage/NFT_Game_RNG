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

import "./Common/Name.sol";
import "./Common/Upgradable.sol";

// ----------------------------------------------------------------------------
// --- Contract User 
// ----------------------------------------------------------------------------

contract User is Upgradable, Name {
    mapping (bytes32 => bool) public existingNames;
    mapping (address => bytes32) public names;

    function getName(address _user) external view returns (bytes32) {
        return names[_user];
    }

    function setName(
        address _user,
        string _name
    ) external onlyFarmer returns (bytes32) {
        (
            bytes32 _initial, 
            bytes32 _lowercase 
        ) = _convertName(_name);
        require(!existingNames[_lowercase], "this username already exists");
        require(names[_user] == 0x0, "username is already set");
        names[_user] = _initial;
        existingNames[_lowercase] = true;
        return _initial;
    }
}
