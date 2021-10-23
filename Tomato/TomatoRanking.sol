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
import "../Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract TomatoRanking 
// ----------------------------------------------------------------------------

contract TomatoRanking is Upgradable {
    using SafeMath256 for uint256;

    struct Ranking {
        uint256 id;
        uint32 rarity;
    }

    Ranking[10] ranking;

    uint256 constant REWARDED_TOMATOS_AMOUNT = 10;
    uint256 constant DISTRIBUTING_FRACTION_OF_REMAINING_BEAN = 10000;
    uint256 rewardPeriod = 24 hours;
    uint256 lastRewardDate;

    constructor() public {
        lastRewardDate = now; 
    }

    function update(uint256 _id, uint32 _rarity) external onlyFarmer {
        uint256 _index;
        bool _isIndex;
        uint256 _existingIndex;
        bool _isExistingIndex;

        if (_rarity > ranking[ranking.length.sub(1)].rarity) {

            for (uint256 i = 0; i < ranking.length; i = i.add(1)) {
                if (_rarity > ranking[i].rarity && !_isIndex) {
                    _index = i;
                    _isIndex = true;
                }
                if (ranking[i].id == _id && !_isExistingIndex) {
                    _existingIndex = i;
                    _isExistingIndex = true;
                }
                if(_isIndex && _isExistingIndex) break;
            }
            if (_isExistingIndex && _index >= _existingIndex) {
                ranking[_existingIndex] = Ranking(_id, _rarity);
            } else if (_isIndex) {
                _add(_index, _existingIndex, _isExistingIndex, _id, _rarity);
            }
        }
    }

    function _add(
        uint256 _index,
        uint256 _existingIndex,
        bool _isExistingIndex,
        uint256 _id,
        uint32 _rarity
    ) internal {
        uint256 _length = ranking.length;
        uint256 _indexTo = _isExistingIndex ? _existingIndex : _length.sub(1);
        for (uint256 i = _indexTo; i > _index; i = i.sub(1)){
            ranking[i] = ranking[i.sub(1)];
        }

        ranking[_index] = Ranking(_id, _rarity);
    }

    function getTomatosFromRanking() external view returns (uint256[10] result) {
        for (uint256 i = 0; i < ranking.length; i = i.add(1)) {
            result[i] = ranking[i].id;
        }
    }

    function updateRewardTime() external onlyFarmer {
        require(lastRewardDate.add(rewardPeriod) < now, "too early"); 
        lastRewardDate = now; 
    }

    function getRewards(uint256 _remainingBean) external view returns (uint256[10] rewards) {
        for (uint8 i = 0; i < REWARDED_TOMATOS_AMOUNT; i++) {
            rewards[i] = _remainingBean.mul(uint256(2).pow(REWARDED_TOMATOS_AMOUNT.sub(1))).div(
                DISTRIBUTING_FRACTION_OF_REMAINING_BEAN.mul((uint256(2).pow(REWARDED_TOMATOS_AMOUNT)).sub(1)).mul(uint256(2).pow(i))
            );
        }
    }

    function getDate() external view returns (uint256, uint256) {
        return (lastRewardDate, rewardPeriod);
    }
}
