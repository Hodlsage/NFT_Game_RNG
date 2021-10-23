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

import "../Common/Upgradable.sol";
import "../Common/Random.sol";
import "./TomatoSilo.sol";
import "./TomatoSpecs.sol";
import "./TomatoFarmRancher.sol";
import "../Common/SafeMath32.sol";
import "../Common/SafeMath256.sol";
import "../Common/SafeConvert.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoFarmhouse 
// ----------------------------------------------------------------------------

contract TomatoFarmhouse is Upgradable {
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;
    using SafeConvert for uint32;
    using SafeConvert for uint256;

    TomatoSilo _silo_;
    TomatoSpecs specs;
    TomatoFarmRancher rancher;
    Random random;

    function _identifySpecialClashAbilitys(
        uint256 _id,
        uint8[11] _tomatoTypes
    ) internal {
        uint256 _randomSeed = random.random(10000); 
        uint256 _attackRandom = _randomSeed % 100; 
        uint256 _defenseRandom = _randomSeed / 100; 

        _attackRandom = _attackRandom.mul(4).div(10);
        _defenseRandom = _defenseRandom.mul(4).div(10);

        uint8 _attackType = rancher.getSpecialClashAbilityTomatoType(_tomatoTypes, _attackRandom);
        uint8 _defenseType = rancher.getSpecialClashAbilityTomatoType(_tomatoTypes, _defenseRandom);

        _silo_.setSpecialAttack(_id, _attackType);
        _silo_.setSpecialDefense(_id, _defenseType);
    }

    function _setAbilitysAndHealthAndRadiation(uint256 _id, uint256[4] _genome, uint8[11] _tomatoTypes) internal {
        (
            uint32 _attack,
            uint32 _defense,
            uint32 _stamina,
            uint32 _speed,
            uint32 _intelligence
        ) = rancher.calculateAbilitys(_genome);

        _silo_.setAbilitys(_id, _attack, _defense, _stamina, _speed, _intelligence);

        _identifySpecialClashAbilitys(_id, _tomatoTypes);

        (
            uint32 _health,
            uint32 _radiation
        ) = rancher.calculateHealthAndRadiation(_stamina, _intelligence, 0, 0);
        _silo_.setMaxHealthAndRadiation(_id, _health, _radiation);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        _silo_ = TomatoSilo(_newDependencies[0]);
        specs = TomatoSpecs(_newDependencies[1]);
        rancher = TomatoFarmRancher(_newDependencies[2]);
        random = Random(_newDependencies[3]);
    }
}
