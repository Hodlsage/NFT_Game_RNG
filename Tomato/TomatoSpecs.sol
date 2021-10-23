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

// ----------------------------------------------------------------------------
// --- Contract TomatoSpecs 
// ----------------------------------------------------------------------------

contract TomatoSpecs is Upgradable {
    uint8[5][11] _tomatoTypesFactors_;
    uint8[5][10] _bodyPartsFactors_;
    uint8[5][10] _geneTypesFactors_;
    uint8[10] _experienceToNextLevel_;
    uint16[11] _dnaPoints_;
    uint8 _clashPoints_;
    uint8[99] _geneUpgradeDNAPoints_;

    function tomatoTypesFactors(uint8 _index) external view returns (uint8[5]) {
        return _tomatoTypesFactors_[_index];
    }

    function bodyPartsFactors(uint8 _index) external view returns (uint8[5]) {
        return _bodyPartsFactors_[_index];
    }

    function geneTypesFactors(uint8 _index) external view returns (uint8[5]) {
        return _geneTypesFactors_[_index];
    }

    function experienceToNextLevel(uint8 _index) external view returns (uint8) {
        return _experienceToNextLevel_[_index];
    }

    function dnaPoints(uint8 _index) external view returns (uint16) {
        return _dnaPoints_[_index];
    }

    function geneUpgradeDNAPoints(uint8 _index) external view returns (uint8) {
        return _geneUpgradeDNAPoints_[_index];
    }

    function getTomatoTypesFactors() external view returns (uint8[55] result) {
        uint8 _index;
        for (uint8 i = 0; i < 11; i++) {
            for (uint8 j = 0; j < 5; j++) {
                result[_index] = _tomatoTypesFactors_[i][j];
                _index++;
            }
        }
    }

    function _transformArray(uint8[5][10] _array) internal pure returns (uint8[50] result) {
        uint8 _index;
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 5; j++) {
                result[_index] = _array[i][j];
                _index++;
            }
        }
    }

    function getBodyPartsFactors() external view returns (uint8[50]) {
        return _transformArray(_bodyPartsFactors_);
    }

    function getGeneTypesFactors() external view returns (uint8[50]) {
        return _transformArray(_geneTypesFactors_);
    }

    function getExperienceToNextLevel() external view returns (uint8[10]) {
        return _experienceToNextLevel_;
    }

    function getDNAPoints() external view returns (uint16[11]) {
        return _dnaPoints_;
    }

    function clashPoints() external view returns (uint8) {
        return _clashPoints_;
    }

    function getGeneUpgradeDNAPoints() external view returns (uint8[99]) {
        return _geneUpgradeDNAPoints_;
    }

    function setTomatoTypesFactors(uint8[5][11] _types) external onlyOwner {
        _tomatoTypesFactors_ = _types;
    }

    function setBodyPartsFactors(uint8[5][10] _bodyParts) external onlyOwner {
        _bodyPartsFactors_ = _bodyParts;
    }

    function setGeneTypesFactors(uint8[5][10] _geneTypes) external onlyOwner {
        _geneTypesFactors_ = _geneTypes;
    }

    function setLevelUpPoints(
        uint8[10] _experienceToNextLevel,
        uint16[11] _dnaPoints,
        uint8 _clashPoints
    ) external onlyOwner {
        _experienceToNextLevel_ = _experienceToNextLevel;
        _dnaPoints_ = _dnaPoints;
        _clashPoints_ = _clashPoints;
    }

    function setGeneUpgradeDNAPoints(uint8[99] _points) external onlyOwner {
        _geneUpgradeDNAPoints_ = _points;
    }
}
