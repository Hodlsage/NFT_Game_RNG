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

import "../Common/ERC721/ERC721Token.sol";
import "./TomatoModel.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoSilo 
// ----------------------------------------------------------------------------

contract TomatoSilo is TomatoModel, ERC721Token {
    Tomato[] public tomatos;
    mapping (bytes32 => bool) public existingNames;
    mapping (uint256 => bytes32) public names;
    mapping (uint256 => HealthAndRadiation) public healthAndRadiation;
    mapping (uint256 => Tactics) public tactics;
    mapping (uint256 => Clashs) public clashs;
    mapping (uint256 => Abilitys) public abilitys;
    mapping (uint256 => Level) public levels;
    mapping (uint256 => uint32) public rarity; 
    mapping (uint256 => uint8) public specialAttacks;
    mapping (uint256 => uint8) public specialDefenses;
    mapping (uint256 => uint8) public specialPeacefulAbilitys;
    mapping (uint256 => mapping (uint8 => uint32)) public buffs;

    constructor(string _name, string _symbol) public ERC721Token(_name, _symbol) {
        tomatos.length = 1; 
    }

    function length() external view returns (uint256) {
        return tomatos.length;
    }

    function getGenome(uint256 _id) external view returns (uint256[4]) {
        return tomatos[_id].genome;
    }

    function getDonors(uint256 _id) external view returns (uint256[2]) {
        return tomatos[_id].donors;
    }

    function getTomatoTypes(uint256 _id) external view returns (uint8[11]) {
        return tomatos[_id].types;
    }

    function push(
        address _sender,
        uint16 _generation,
        uint256[4] _genome,
        uint256[2] _donors,
        uint8[11] _types
    ) public onlyFarmer returns (uint256 id) {
        id = tomatos.push(Tomato({
            generation: _generation,
            genome: _genome,
            donors: _donors,
            types: _types,
            birth: now 
        })).sub(1);
        _mint(_sender, id);
    }

    function setName(
        uint256 _id,
        bytes32 _name,
        bytes32 _lowercase
    ) external onlyFarmer {
        names[_id] = _name;
        existingNames[_lowercase] = true;
    }

    function setTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyFarmer {
        tactics[_id].melee = _melee;
        tactics[_id].attack = _attack;
    }

    function setWins(uint256 _id, uint16 _value) external onlyFarmer {
        clashs[_id].wins = _value;
    }

    function setDefeats(uint256 _id, uint16 _value) external onlyFarmer {
        clashs[_id].defeats = _value;
    }

    function setMaxHealthAndRadiation(
        uint256 _id,
        uint32 _maxHealth,
        uint32 _maxRadiation
    ) external onlyFarmer {
        healthAndRadiation[_id].maxHealth = _maxHealth;
        healthAndRadiation[_id].maxRadiation = _maxRadiation;
    }

    function setReprimeingHealthAndRadiation(
        uint256 _id,
        uint32 _remainingHealth,
        uint32 _remainingRadiation
    ) external onlyFarmer {
        healthAndRadiation[_id].timestamp = now; 
        healthAndRadiation[_id].remainingHealth = _remainingHealth;
        healthAndRadiation[_id].remainingRadiation = _remainingRadiation;
    }

    function resetHealthAndRadiationTimestamp(uint256 _id) external onlyFarmer {
        healthAndRadiation[_id].timestamp = 0;
    }

    function setAbilitys(
        uint256 _id,
        uint32 _attack,
        uint32 _defense,
        uint32 _stamina,
        uint32 _speed,
        uint32 _intelligence
    ) external onlyFarmer {
        abilitys[_id].attack = _attack;
        abilitys[_id].defense = _defense;
        abilitys[_id].stamina = _stamina;
        abilitys[_id].speed = _speed;
        abilitys[_id].intelligence = _intelligence;
    }

    function setLevel(uint256 _id, uint8 _level, uint8 _experience, uint16 _dnaPoints) external onlyFarmer {
        levels[_id].level = _level;
        levels[_id].experience = _experience;
        levels[_id].dnaPoints = _dnaPoints;
    }

    function setRarity(uint256 _id, uint32 _rarity) external onlyFarmer {
        rarity[_id] = _rarity;
    }

    function setGenome(uint256 _id, uint256[4] _genome) external onlyFarmer {
        tomatos[_id].genome = _genome;
    }

    function setSpecialAttack(
        uint256 _id,
        uint8 _tomatoType
    ) external onlyFarmer {
        specialAttacks[_id] = _tomatoType;
    }

    function setSpecialDefense(
        uint256 _id,
        uint8 _tomatoType
    ) external onlyFarmer {
        specialDefenses[_id] = _tomatoType;
    }

    function setSpecialPeacefulAbility(
        uint256 _id,
        uint8 _class
    ) external onlyFarmer {
        specialPeacefulAbilitys[_id] = _class;
    }

    function setBuff(uint256 _id, uint8 _class, uint32 _effect) external onlyFarmer {
        buffs[_id][_class] = _effect;
    }
}
