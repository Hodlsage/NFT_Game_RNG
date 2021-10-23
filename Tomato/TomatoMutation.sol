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
import "./TomatoUtils.sol";
import "../Farmhand.sol";
import "../Common/SafeMath16.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoMutation 
// ----------------------------------------------------------------------------

contract TomatoMutation is Upgradable, TomatoUtils {
    using SafeMath16 for uint16;
    using SafeMath256 for uint256;

    Farmhand farmhand;

    uint8 constant MUTATION_CHANCE = 1; 
    uint16[7] genesWeights = [300, 240, 220, 190, 25, 15, 10];

    function _chooseGen(uint8 _random, uint8[16] _array1, uint8[16] _array2) internal pure returns (uint8[16] gen) {
        uint8 x = _random.div(2);
        uint8 y = _random % 2;
        for (uint8 j = 0; j < 2; j++) {
            for (uint8 k = 0; k < 4; k++) {
                gen[k.add(j.mul(8))] = _array1[k.add(j.mul(4)).add(x.mul(8))];
                gen[k.add(j.mul(2).add(1).mul(4))] = _array2[k.add(j.mul(4)).add(y.mul(8))];
            }
        }
    }

    function _getDonors(uint256 _id) internal view returns (uint256[2]) {
        if (_id != 0) {
            return farmhand.getTomatoDonors(_id);
        }
        return [uint256(0), uint256(0)];
    }

    function _checkIncloning(uint256[2] memory _donors) internal view returns (uint8 chance) {
        uint8 _relatives;
        uint8 i;
        uint256[2] memory _donors_1_1 = _getDonors(_donors[0]);
        uint256[2] memory _donors_1_2 = _getDonors(_donors[1]);

        if (_donors_1_1[0] != 0 && (_donors_1_1[0] == _donors_1_2[0] || _donors_1_1[0] == _donors_1_2[1])) {
            _relatives = _relatives.add(1);
        }
        
        if (_donors_1_1[1] != 0 && (_donors_1_1[1] == _donors_1_2[0] || _donors_1_1[1] == _donors_1_2[1])) {
            _relatives = _relatives.add(1);
        }

        if (_donors[0] == _donors_1_2[0] || _donors[0] == _donors_1_2[1]) {
            _relatives = _relatives.add(1);
        }
        
        if (_donors[1] == _donors_1_1[0] || _donors[1] == _donors_1_1[1]) {
            _relatives = _relatives.add(1);
        }
        
        if (_relatives >= 2) return 8; 
        
        if (_relatives == 1) chance = 7; 
        
        uint256[12] memory _ancestors;
        uint256[2] memory _donors_2_1 = _getDonors(_donors_1_1[0]);
        uint256[2] memory _donors_2_2 = _getDonors(_donors_1_1[1]);
        uint256[2] memory _donors_2_3 = _getDonors(_donors_1_2[0]);
        uint256[2] memory _donors_2_4 = _getDonors(_donors_1_2[1]);
        for (i = 0; i < 2; i++) {
            _ancestors[i.mul(6).add(0)] = _donors_1_1[i];
            _ancestors[i.mul(6).add(1)] = _donors_1_2[i];
            _ancestors[i.mul(6).add(2)] = _donors_2_1[i];
            _ancestors[i.mul(6).add(3)] = _donors_2_2[i];
            _ancestors[i.mul(6).add(4)] = _donors_2_3[i];
            _ancestors[i.mul(6).add(5)] = _donors_2_4[i];
        }
        for (i = 0; i < 12; i++) {
            for (uint8 j = i.add(1); j < 12; j++) {
                if (_ancestors[i] != 0 && _ancestors[i] == _ancestors[j]) {
                    _relatives = _relatives.add(1);
                    _ancestors[j] = 0;
                }
                if (_relatives > 2 || (_relatives == 2 && chance == 0)) return 8;
            }
        }
        if (_relatives == 1 && chance == 0) return 5; 
    }

    function _mutateGene(uint8[16] _gene, uint8 _genType) internal pure returns (uint8[16]) {
        uint8 _index = _getActiveGeneIndex(_gene);
        _gene[_index.mul(4).add(1)] = _genType; 
        _gene[_index.mul(4).add(2)] = 1; 
        return _gene;
    }

    function _calculateGen(
        uint8[16] _a_donorGen,
        uint8[16] _b_donorGen,
        uint8 _random
    ) internal pure returns (uint8[16] gen) {
        if (_random < 4) {
            return _chooseGen(_random, _a_donorGen, _a_donorGen);
        } else if (_random < 8) {
            return _chooseGen(_random.sub(4), _a_donorGen, _b_donorGen);
        } else if (_random < 12) {
            return _chooseGen(_random.sub(8), _b_donorGen, _b_donorGen);
        } else {
            return _chooseGen(_random.sub(12), _b_donorGen, _a_donorGen);
        }
    }

    function _calculateGenome(
        uint8[16][10] memory _a_donorGenome,
        uint8[16][10] memory _b_donorGenome,
        uint8 _uglinessChance,
        uint256 _seed_
    ) internal pure returns (uint8[16][10] genome) {
        uint256 _seed = _seed_;
        uint256 _random;
        uint8 _mutationChance = _uglinessChance == 0 ? MUTATION_CHANCE : _uglinessChance;
        uint8 _geneType;
        for (uint8 i = 0; i < 10; i++) {
            (_random, _seed) = _getSpecialRandom(_seed, 4);
            genome[i] = _calculateGen(_a_donorGenome[i], _b_donorGenome[i], (_random % 16).toUint8());
            (_random, _seed) = _getSpecialRandom(_seed, 1);
            if (_random < _mutationChance) {
                _geneType = 0;
                if (_uglinessChance == 0) {
                    (_random, _seed) = _getSpecialRandom(_seed, 2);
                    _geneType = (_random % 9).add(1).toUint8(); 
                }
                genome[i] = _mutateGene(genome[i], _geneType);
            }
        }
    }

    function _calculateTomatoTypes(uint8[16][10] _genome) internal pure returns (uint8[11] tomatoTypesArray) {
        uint8 _tomatoType;
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 4; j++) {
                _tomatoType = _genome[i][j.mul(4)];
                tomatoTypesArray[_tomatoType] = tomatoTypesArray[_tomatoType].add(1);
            }
        }
    }

    function createGenome(
        uint256[2] _donors,
        uint256[4] _a_donorGenome,
        uint256[4] _b_donorGenome,
        uint256 _seed
    ) external view returns (
        uint256[4] genome,
        uint8[11] tomatoTypes
    ) {
        uint8 _uglinessChance = _checkIncloning(_donors);
        uint8[16][10] memory _parsedGenome = _calculateGenome(
            _parseGenome(_a_donorGenome),
            _parseGenome(_b_donorGenome),
            _uglinessChance,
            _seed
        );
        genome = _composeGenome(_parsedGenome);
        tomatoTypes = _calculateTomatoTypes(_parsedGenome);
    }

    function _getWeightedRandom(uint256 _random) internal view returns (uint8) {
        uint16 _weight;
        for (uint8 i = 1; i < 7; i++) {
            _weight = _weight.add(genesWeights[i.sub(1)]);
            if (_random < _weight) return i;
        }
        return 7;
    }

    function _generateGen(uint8 _tomatoType, uint256 _random) internal view returns (uint8[16]) {
        uint8 _geneType = _getWeightedRandom(_random); 
        return [
            _tomatoType, _geneType, 1, 1,
            _tomatoType, _geneType, 1, 0,
            _tomatoType, _geneType, 1, 0,
            _tomatoType, _geneType, 1, 0
        ];
    }

    // max 4 digits
    function _getSpecialRandom(
        uint256 _seed_,
        uint8 _digits
    ) internal pure returns (uint256, uint256) {
        uint256 _farmhouse = 10;
        uint256 _seed = _seed_;
        uint256 _random = _seed % _farmhouse.pow(_digits);
        _seed = _seed.div(_farmhouse.pow(_digits));
        return (_random, _seed);
    }

    function createGenomeForGenesis(uint8 _tomatoType, uint256 _seed_) external view returns (uint256[4]) {
        uint256 _seed = _seed_;
        uint8[16][10] memory _genome;
        uint256 _random;
        for (uint8 i = 0; i < 10; i++) {
            (_random, _seed) = _getSpecialRandom(_seed, 3);
            _genome[i] = _generateGen(_tomatoType, _random);
        }
        return _composeGenome(_genome);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        farmhand = Farmhand(_newDependencies[0]);
    }
}
