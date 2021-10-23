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
import "./Tomato/TomatoFarm.sol";
import "./Tomato/TomatoRanking.sol";
import "./Tomato/TomatoFarmhand.sol";
import "./Tomato/TomatoMutation.sol";
import "./Seed/SeedFarm.sol";
import "./Soil.sol";
import "./Common/SafeMath8.sol";
import "./Common/SafeMath16.sol";
import "./Common/SafeMath32.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract Farm 
// ----------------------------------------------------------------------------

contract Farm is Upgradable {
    using SafeMath8 for uint8;
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;

    TomatoFarm tomatoFarm;
    TomatoFarmhand tomatoFarmhand;
    TomatoMutation tomatoMutation;
    SeedFarm seedFarm;
    TomatoRanking ranking;
    Soil soil;

    uint256 public peacefulAbilityCooldown;
    mapping (uint256 => uint256) public lastPeacefulAbilitysUsageDates;

    constructor() public {
        peacefulAbilityCooldown = 14 days;
    }

    function _checkPossibilityOfUsingSpecialPeacefulAbility(uint256 _id) internal view {
        uint256 _availableFrom = lastPeacefulAbilitysUsageDates[_id].add(peacefulAbilityCooldown);
        require(_availableFrom <= now, "special peaceful ability is not yet available");
    }

    function setCooldown(uint256 _value) external onlyOwner {
        peacefulAbilityCooldown = _value;
    }

    function _max(uint16 lth, uint16 rth) internal pure returns (uint16) {
        if (lth > rth) {
            return lth;
        } else {
            return rth;
        }
    }

    function createSeed(
        address _sender,
        uint8 _tomatoType
    ) external onlyFarmer returns (uint256) {
        return seedFarm.create(_sender, [uint256(0), uint256(0)], _tomatoType);
    }

    function sendToSoil(
        uint256 _id
    ) external onlyFarmer returns (
        bool isSprouted,
        uint256 newTomatoId,
        uint256 sproutedId,
        address owner
    ) {
        uint256 _randomForSeedOpening;
        (isSprouted, sproutedId, _randomForSeedOpening) = soil.add(_id);
        if (isSprouted) {
            owner = seedFarm.ownerOf(sproutedId);
            newTomatoId = openSeed(owner, sproutedId, _randomForSeedOpening);
        }
    }

    function openSeed(
        address _owner,
        uint256 _seedId,
        uint256 _random
    ) internal returns (uint256 newTomatoId) {
        uint256[2] memory _donors;
        uint8 _tomatoType;
        (_donors, _tomatoType) = seedFarm.get(_seedId);

        uint256[4] memory _genome;
        uint8[11] memory _tomatoTypesArray;
        uint16 _generation;
        if (_donors[0] == 0 && _donors[1] == 0) {
            _generation = 0;
            _genome = tomatoMutation.createGenomeForGenesis(_tomatoType, _random);
            _tomatoTypesArray[_tomatoType] = 40; // 40 genes of 1 type
        } else {
            uint256[4] memory _a_donorGenome = tomatoFarmhand.getComposedGenome(_donors[0]);
            uint256[4] memory _b_donorGenome = tomatoFarmhand.getComposedGenome(_donors[1]);
            (_genome, _tomatoTypesArray) = tomatoMutation.createGenome(_donors, _a_donorGenome, _b_donorGenome, _random);
            _generation = _max(
                tomatoFarmhand.getGeneration(_donors[0]),
                tomatoFarmhand.getGeneration(_donors[1])
            ).add(1);
        }

        newTomatoId = tomatoFarm.createTomato(_owner, _generation, _donors, _genome, _tomatoTypesArray);
        seedFarm.remove(_owner, _seedId);

        uint32 _rarity = tomatoFarmhand.getRarity(newTomatoId);
        ranking.update(newTomatoId, _rarity);
    }

    function cultivar(
        address _sender,
        uint256 _a_donorId,
        uint256 _b_donorId
    ) external onlyFarmer returns (uint256) {
        tomatoFarm.payDNAPointsForCloning(_a_donorId);
        tomatoFarm.payDNAPointsForCloning(_b_donorId);
        return seedFarm.create(_sender, [_a_donorId, _b_donorId], 0);
    }

    function setTomatoReprimeingHealthAndRadiation(uint256 _id, uint32 _health, uint32 _radiation) external onlyFarmer {
        return tomatoFarm.setReprimeingHealthAndRadiation(_id, _health, _radiation);
    }

    function increaseTomatoExperience(uint256 _id, uint256 _factor) external onlyFarmer {
        tomatoFarm.increaseExperience(_id, _factor);
    }

    function upgradeTomatoGenes(uint256 _id, uint16[10] _dnaPoints) external onlyFarmer {
        tomatoFarm.upgradeGenes(_id, _dnaPoints);

        uint32 _rarity = tomatoFarmhand.getRarity(_id);
        ranking.update(_id, _rarity);
    }

    function increaseTomatoWins(uint256 _id) external onlyFarmer {
        tomatoFarm.increaseWins(_id);
    }

    function increaseTomatoDefeats(uint256 _id) external onlyFarmer {
        tomatoFarm.increaseDefeats(_id);
    }

    function setTomatoTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyFarmer {
        tomatoFarm.setTactics(_id, _melee, _attack);
    }

    function setTomatoName(uint256 _id, string _name) external onlyFarmer returns (bytes32) {
        return tomatoFarm.setName(_id, _name);
    }

    function setTomatoSpecialPeacefulAbility(uint256 _id, uint8 _class) external onlyFarmer {
        tomatoFarm.setSpecialPeacefulAbility(_id, _class);
    }

    function useTomatoSpecialPeacefulAbility(
        address _sender,
        uint256 _id,
        uint256 _target
    ) external onlyFarmer {
        _checkPossibilityOfUsingSpecialPeacefulAbility(_id);
        tomatoFarm.useSpecialPeacefulAbility(_sender, _id, _target);
        lastPeacefulAbilitysUsageDates[_id] = now;
    }

    function resetTomatoBuffs(uint256 _id) external onlyFarmer {
        tomatoFarm.setBuff(_id, 1, 0); // attack
        tomatoFarm.setBuff(_id, 2, 0); // defense
        tomatoFarm.setBuff(_id, 3, 0); // stamina
        tomatoFarm.setBuff(_id, 4, 0); // speed
        tomatoFarm.setBuff(_id, 5, 0); // intelligence
    }

    function updateRankingRewardTime() external onlyFarmer {
        return ranking.updateRewardTime();
    }

    function getTomatoFullRegenerationTime(uint256 _id) external view returns (uint32 time) {
        return tomatoFarmhand.getFullRegenerationTime(_id);
    }

    function isSeedOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return seedFarm.isOwner(_user, _tokenId);
    }

    function isSeedInSoil(uint256 _id) external view returns (bool) {
        return soil.inSoil(_id);
    }

    function getSeedsInSoil() external view returns (uint256[2]) {
        return soil.getSeeds();
    }

    function getSeed(uint256 _id) external view returns (uint16, uint32, uint256[2], uint8[11], uint8[11]) {
        uint256[2] memory donors;
        uint8 _tomatoType;
        (donors, _tomatoType) = seedFarm.get(_id);

        uint8[11] memory a_donorTomatoTypes;
        uint8[11] memory b_donorTomatoTypes;
        uint32 rarity;
        uint16 gen;
        if (donors[0] == 0 && donors[1] == 0) {
            a_donorTomatoTypes[_tomatoType] = 100;
            b_donorTomatoTypes[_tomatoType] = 100;
            rarity = 3600;
        } else {
            a_donorTomatoTypes = tomatoFarmhand.getTomatoTypes(donors[0]);
            b_donorTomatoTypes = tomatoFarmhand.getTomatoTypes(donors[1]);
            rarity = tomatoFarmhand.getRarity(donors[0]).add(tomatoFarmhand.getRarity(donors[1])).div(2);
            uint16 _a_donorGeneration = tomatoFarmhand.getGeneration(donors[0]);
            uint16 _b_donorGeneration = tomatoFarmhand.getGeneration(donors[1]);
            gen = _max(_a_donorGeneration, _b_donorGeneration).add(1);
        }
        return (gen, rarity, donors, a_donorTomatoTypes, b_donorTomatoTypes);
    }

    function getTomatoChildren(uint256 _id) external view returns (
        uint256[10] tomatosChildren,
        uint256[10] seedsChildren
    ) {
        uint8 _counter;
        uint256[2] memory _donors;
        uint256 i;
        for (i = _id.add(1); i <= tomatoFarmhand.getAmount() && _counter < 10; i++) {
            _donors = tomatoFarmhand.getDonors(i);
            if (_donors[0] == _id || _donors[1] == _id) {
                tomatosChildren[_counter] = i;
                _counter = _counter.add(1);
            }
        }
        _counter = 0;
        uint256[] memory seeds = seedFarm.getAllSeeds();
        for (i = 0; i < seeds.length && _counter < 10; i++) {
            (_donors, ) = seedFarm.get(seeds[i]);
            if (_donors[0] == _id || _donors[1] == _id) {
                seedsChildren[_counter] = seeds[i];
                _counter = _counter.add(1);
            }
        }
    }

    function getTomatosFromRanking() external view returns (uint256[10]) {
        return ranking.getTomatosFromRanking();
    }

    function getRankingRewards(
        uint256 _remainingBean
    ) external view returns (
        uint256[10]
    ) {
        return ranking.getRewards(_remainingBean);
    }

    function getRankingRewardDate() external view returns (uint256, uint256) {
        return ranking.getDate();
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);
        tomatoFarm = TomatoFarm(_newDependencies[0]);
        tomatoFarmhand = TomatoFarmhand(_newDependencies[1]);
        tomatoMutation = TomatoMutation(_newDependencies[2]);
        seedFarm = SeedFarm(_newDependencies[3]);
        ranking = TomatoRanking(_newDependencies[4]);
        soil = Soil(_newDependencies[5]);
    }
}
