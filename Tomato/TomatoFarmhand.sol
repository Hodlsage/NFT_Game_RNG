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

import "./TomatoSilo.sol";
import "./TomatoFarm.sol";
import "./TomatoFarmRancher.sol";
import "../Common/Upgradable.sol";
import "../Common/SafeMath32.sol";
import "../Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoFarmhand 
// ----------------------------------------------------------------------------

contract TomatoFarmhand is Upgradable {
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;

    TomatoSilo _silo_;
    TomatoFarm tomatoFarm;
    TomatoFarmRancher rancher;

    uint256 constant BEAN_DECIMALS = 10 ** 18;

    uint256 constant TOMATO_NAME_2_LETTERS_PRICE = 100000 * BEAN_DECIMALS;
    uint256 constant TOMATO_NAME_3_LETTERS_PRICE = 10000 * BEAN_DECIMALS;
    uint256 constant TOMATO_NAME_4_LETTERS_PRICE = 1000 * BEAN_DECIMALS;

    function _checkExistence(uint256 _id) internal view {
        require(_silo_.exists(_id), "tomato doesn't exist");
    }

    function _min(uint32 lth, uint32 rth) internal pure returns (uint32) {
        return lth > rth ? rth : lth;
    }

    function getAmount() external view returns (uint256) {
        return _silo_.length().sub(1);
    }

    function isOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return _user == _silo_.ownerOf(_tokenId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _silo_.ownerOf(_tokenId);
    }

    function getGenome(uint256 _id) public view returns (uint8[30]) {
        _checkExistence(_id);
        return rancher.getActiveGenes(_silo_.getGenome(_id));
    }

    function getComposedGenome(uint256 _id) external view returns (uint256[4]) {
        _checkExistence(_id);
        return _silo_.getGenome(_id);
    }

    function getAbilitys(uint256 _id) external view returns (uint32, uint32, uint32, uint32, uint32) {
        _checkExistence(_id);
        return _silo_.abilitys(_id);
    }

    function getRarity(uint256 _id) public view returns (uint32) {
        _checkExistence(_id);
        return _silo_.rarity(_id);
    }

    function getLevel(uint256 _id) public view returns (uint8 level) {
        _checkExistence(_id);
        (level, , ) = _silo_.levels(_id);
    }

    function getHealthAndRadiation(uint256 _id) external view returns (
        uint256 timestamp,
        uint32 remainingHealth,
        uint32 remainingRadiation,
        uint32 maxHealth,
        uint32 maxRadiation
    ) {
        _checkExistence(_id);
        (
            timestamp,
            remainingHealth,
            remainingRadiation,
            maxHealth,
            maxRadiation
        ) = _silo_.healthAndRadiation(_id);
        (maxHealth, maxRadiation) = tomatoFarm.calculateMaxHealthAndRadiationWithBuffs(_id);

        remainingHealth = _min(remainingHealth, maxHealth);
        remainingRadiation = _min(remainingRadiation, maxRadiation);
    }

    function getCurrentHealthAndRadiation(uint256 _id) external view returns (
        uint32, uint32, uint8, uint8
    ) {
        _checkExistence(_id);
        return tomatoFarm.getCurrentHealthAndRadiation(_id);
    }

    function getFullRegenerationTime(uint256 _id) external view returns (uint32) {
        _checkExistence(_id);
        ( , , , uint32 _maxHealth, ) = _silo_.healthAndRadiation(_id);
        return rancher.calculateFullRegenerationTime(_maxHealth);
    }

    function getTomatoTypes(uint256 _id) external view returns (uint8[11]) {
        _checkExistence(_id);
        return _silo_.getTomatoTypes(_id);
    }

    function getProfile(uint256 _id) external view returns (
        bytes32 name,
        uint16 generation,
        uint256 birth,
        uint8 level,
        uint8 experience,
        uint16 dnaPoints,
        bool isCloningAllowed,
        uint32 rarity
    ) {
        _checkExistence(_id);
        name = _silo_.names(_id);
        (level, experience, dnaPoints) = _silo_.levels(_id);
        isCloningAllowed = tomatoFarm.isCloningAllowed(level, dnaPoints);
        (generation, birth) = _silo_.tomatos(_id);
        rarity = _silo_.rarity(_id);

    }

    function getGeneration(uint256 _id) external view returns (uint16 generation) {
        _checkExistence(_id);
        (generation, ) = _silo_.tomatos(_id);
    }

    function isCloningAllowed(uint256 _id) external view returns (bool) {
        _checkExistence(_id);
        uint8 _level;
        uint16 _dnaPoints;
        (_level, , _dnaPoints) = _silo_.levels(_id);
        return tomatoFarm.isCloningAllowed(_level, _dnaPoints);
    }

    function getTactics(uint256 _id) external view returns (uint8, uint8) {
        _checkExistence(_id);
        return _silo_.tactics(_id);
    }

    function getClashs(uint256 _id) external view returns (uint16, uint16) {
        _checkExistence(_id);
        return _silo_.clashs(_id);
    }

    function getDonors(uint256 _id) external view returns (uint256[2]) {
        _checkExistence(_id);
        return _silo_.getDonors(_id);
    }

    function _getSpecialClashAbility(uint256 _id, uint8 _tomatoType) internal view returns (
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        _checkExistence(_id);
        uint32 _attack;
        uint32 _defense;
        uint32 _stamina;
        uint32 _speed;
        uint32 _intelligence;
        (_attack, _defense, _stamina, _speed, _intelligence) = _silo_.abilitys(_id);
        return rancher.calculateSpecialClashAbility(_tomatoType, [_attack, _defense, _stamina, _speed, _intelligence]);
    }

    function getSpecialAttack(uint256 _id) external view returns (
        uint8 tomatoType,
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        _checkExistence(_id);
        tomatoType = _silo_.specialAttacks(_id);
        (cost, factor, chance) = _getSpecialClashAbility(_id, tomatoType);
    }

    function getSpecialDefense(uint256 _id) external view returns (
        uint8 tomatoType,
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        _checkExistence(_id);
        tomatoType = _silo_.specialDefenses(_id);
        (cost, factor, chance) = _getSpecialClashAbility(_id, tomatoType);
    }

    function getSpecialPeacefulAbility(uint256 _id) external view returns (uint8, uint32, uint32) {
        _checkExistence(_id);
        return tomatoFarm.calculateSpecialPeacefulAbility(_id);
    }

    function getBuffs(uint256 _id) external view returns (uint32[5]) {
        _checkExistence(_id);
        return [
            _silo_.buffs(_id, 1), // attack
            _silo_.buffs(_id, 2), // defense
            _silo_.buffs(_id, 3), // stamina
            _silo_.buffs(_id, 4), // speed
            _silo_.buffs(_id, 5)  // intelligence
        ];
    }

    function getTomatoStrength(uint256 _id) external view returns (uint32 sum) {
        _checkExistence(_id);
        uint32 _attack;
        uint32 _defense;
        uint32 _stamina;
        uint32 _speed;
        uint32 _intelligence;
        (_attack, _defense, _stamina, _speed, _intelligence) = _silo_.abilitys(_id);
        sum = sum.add(_attack.mul(69));
        sum = sum.add(_defense.mul(217));
        sum = sum.add(_stamina.mul(232));
        sum = sum.add(_speed.mul(114));
        sum = sum.add(_intelligence.mul(151));
        sum = sum.div(100);
    }

    function getTomatoNamePriceByLength(uint256 _length) external pure returns (uint256) {
        if (_length == 2) {
            return TOMATO_NAME_2_LETTERS_PRICE;
        } else if (_length == 3) {
            return TOMATO_NAME_3_LETTERS_PRICE;
        } else {
            return TOMATO_NAME_4_LETTERS_PRICE;
        }
    }

    function getTomatoNamePrices() external pure returns (uint8[3] lengths, uint256[3] prices) {
        lengths = [2, 3, 4];
        prices = [
            TOMATO_NAME_2_LETTERS_PRICE,
            TOMATO_NAME_3_LETTERS_PRICE,
            TOMATO_NAME_4_LETTERS_PRICE
        ];
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        _silo_ = TomatoSilo(_newDependencies[0]);
        tomatoFarm = TomatoFarm(_newDependencies[1]);
        rancher = TomatoFarmRancher(_newDependencies[2]);
    }
}
