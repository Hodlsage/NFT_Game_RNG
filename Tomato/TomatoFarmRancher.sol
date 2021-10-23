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

import "./TomatoUtils.sol";
import "./TomatoSpecs.sol";
import "../Common/Name.sol";
import "../Common/Upgradable.sol";
import "../Common/SafeMath16.sol";
import "../Common/SafeMath32.sol";
import "../Common/SafeMath256.sol";
import "../Common/SafeConvert.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoFarmRancher 
// ----------------------------------------------------------------------------

contract TomatoFarmRancher is Upgradable, TomatoUtils, Name {
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;
    using SafeConvert for uint32;
    using SafeConvert for uint256;

    TomatoSpecs specs;

    uint8 constant PERCENT_MULTIPLIER = 100;
    uint8 constant MAX_PERCENTAGE = 100;

    uint8 constant MAX_GENE_LVL = 99;

    uint8 constant MAX_LEVEL = 10;

    function _min(uint32 lth, uint32 rth) internal pure returns (uint32) {
        return lth > rth ? rth : lth;
    }

    function _calculateAbilityWithBuff(uint32 _ability, uint32 _buff) internal pure returns (uint32) {
        return _buff > 0 ? _ability.mul(_buff).div(100) : _ability; 
    }

    function _calculateRegenerationSpeed(uint32 _max) internal pure returns (uint32) {
        // because HP/radiation is multiplied by 100 so we need to have step multiplied by 100 too
        return _sqrt(_max.mul(100)).div(2).div(1 minutes); 
    }

    function calculateFullRegenerationTime(uint32 _max) external pure returns (uint32) { 
        return _max.div(_calculateRegenerationSpeed(_max));
    }

    function calculateCurrent(
        uint256 _pastTime,
        uint32 _max,
        uint32 _remaining
    ) external pure returns (
        uint32 current,
        uint8 percentage
    ) {
        if (_remaining >= _max) {
            return (_max, MAX_PERCENTAGE);
        }
        uint32 _speed = _calculateRegenerationSpeed(_max); 
        uint32 _secondsToFull = _max.sub(_remaining).div(_speed); 
        uint32 _secondsPassed = _pastTime.toUint32();
        if (_secondsPassed >= _secondsToFull.add(1)) {
            return (_max, MAX_PERCENTAGE); 
        }
        current = _min(_max, _remaining.add(_speed.mul(_secondsPassed)));
        percentage = _min(MAX_PERCENTAGE, current.mul(PERCENT_MULTIPLIER).div(_max)).toUint8();
    }

    function calculateHealthAndRadiation(
        uint32 _initStamina,
        uint32 _initIntelligence,
        uint32 _staminaBuff,
        uint32 _intelligenceBuff
    ) external pure returns (uint32 health, uint32 radiation) {
        uint32 _stamina = _initStamina;
        uint32 _intelligence = _initIntelligence;

        _stamina = _calculateAbilityWithBuff(_stamina, _staminaBuff);
        _intelligence = _calculateAbilityWithBuff(_intelligence, _intelligenceBuff);

        health = _stamina.mul(5);
        radiation = _intelligence.mul(5);
    }

    function _sqrt(uint32 x) internal pure returns (uint32 y) {
        uint32 z = x.add(1).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = x.div(z).add(z).div(2);
        }
    }

    function getSpecialClashAbilityTomatoType(uint8[11] _tomatoTypes, uint256 _random) external pure returns (uint8 abilityTomatoType) {
        uint256 _currentChance;
        for (uint8 i = 0; i < 11; i++) {
            _currentChance = _currentChance.add(_tomatoTypes[i]);
            if (_random < _currentChance) {
                abilityTomatoType = i;
                break;
            }
        }
    }

    function _getFarmhouseAbilityIndex(uint8 _tomatoType) internal pure returns (uint8) {
        uint8[5] memory _abilitys = [2, 0, 3, 1, 4];
        return _abilitys[_tomatoType];
    }

    function calculateSpecialClashAbility(
        uint8 _tomatoType,
        uint32[5] _abilitys
    ) external pure returns (
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        uint32 _farmhouseAbility = _abilitys[_getFarmhouseAbilityIndex(_tomatoType)];
        uint32 _intelligence = _abilitys[4];

        cost = _farmhouseAbility.mul(3);
        factor = _sqrt(_farmhouseAbility.div(3)).add(10).toUint8();
        chance = _sqrt(_intelligence).div(10).add(10).toUint8();
    }

    function _getAbilityIndexBySpecialPeacefulAbilityClass(
        uint8 _class
    ) internal pure returns (uint8) {
        uint8[8] memory _buffsIndexes = [0, 0, 1, 2, 3, 4, 2, 4]; 
        return _buffsIndexes[_class];
    }

    function calculateSpecialPeacefulAbility(
        uint8 _class,
        uint32[5] _abilitys,
        uint32[5] _buffs
    ) external pure returns (uint32 cost, uint32 effect) {
        uint32 _index = _getAbilityIndexBySpecialPeacefulAbilityClass(_class);
        uint32 _ability = _calculateAbilityWithBuff(_abilitys[_index], _buffs[_index]);
        if (_class == 6 || _class == 7) { 
            effect = _ability.mul(2);
        } else {
            effect = _sqrt(_ability.mul(10).div(3)).add(100);
        }
        cost = _ability.mul(3);
    }

    function _getGeneVarietyFactor(uint8 _type) internal pure returns (uint32 value) {
        if (_type == 0) value = 5;
        else if (_type < 5) value = 12;
        else if (_type < 8) value = 16;
        else value = 28;
    }

    function calculateRarity(uint256[4] _composedGenome) external pure returns (uint32 rarity) {
        uint8[16][10] memory _genome = _parseGenome(_composedGenome);
        uint32 _geneVarietyFactor; 
        uint8 _strengthCoefficient; 
        uint8 _geneLevel;
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 4; j++) {
                _geneVarietyFactor = _getGeneVarietyFactor(_genome[i][(j * 4) + 1]);
                _strengthCoefficient = (_genome[i][(j * 4) + 3] == 0) ? 7 : 10; 
                _geneLevel = _genome[i][(j * 4) + 2];
                rarity = rarity.add(_geneVarietyFactor.mul(_geneLevel).mul(_strengthCoefficient));
            }
        }
    }

    function calculateAbilitys(
        uint256[4] _composed
    ) external view returns (
        uint32, uint32, uint32, uint32, uint32
    ) {
        uint8[30] memory _activeGenes = _getActiveGenes(_parseGenome(_composed));
        uint8[5] memory _tomatoTypeFactors;
        uint8[5] memory _bodyPartFactors;
        uint8[5] memory _geneTypeFactors;
        uint8 _level;
        uint32[5] memory _abilitys;

        for (uint8 i = 0; i < 10; i++) {
            _bodyPartFactors = specs.bodyPartsFactors(i);
            _tomatoTypeFactors = specs.tomatoTypesFactors(_activeGenes[i * 3]);
            _geneTypeFactors = specs.geneTypesFactors(_activeGenes[i * 3 + 1]);
            _level = _activeGenes[i * 3 + 2];

            for (uint8 j = 0; j < 5; j++) {
                _abilitys[j] = _abilitys[j].add(uint32(_tomatoTypeFactors[j]).mul(_bodyPartFactors[j]).mul(_geneTypeFactors[j]).mul(_level));
            }
        }
        return (_abilitys[0], _abilitys[1], _abilitys[2], _abilitys[3], _abilitys[4]);
    }

    function calculateExperience(
        uint8 _level,
        uint256 _experience,
        uint16 _dnaPoints,
        uint256 _factor
    ) external view returns (
        uint8 level,
        uint256 experience,
        uint16 dnaPoints
    ) {
        level = _level;
        experience = _experience;
        dnaPoints = _dnaPoints;

        uint8 _expToNextLvl;
        experience = experience.add(uint256(specs.clashPoints()).mul(_factor).div(10));
        _expToNextLvl = specs.experienceToNextLevel(level);
        while (experience >= _expToNextLvl && level < MAX_LEVEL) {
            experience = experience.sub(_expToNextLvl);
            level = level.add(1);
            dnaPoints = dnaPoints.add(specs.dnaPoints(level));
            if (level < MAX_LEVEL) {
                _expToNextLvl = specs.experienceToNextLevel(level);
            }
        }
    }

    function checkAndConvertName(string _input) external pure returns(bytes32, bytes32) {
        return _convertName(_input);
    }

    function _checkIfEnoughDNAPoints(bool _isEnough) internal pure {
        require(_isEnough, "not enough DNA points for upgrade");
    }

    function upgradeGenes(
        uint256[4] _composedGenome,
        uint16[10] _dnaPoints,
        uint16 _availableDNAPoints
    ) external view returns (
        uint256[4],
        uint16
    ) {
        uint16 _sum;
        uint8 _i;
        for (_i = 0; _i < 10; _i++) {
            _checkIfEnoughDNAPoints(_dnaPoints[_i] <= _availableDNAPoints);
            _sum = _sum.add(_dnaPoints[_i]);
        }
        _checkIfEnoughDNAPoints(_sum <= _availableDNAPoints);
        _sum = 0;

        uint8[16][10] memory _genome = _parseGenome(_composedGenome);
        uint8 _geneLevelIndex;
        uint8 _geneLevel;
        uint16 _geneUpgradeDNAPoints;
        uint8 _levelsToUpgrade;
        uint16 _specificDNAPoints;
        for (_i = 0; _i < 10; _i++) {
            _specificDNAPoints = _dnaPoints[_i]; 
            if (_specificDNAPoints > 0) {
                _geneLevelIndex = _getActiveGeneIndex(_genome[_i]).mul(4).add(2); 
                _geneLevel = _genome[_i][_geneLevelIndex]; 
                if (_geneLevel < MAX_GENE_LVL) {
                    _geneUpgradeDNAPoints = specs.geneUpgradeDNAPoints(_geneLevel);
                    while (_specificDNAPoints >= _geneUpgradeDNAPoints && _geneLevel.add(_levelsToUpgrade) < MAX_GENE_LVL) {
                        _levelsToUpgrade = _levelsToUpgrade.add(1);
                        _specificDNAPoints = _specificDNAPoints.sub(_geneUpgradeDNAPoints);
                        _sum = _sum.add(_geneUpgradeDNAPoints); // the sum of used points
                        if (_geneLevel.add(_levelsToUpgrade) < MAX_GENE_LVL) {
                            _geneUpgradeDNAPoints = specs.geneUpgradeDNAPoints(_geneLevel.add(_levelsToUpgrade));
                        }
                    }
                    _genome[_i][_geneLevelIndex] = _geneLevel.add(_levelsToUpgrade); 
                    _levelsToUpgrade = 0;
                }
            }
        }
        return (_composeGenome(_genome), _sum);
    }

    function getActiveGenes(uint256[4] _composed) external pure returns (uint8[30]) {
        uint8[16][10] memory _genome = _parseGenome(_composed);
        return _getActiveGenes(_genome);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        specs = TomatoSpecs(_newDependencies[0]);
    }
}
