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

// ----------------------------------------------------------------------------
// --- Contract TomatoModel 
// ----------------------------------------------------------------------------

contract TomatoModel {

    struct HealthAndRadiation {
        uint256 timestamp; 
        uint32 remainingHealth; 
        uint32 remainingRadiation; 
        uint32 maxHealth;
        uint32 maxRadiation;
    }

    struct Level {
        uint8 level; 
        uint8 experience; 
        uint16 dnaPoints; 
    }

    struct Tactics {
        uint8 melee; 
        uint8 attack;
    }

    struct Clashs {
        uint16 wins;
        uint16 defeats;
    }

    struct Abilitys {
        uint32 attack;
        uint32 defense;
        uint32 stamina;
        uint32 speed;
        uint32 intelligence;
    }

    struct Tomato {
        uint16 generation;
        uint256[4] genome; 
        uint256[2] donors;
        uint8[11] types; 
        uint256 birth;
    }

}
