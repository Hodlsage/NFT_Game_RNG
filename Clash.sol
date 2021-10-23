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
import "./Farmhand.sol";
import "./Common/SafeMath8.sol";
import "./Common/SafeMath32.sol";
import "./Common/SafeMath256.sol";
import "./Common/SafeConvert.sol";

// ----------------------------------------------------------------------------
// --- Contract Clash 
// ----------------------------------------------------------------------------

contract Clash is Upgradable {
    using SafeMath8 for uint8;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;
    using SafeConvert for uint256;

    Farmhand farmhand;

    struct Tomato {
        uint256 id;
        uint8 attackChance;
        uint8 meleeChance;
        uint32 health;
        uint32 radiation;
        uint32 speed;
        uint32 attack;
        uint32 defense;
        uint32 specialAttackCost;
        uint8 specialAttackFactor;
        uint8 specialAttackChance;
        uint32 specialDefenseCost;
        uint8 specialDefenseFactor;
        uint8 specialDefenseChance;
        bool blocking;
        bool specialBlocking;
    }

    uint8 constant __FLOAT_NUMBER_MULTIPLY = 10;
    uint8 constant DISTANCE_ATTACK_WEAK__ = 8;
    uint8 constant DEFENSE_SUCCESS_MULTIPLY__ = 10;
    uint8 constant DEFENSE_FAIL_MULTIPLY__ = 2;
    uint8 constant FALLBACK_SPEED_FACTOR__ = 7;

    uint32 constant MAX_MELEE_ATTACK_DISTANCE = 100;
    uint32 constant MIN_RANGE_ATTACK_DISTANCE = 300;

    uint8 constant MAX_TURNS = 70;

    uint8 constant TOMATO_TYPE_FACTOR = 5;

    uint16 constant TOMATO_TYPE_MULTIPLY = 1600;

    uint8 constant PERCENT_MULTIPLIER = 100;

    uint256 clashsCounter;

    function _getRandomNumber(
        uint256 _initialSeed,
        uint256 _currentSeed_
    ) internal pure returns(uint8, uint256) {
        uint256 _currentSeed = _currentSeed_;
        if (_currentSeed == 0) {
            _currentSeed = _initialSeed;
        }
        uint8 _random = (_currentSeed % 100).toUint8();
        _currentSeed = _currentSeed.div(100);
        return (_random, _currentSeed);
    }

    function _safeSub(uint32 a, uint32 b) internal pure returns(uint32) {
        return b > a ? 0 : a.sub(b);
    }

    function _multiplyByFloatNumber(uint32 _number, uint8 _multiplier) internal pure returns (uint32) {
        return _number.mul(_multiplier).div(__FLOAT_NUMBER_MULTIPLY);
    }

    function _calculatePercentage(uint32 _part, uint32 _full) internal pure returns (uint32) {
        return _part.mul(PERCENT_MULTIPLIER).div(_full);
    }

    function _calculateTomatoTypeMultiply(uint8[11] _attackerTypesArray, uint8[11] _defenderTypesArray) internal pure returns (uint32) {
        uint32 tomatoTypeSumMultiply = 0;
        uint8 _currentDefenderType;
        uint32 _tomatoTypeMultiply;

        for (uint8 _attackerType = 0; _attackerType < _attackerTypesArray.length; _attackerType++) {
            if (_attackerTypesArray[_attackerType] != 0) {
                for (uint8 _defenderType = 0; _defenderType < _defenderTypesArray.length; _defenderType++) {
                    if (_defenderTypesArray[_defenderType] != 0) {
                        _currentDefenderType = _defenderType;

                        if (_currentDefenderType < _attackerType) {
                            _currentDefenderType = _currentDefenderType.add(_defenderTypesArray.length.toUint8());
                        }

                        if (_currentDefenderType.add(_attackerType).add(1) % 2 == 0) {
                            _tomatoTypeMultiply = _attackerTypesArray[_attackerType];
                            _tomatoTypeMultiply = _tomatoTypeMultiply.mul(_defenderTypesArray[_defenderType]);
                            tomatoTypeSumMultiply = tomatoTypeSumMultiply.add(_tomatoTypeMultiply);
                        }
                    }
                }
            }
        }

        return _multiplyByFloatNumber(tomatoTypeSumMultiply, TOMATO_TYPE_FACTOR).add(TOMATO_TYPE_MULTIPLY);
    }

    function _initFarmhouseTomato(
        uint256 _id,
        uint256 _opponentId,
        uint8 _meleeChance,
        uint8 _attackChance,
        bool _isCrop
    ) internal view returns (Tomato) {
        uint32 _health;
        uint32 _radiation;
        if (_isCrop) {
            (_health, _radiation) = farmhand.getTomatoMaxHealthAndRadiation(_id);
        } else {
            (_health, _radiation, , ) = farmhand.getTomatoCurrentHealthAndRadiation(_id);
        }

        if (_meleeChance == 0 || _attackChance == 0) {
            (_meleeChance, _attackChance) = farmhand.getTomatoTactics(_id);
        }
        uint8[11] memory _attackerTypes = farmhand.getTomatoTypes(_id);
        uint8[11] memory _opponentTypes = farmhand.getTomatoTypes(_opponentId);
        uint32 _attack;
        uint32 _defense;
        uint32 _speed;
        (_attack, _defense, , _speed, ) = farmhand.getTomatoAbilitys(_id);

        return Tomato({
            id: _id,
            attackChance: _attackChance,
            meleeChance: _meleeChance,
            health: _health,
            radiation: _radiation,
            speed: _speed,
            attack: _attack.mul(_calculateTomatoTypeMultiply(_attackerTypes, _opponentTypes)).div(TOMATO_TYPE_MULTIPLY),
            defense: _defense,
            specialAttackCost: 0,
            specialAttackFactor: 0,
            specialAttackChance: 0,
            specialDefenseCost: 0,
            specialDefenseFactor: 0,
            specialDefenseChance: 0,
            blocking: false,
            specialBlocking: false
        });
    }

    function _initTomato(
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics,
        bool _isCrop
    ) internal view returns (Tomato tomato) {
        tomato = _initFarmhouseTomato(_id, _opponentId, _tactics[0], _tactics[1], _isCrop);

        uint32 _specialAttackCost;
        uint8 _specialAttackFactor;
        uint8 _specialAttackChance;
        uint32 _specialDefenseCost;
        uint8 _specialDefenseFactor;
        uint8 _specialDefenseChance;

        ( , _specialAttackCost, _specialAttackFactor, _specialAttackChance) = farmhand.getTomatoSpecialAttack(_id);
        ( , _specialDefenseCost, _specialDefenseFactor, _specialDefenseChance) = farmhand.getTomatoSpecialDefense(_id);

        tomato.specialAttackCost = _specialAttackCost;
        tomato.specialAttackFactor = _specialAttackFactor;
        tomato.specialAttackChance = _specialAttackChance;
        tomato.specialDefenseCost = _specialDefenseCost;
        tomato.specialDefenseFactor = _specialDefenseFactor;
        tomato.specialDefenseChance = _specialDefenseChance;

        uint32[5] memory _buffs = farmhand.getTomatoBuffs(_id);

        if (_buffs[0] > 0) {
            tomato.attack = tomato.attack.mul(_buffs[0]).div(100);
        }
        if (_buffs[1] > 0) {
            tomato.defense = tomato.defense.mul(_buffs[1]).div(100);
        }
        if (_buffs[3] > 0) {
            tomato.speed = tomato.speed.mul(_buffs[3]).div(100);
        }
    }

    function _resetBlocking(Tomato tomato) internal pure returns (Tomato) {
        tomato.blocking = false;
        tomato.specialBlocking = false;

        return tomato;
    }

    function _attack(
        uint8 turnId,
        bool isMelee,
        Tomato attacker,
        Tomato opponent,
        uint8 _random
    ) internal pure returns (
        Tomato,
        Tomato
    ) {

        uint8 _turnModificator = 10;
        if (turnId > 30) {
            uint256 _modif = uint256(turnId).sub(30);
            _modif = _modif.mul(50);
            _modif = _modif.div(40);
            _modif = _modif.add(10);
            _turnModificator = _modif.toUint8();
        }

        bool isSpecial = _random < _multiplyByFloatNumber(attacker.specialAttackChance, _turnModificator);

        uint32 damage = _multiplyByFloatNumber(attacker.attack, _turnModificator);

        if (isSpecial && attacker.radiation >= attacker.specialAttackCost) {
            attacker.radiation = attacker.radiation.sub(attacker.specialAttackCost);
            damage = _multiplyByFloatNumber(damage, attacker.specialAttackFactor);
        }

        if (!isMelee) {
            damage = _multiplyByFloatNumber(damage, DISTANCE_ATTACK_WEAK__);
        }

        uint32 defense = opponent.defense;

        if (opponent.blocking) {
            defense = _multiplyByFloatNumber(defense, DEFENSE_SUCCESS_MULTIPLY__);

            if (opponent.specialBlocking) {
                defense = _multiplyByFloatNumber(defense, opponent.specialDefenseFactor);
            }
        } else {
            defense = _multiplyByFloatNumber(defense, DEFENSE_FAIL_MULTIPLY__);
        }

        if (damage > defense) {
            opponent.health = _safeSub(opponent.health, damage.sub(defense));
        } else if (isMelee) {
            attacker.health = _safeSub(attacker.health, defense.sub(damage));
        }

        return (attacker, opponent);
    }

    function _defense(
        Tomato attacker,
        uint256 initialSeed,
        uint256 currentSeed
    ) internal pure returns (
        Tomato,
        uint256
    ) {
        uint8 specialRandom;

        (specialRandom, currentSeed) = _getRandomNumber(initialSeed, currentSeed);
        bool isSpecial = specialRandom < attacker.specialDefenseChance;

        if (isSpecial && attacker.radiation >= attacker.specialDefenseCost) {
            attacker.radiation = attacker.radiation.sub(attacker.specialDefenseCost);
            attacker.specialBlocking = true;
        }
        attacker.blocking = true;

        return (attacker, currentSeed);
    }

    function _turn(
        uint8 turnId,
        uint256 initialSeed,
        uint256 currentSeed,
        uint32 distance,
        Tomato currentTomato,
        Tomato currentEnemy
    ) internal view returns (
        Tomato winner,
        Tomato looser
    ) {
        uint8 rand;

        (rand, currentSeed) = _getRandomNumber(initialSeed, currentSeed);
        bool isAttack = rand < currentTomato.attackChance;

        if (isAttack) {
            (rand, currentSeed) = _getRandomNumber(initialSeed, currentSeed);
            bool isMelee = rand < currentTomato.meleeChance;

            if (isMelee && distance > MAX_MELEE_ATTACK_DISTANCE) {
                distance = _safeSub(distance, currentTomato.speed);
            } else if (!isMelee && distance < MIN_RANGE_ATTACK_DISTANCE) {
                distance = distance.add(_multiplyByFloatNumber(currentTomato.speed, FALLBACK_SPEED_FACTOR__));
            } else {
                (rand, currentSeed) = _getRandomNumber(initialSeed, currentSeed);
                (currentTomato, currentEnemy) = _attack(turnId, isMelee, currentTomato, currentEnemy, rand);
            }
        } else {
            (currentTomato, currentSeed) = _defense(currentTomato, initialSeed, currentSeed);
        }

        currentEnemy = _resetBlocking(currentEnemy);

        if (currentTomato.health == 0) {
            return (currentEnemy, currentTomato);
        } else if (currentEnemy.health == 0) {
            return (currentTomato, currentEnemy);
        } else if (turnId < MAX_TURNS) {
            return _turn(turnId.add(1), initialSeed, currentSeed, distance, currentEnemy, currentTomato);
        } else {
            uint32 _tomatoMaxHealth;
            uint32 _enemyMaxHealth;
            (_tomatoMaxHealth, ) = farmhand.getTomatoMaxHealthAndRadiation(currentTomato.id);
            (_enemyMaxHealth, ) = farmhand.getTomatoMaxHealthAndRadiation(currentEnemy.id);
            if (_calculatePercentage(currentTomato.health, _tomatoMaxHealth) >= _calculatePercentage(currentEnemy.health, _enemyMaxHealth)) {
                return (currentTomato, currentEnemy);
            } else {
                return (currentEnemy, currentTomato);
            }
        }
    }

    function _start(
        uint256 _firstTomatoId,
        uint256 _secondTomatoId,
        uint8[2] _firstTactics,
        uint8[2] _secondTactics,
        uint256 _seed,
        bool _isCrop
    ) internal view returns (
        uint256[2],
        uint32,
        uint32,
        uint32,
        uint32
    ) {
        Tomato memory _firstTomato = _initTomato(_firstTomatoId, _secondTomatoId, _firstTactics, _isCrop);
        Tomato memory _secondTomato = _initTomato(_secondTomatoId, _firstTomatoId, _secondTactics, _isCrop);

        if (_firstTomato.speed >= _secondTomato.speed) {
            (_firstTomato, _secondTomato) = _turn(1, _seed, _seed, MAX_MELEE_ATTACK_DISTANCE, _firstTomato, _secondTomato);
        } else {
            (_firstTomato, _secondTomato) = _turn(1, _seed, _seed, MAX_MELEE_ATTACK_DISTANCE, _secondTomato, _firstTomato);
        }

        return (
            [_firstTomato.id,  _secondTomato.id],
            _firstTomato.health,
            _firstTomato.radiation,
            _secondTomato.health,
            _secondTomato.radiation
        );
    }

    function start(
        uint256 _firstTomatoId,
        uint256 _secondTomatoId,
        uint8[2] _tactics,
        uint8[2] _tactics2,
        uint256 _seed,
        bool _isCrop
    ) external onlyFarmer returns (
        uint256[2] winnerLooserIds,
        uint32 winnerHealth,
        uint32 winnerRadiation,
        uint32 looserHealth,
        uint32 looserRadiation,
        uint256 clashId
    ) {

        (
            winnerLooserIds,
            winnerHealth,
            winnerRadiation,
            looserHealth,
            looserRadiation
        ) = _start(
            _firstTomatoId,
            _secondTomatoId,
            _tactics,
            _tactics2,
            _seed,
            _isCrop
        );

        clashId = clashsCounter;
        clashsCounter = clashsCounter.add(1);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        farmhand = Farmhand(_newDependencies[0]);
    }
}
