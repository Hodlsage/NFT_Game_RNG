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

import "./TomatoFarmhouse.sol";
import "../Common/SafeMath16.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoFarm 
// ----------------------------------------------------------------------------

contract TomatoFarm is TomatoFarmhouse {
    using SafeMath16 for uint16;
    uint8 constant MAX_LEVEL = 10; 
    uint8 constant MAX_TACTICS_PERCENTAGE = 80;
    uint8 constant MIN_TACTICS_PERCENTAGE = 20;
    uint8 constant MAX_GENE_LVL = 99;
    uint8 constant NUMBER_OF_SPECIAL_PEACEFUL_SKILL_CLASSES = 8; 

    function isCloningAllowed(uint8 _level, uint16 _dnaPoints) public view returns (bool) {
        return _level > 0 && _dnaPoints >= specs.dnaPoints(_level);
    }

    function _checkIfEnoughPoints(bool _isEnough) internal pure {
        require(_isEnough, "not enough points");
    }

    function _validateSpecialPeacefulAbilityClass(uint8 _class) internal pure {
        require(_class > 0 && _class < NUMBER_OF_SPECIAL_PEACEFUL_SKILL_CLASSES, "wrong class of special peaceful ability");
    }

    function _checkIfSpecialPeacefulAbilityAvailable(bool _isAvailable) internal pure {
        require(_isAvailable, "special peaceful ability selection is not available");
    }

    function _getBuff(uint256 _id, uint8 _class) internal view returns (uint32) {
        return _silo_.buffs(_id, _class);
    }

    function _getAllBuffs(uint256 _id) internal view returns (uint32[5]) {
        return [
            _getBuff(_id, 1),
            _getBuff(_id, 2),
            _getBuff(_id, 3),
            _getBuff(_id, 4),
            _getBuff(_id, 5)
        ];
    }

    function calculateMaxHealthAndRadiationWithBuffs(uint256 _id) public view returns (
        uint32 maxHealth,
        uint32 maxRadiation
    ) {
        (, , uint32 _stamina, , uint32 _intelligence) = _silo_.abilitys(_id);

        (
            maxHealth,
            maxRadiation
        ) = rancher.calculateHealthAndRadiation(
            _stamina,
            _intelligence,
            _getBuff(_id, 3), 
            _getBuff(_id, 5) 
        );
    }

    function getCurrentHealthAndRadiation(uint256 _id) public view returns (
        uint32 health,
        uint32 radiation,
        uint8 healthPercentage,
        uint8 radiationPercentage
    ) {
        (
            uint256 _timestamp,
            uint32 _remainingHealth,
            uint32 _remainingRadiation,
            uint32 _maxHealth,
            uint32 _maxRadiation
        ) = _silo_.healthAndRadiation(_id);

        (_maxHealth, _maxRadiation) = calculateMaxHealthAndRadiationWithBuffs(_id);

        uint256 _pastTime = now.sub(_timestamp); 
        (health, healthPercentage) = rancher.calculateCurrent(_pastTime, _maxHealth, _remainingHealth);
        (radiation, radiationPercentage) = rancher.calculateCurrent(_pastTime, _maxRadiation, _remainingRadiation);
    }

    function setReprimeingHealthAndRadiation(
        uint256 _id,
        uint32 _remainingHealth,
        uint32 _remainingRadiation
    ) external onlyFarmer {
        _silo_.setReprimeingHealthAndRadiation(_id, _remainingHealth, _remainingRadiation);
    }

    function increaseExperience(uint256 _id, uint256 _factor) external onlyFarmer {
        (
            uint8 _level,
            uint256 _experience,
            uint16 _dnaPoints
        ) = _silo_.levels(_id);
        uint8 _currentLevel = _level;
        if (_level < MAX_LEVEL) {
            (_level, _experience, _dnaPoints) = rancher.calculateExperience(_level, _experience, _dnaPoints, _factor);
            if (_level > _currentLevel) {
                _silo_.resetHealthAndRadiationTimestamp(_id);
            }
            if (_level == MAX_LEVEL) {
                _experience = 0;
            }
            _silo_.setLevel(_id, _level, _experience.toUint8(), _dnaPoints);
        }
    }

    function payDNAPointsForCloning(uint256 _id) external onlyFarmer {
        (
            uint8 _level,
            uint8 _experience,
            uint16 _dnaPoints
        ) = _silo_.levels(_id);

        _checkIfEnoughPoints(isCloningAllowed(_level, _dnaPoints));
        _dnaPoints = _dnaPoints.sub(specs.dnaPoints(_level));

        _silo_.setLevel(_id, _level, _experience, _dnaPoints);
    }

    function upgradeGenes(uint256 _id, uint16[10] _dnaPoints) external onlyFarmer {
        (
            uint8 _level,
            uint8 _experience,
            uint16 _availableDNAPoints
        ) = _silo_.levels(_id);

        uint16 _sum;
        uint256[4] memory _newComposedGenome;
        (
            _newComposedGenome,
            _sum
        ) = rancher.upgradeGenes(
            _silo_.getGenome(_id),
            _dnaPoints,
            _availableDNAPoints
        );

        require(_sum > 0, "DNA points were not used");

        _availableDNAPoints = _availableDNAPoints.sub(_sum);
        _silo_.setLevel(_id, _level, _experience, _availableDNAPoints);
        _silo_.setGenome(_id, _newComposedGenome);
        _silo_.setRarity(_id, rancher.calculateRarity(_newComposedGenome));
        _saveAbilitys(_id, _newComposedGenome);
    }

    function _saveAbilitys(uint256 _id, uint256[4] _genome) internal {
        (
            uint32 _attack,
            uint32 _defense,
            uint32 _stamina,
            uint32 _speed,
            uint32 _intelligence
        ) = rancher.calculateAbilitys(_genome);
        (
            uint32 _health,
            uint32 _radiation
        ) = rancher.calculateHealthAndRadiation(_stamina, _intelligence, 0, 0); 

        _silo_.setMaxHealthAndRadiation(_id, _health, _radiation);
        _silo_.setAbilitys(_id, _attack, _defense, _stamina, _speed, _intelligence);
    }

    function increaseWins(uint256 _id) external onlyFarmer {
        (uint16 _wins, ) = _silo_.clashs(_id);
        _silo_.setWins(_id, _wins.add(1));
    }

    function increaseDefeats(uint256 _id) external onlyFarmer {
        (, uint16 _defeats) = _silo_.clashs(_id);
        _silo_.setDefeats(_id, _defeats.add(1));
    }

    function setTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyFarmer {
        require(
            _melee >= MIN_TACTICS_PERCENTAGE &&
            _melee <= MAX_TACTICS_PERCENTAGE &&
            _attack >= MIN_TACTICS_PERCENTAGE &&
            _attack <= MAX_TACTICS_PERCENTAGE,
            "tactics value must be between 20 and 80"
        );
        _silo_.setTactics(_id, _melee, _attack);
    }

    function calculateSpecialPeacefulAbility(uint256 _id) public view returns (
        uint8 class,
        uint32 cost,
        uint32 effect
    ) {
        class = _silo_.specialPeacefulAbilitys(_id);
        if (class == 0) return;
        (
            uint32 _attack,
            uint32 _defense,
            uint32 _stamina,
            uint32 _speed,
            uint32 _intelligence
        ) = _silo_.abilitys(_id);

        (
            cost,
            effect
        ) = rancher.calculateSpecialPeacefulAbility(
            class,
            [_attack, _defense, _stamina, _speed, _intelligence],
            _getAllBuffs(_id)
        );
    }

    function setSpecialPeacefulAbility(uint256 _id, uint8 _class) external onlyFarmer {
        (uint8 _level, , ) = _silo_.levels(_id);
        uint8 _currentClass = _silo_.specialPeacefulAbilitys(_id);

        _checkIfSpecialPeacefulAbilityAvailable(_level == MAX_LEVEL);
        _validateSpecialPeacefulAbilityClass(_class);
        _checkIfSpecialPeacefulAbilityAvailable(_currentClass == 0);

        _silo_.setSpecialPeacefulAbility(_id, _class);
    }

    function _getBuffIndexBySpecialPeacefulAbilityClass(
        uint8 _class
    ) internal pure returns (uint8) {
        uint8[8] memory _buffsIndexes = [0, 1, 2, 3, 4, 5, 3, 5]; 
        return _buffsIndexes[_class];
    }

    function useSpecialPeacefulAbility(address _sender, uint256 _id, uint256 _target) external onlyFarmer {
        (
            uint8 _class,
            uint32 _cost,
            uint32 _effect
        ) = calculateSpecialPeacefulAbility(_id);
        (
            uint32 _health,
            uint32 _radiation, ,
        ) = getCurrentHealthAndRadiation(_id);

        _validateSpecialPeacefulAbilityClass(_class);
        _checkIfEnoughPoints(_radiation >= _cost);
        _silo_.setReprimeingHealthAndRadiation(_id, _health, _radiation.sub(_cost));
        _silo_.setBuff(_id, 5, 0);
        uint8 _buffIndexOfActiveAbility = _getBuffIndexBySpecialPeacefulAbilityClass(_class);
        _silo_.setBuff(_id, _buffIndexOfActiveAbility, 0);

        if (_class == 6 || _class == 7) { 
            (
                uint32 _targetHealth,
                uint32 _targetRadiation, ,
            ) = getCurrentHealthAndRadiation(_target);
            if (_class == 6) _targetHealth = _targetHealth.add(_effect); 
            if (_class == 7) _targetRadiation = _targetRadiation.add(_effect); 
            _silo_.setReprimeingHealthAndRadiation(
                _target,
                _targetHealth,
                _targetRadiation
            );
        } else { 
            if (_silo_.ownerOf(_target) != _sender) { 
                require(_getBuff(_target, _class) < _effect, "you can't buff alien tomato by lower effect");
            }
            _silo_.setBuff(_target, _class, _effect);
        }
    }

    function setBuff(uint256 _id, uint8 _class, uint32 _effect) external onlyFarmer {
        _silo_.setBuff(_id, _class, _effect);
    }

    function createTomato(
        address _sender,
        uint16 _generation,
        uint256[2] _donors,
        uint256[4] _genome,
        uint8[11] _tomatoTypes
    ) external onlyFarmer returns (uint256 newTomatoId) {
        newTomatoId = _silo_.push(_sender, _generation, _genome, _donors, _tomatoTypes);
        uint32 _rarity = rancher.calculateRarity(_genome);
        _silo_.setRarity(newTomatoId, _rarity);
        _silo_.setTactics(newTomatoId, 50, 50);
        _setAbilitysAndHealthAndRadiation(newTomatoId, _genome, _tomatoTypes);
    }

    function setName(
        uint256 _id,
        string _name
    ) external onlyFarmer returns (bytes32) {
        (
            bytes32 _initial, 
            bytes32 _lowercase 
        ) = rancher.checkAndConvertName(_name);
        require(!_silo_.existingNames(_lowercase), "name exists");
        require(_silo_.names(_id) == 0x0, "tomato already has a name");
        _silo_.setName(_id, _initial, _lowercase);
        return _initial;
    }
}
