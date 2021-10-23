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

import "./Common/Upgradable.sol";
import "./Common/Random.sol";
import "./Common/SafeMath8.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract Soil 
// ----------------------------------------------------------------------------

contract Soil is Upgradable {
    using SafeMath8 for uint8;
    using SafeMath256 for uint256;
    Random random;
    uint256[2] seeds;
    uint256 lastBlockNumber;
    bool isFull;
    mapping (uint256 => bool) public inSoil;

    function add(
        uint256 _id
    ) external onlyFarmer returns (
        bool isSprouted,
        uint256 sproutedId,
        uint256 randomForSeedOpening
    ) {
        require(!inSoil[_id], "seed is already in soil");
        require(block.number > lastBlockNumber, "only 1 seed in a block");
        lastBlockNumber = block.number;
        inSoil[_id] = true;

        if (isFull) {
            isSprouted = true;
            sproutedId = seeds[0];
            randomForSeedOpening = random.random(2**256 - 1);
            seeds[0] = seeds[1];
            seeds[1] = _id;
            delete inSoil[sproutedId];
        } else {
            uint8 _index = seeds[0] == 0 ? 0 : 1;
            seeds[_index] = _id;
            if (_index == 1) {
                isFull = true;
            }
        }
    }

    function getSeeds() external view returns (uint256[2]) {
        return seeds;
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        random = Random(_newDependencies[0]);
    }
}
