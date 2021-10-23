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
import "./Common/Random.sol";
import "./Farm.sol";
import "./Clash.sol";
import "./Field.sol";
import "./Farmhand.sol";
import "./Common/SafeMath8.sol";
import "./Common/SafeMath16.sol";
import "./Common/SafeMath32.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract ClashFarmer 
// ----------------------------------------------------------------------------

contract ClashFarmer is Upgradable {
    using SafeMath8 for uint8;
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;

    Farm farm;
    Clash clash;
    Field field;
    Farmhand farmhand;
    Random random;

    mapping (uint256 => uint256) lastClashDate;

    uint8 constant MAX_PERCENTAGE = 100;
    uint8 constant MIN_HEALTH_PERCENTAGE = 50;
    uint8 constant MAX_TACTICS_PERCENTAGE = 80;
    uint8 constant MIN_TACTICS_PERCENTAGE = 20;
    uint8 constant PERCENT_MULTIPLIER = 100;
    uint8 constant TOMATO_STRENGTH_DIFFERENCE_PERCENTAGE = 10;
    uint32 constant MAX_BEAN_REWARD_MULTIPLIER = 10000000;

    uint256 constant BEAN_REWARD_MULTIPLIER = 10 ** 18;

    function _min(uint256 lth, uint256 rth) internal pure returns (uint256) {
        return lth > rth ? rth : lth;
    }

    function _isTouchable(uint256 _id) internal view returns (bool) {
        uint32 _regenerationTime = farm.getTomatoFullRegenerationTime(_id);
        return lastClashDate[_id].add(_regenerationTime.mul(4)) < now; 
    }

    function _checkClashPossibility(
        address _sender,
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics
    ) internal view {
        require(farmhand.isTomatoOwner(_sender, _id), "not an owner");
        require(!farmhand.isTomatoOwner(_sender, _opponentId), "can't be the owner of this tomato");
        require(!farmhand.isTomatoOwner(address(0), _opponentId), "this tomato has no owner");

        require(!farmhand.isTomatoInCropClash(_id), "your tomato is in the crop clash");
        require(!farmhand.isTomatoInCropClash(_opponentId), "opponent is in the crop clash");

        require(_isTouchable(_opponentId), "this tomato is untouchable");

        require(
            _tactics[0] >= MIN_TACTICS_PERCENTAGE &&
            _tactics[0] <= MAX_TACTICS_PERCENTAGE &&
            _tactics[1] >= MIN_TACTICS_PERCENTAGE &&
            _tactics[1] <= MAX_TACTICS_PERCENTAGE,
            "tactics value must be between 20 and 80"
        );

        uint8 _attackerHealthPercentage;
        uint8 _attackerRadiationPercentage;
        ( , , _attackerHealthPercentage, _attackerRadiationPercentage) = farmhand.getTomatoCurrentHealthAndRadiation(_id);
        require(
            _attackerHealthPercentage >= MIN_HEALTH_PERCENTAGE,
            "tomato's health less than 50%"
        );
        uint8 _opponentHealthPercentage;
        uint8 _opponentRadiationPercentage;
        ( , , _opponentHealthPercentage, _opponentRadiationPercentage) = farmhand.getTomatoCurrentHealthAndRadiation(_opponentId);
        require(
            _opponentHealthPercentage == MAX_PERCENTAGE &&
            _opponentRadiationPercentage == MAX_PERCENTAGE,
            "opponent health and/or radiation is not full"
        );
    }

    function startClash(
        address _sender,
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics
    ) external onlyFarmer returns (
        uint256 clashId,
        uint256 seed,
        uint256[2] winnerLooserIds
    ) {
        _checkClashPossibility(_sender, _id, _opponentId, _tactics);

        seed = random.random(2**256 - 1);

        uint32 _winnerHealth;
        uint32 _winnerRadiation;
        uint32 _looserHealth;
        uint32 _looserRadiation;

        (
            winnerLooserIds,
            _winnerHealth, _winnerRadiation,
            _looserHealth, _looserRadiation,
            clashId
        ) = clash.start(
            _id,
            _opponentId,
            _tactics,
            [0, 0],
            seed,
            false
        );

        farm.setTomatoReprimeingHealthAndRadiation(winnerLooserIds[0], _winnerHealth, _winnerRadiation);
        farm.setTomatoReprimeingHealthAndRadiation(winnerLooserIds[1], _looserHealth, _looserRadiation);

        farm.increaseTomatoWins(winnerLooserIds[0]);
        farm.increaseTomatoDefeats(winnerLooserIds[1]);

        lastClashDate[_opponentId] = now; 

        _payClashRewards(
            _sender,
            _id,
            _opponentId,
            winnerLooserIds[0]
        );
    }

    function _payClashRewards(
        address _sender,
        uint256 _id,
        uint256 _opponentId,
        uint256 _winnerId
    ) internal {
        uint32 _strength = farmhand.getTomatoStrength(_id);
        uint32 _opponentStrength = farmhand.getTomatoStrength(_opponentId);
        bool _isAttackerWinner = _id == _winnerId;

        uint256 _xpFactor = _calculateExperience(_isAttackerWinner, _strength, _opponentStrength);
        farm.increaseTomatoExperience(_winnerId, _xpFactor);

        if (_isAttackerWinner) {
            uint256 _factor = _calculateBeanRewardFactor(_strength, _opponentStrength);
            _payBeanReward(_sender, _id, _factor);
        }
    }

    function _calculateExperience(
        bool _isAttackerWinner,
        uint32 _attackerStrength,
        uint32 _opponentStrength
    ) internal pure returns (uint256) {

        uint8 _attackerFactor;
        uint256 _winnerStrength;
        uint256 _looserStrength;

        uint8 _degree;

        if (_isAttackerWinner) {
            _attackerFactor = 10;
            _winnerStrength = _attackerStrength;
            _looserStrength = _opponentStrength;
            _degree = _winnerStrength <= _looserStrength ? 2 : 5;
        } else {
            _attackerFactor = 5;
            _winnerStrength = _opponentStrength;
            _looserStrength = _attackerStrength;
            _degree = _winnerStrength <= _looserStrength ? 1 : 5;
        }

        uint256 _factor = _looserStrength.pow(_degree).mul(_attackerFactor).div(_winnerStrength.pow(_degree));

        if (_isAttackerWinner) {
            return _factor;
        }
        return _min(_factor, 10);
    }

    function _calculateBeanRewardFactor(
        uint256 _winnerStrength,
        uint256 _looserStrength
    ) internal pure returns (uint256) {
        uint8 _degree = _winnerStrength <= _looserStrength ? 1 : 8;
        return _looserStrength.pow(_degree).mul(BEAN_REWARD_MULTIPLIER).div(_winnerStrength.pow(_degree));
    }

    function _getMaxBeanReward(
        uint256 _sproutingPrice,
        uint256 _tomatosAmount
    ) internal pure returns (uint256) {
        uint32 _factor;

        if (_tomatosAmount < 3000) _factor = 2000000; 
        else if (_tomatosAmount < 6000) _factor = 1000000; 
        else if (_tomatosAmount < 9000) _factor = 500000; 
        else if (_tomatosAmount < 12000) _factor = 250000;
        else if (_tomatosAmount < 15000) _factor = 125000;
        else if (_tomatosAmount < 18000) _factor = 62500;
        else if (_tomatosAmount < 21000) _factor = 31250;
        else _factor = 15625;

        return _sproutingPrice.mul(_factor).div(MAX_BEAN_REWARD_MULTIPLIER);
    }

    function _payBeanReward(
        address _sender,
        uint256 _id,
        uint256 _factor
    ) internal {
        uint256 _beanReprime = field.remainingBean();
        uint256 _tomatosAmount = farmhand.getTomatosAmount();
        uint32 _rarity;
        (, , , , , , , _rarity) = farmhand.getTomatoProfile(_id);
        uint256 _sproutingPrice = field.sproutingPrice();
        // tomato rarity is multyplied by 100
        uint256 _value = _beanReprime.mul(_rarity).mul(10).div(_tomatosAmount.pow(2)).div(100);
        _value = _value.mul(_factor).div(BEAN_REWARD_MULTIPLIER);

        uint256 _maxReward = _getMaxBeanReward(_sproutingPrice, _tomatosAmount);
        if (_value > _maxReward) _value = _maxReward;
        if (_value > _beanReprime) _value = _beanReprime;
        field.giveBean(_sender, _value);
    }

    struct Opponent {
        uint256 id;
        uint256 timestamp;
        uint32 strength;
    }

    function _iterateTimestampIndex(uint8 _index) internal pure returns (uint8) {
        return _index < 5 ? _index.add(1) : 0;
    }

    function _getPercentOfValue(uint32 _value, uint8 _percent) internal pure returns (uint32) {
        return _value.mul(_percent).div(PERCENT_MULTIPLIER);
    }

    function matchOpponents(uint256 _attackerId) external view returns (uint256[6]) {
        uint32 _attackerStrength = farmhand.getTomatoStrength(_attackerId);
        uint32 _strengthDiff = _getPercentOfValue(_attackerStrength, TOMATO_STRENGTH_DIFFERENCE_PERCENTAGE);
        uint32 _minStrength = _attackerStrength.sub(_strengthDiff);
        uint32 _maxStrength = _attackerStrength.add(_strengthDiff);
        uint32 _strength;
        uint256 _timestamp; 
        uint8 _timestampIndex;
        uint8 _healthPercentage;
        uint8 _radiationPercentage;

        address _owner = farmhand.ownerOfTomato(_attackerId);

        Opponent[6] memory _opponents;
        _opponents[0].timestamp =
        _opponents[1].timestamp =
        _opponents[2].timestamp =
        _opponents[3].timestamp =
        _opponents[4].timestamp =
        _opponents[5].timestamp = now;

        for (uint256 _id = 1; _id <= farmhand.getTomatosAmount(); _id++) { 

            if (
                _attackerId != _id
                && !farmhand.isTomatoOwner(_owner, _id)
                && !farmhand.isTomatoInCropClash(_id)
                && _isTouchable(_id)
            ) {
                _strength = farmhand.getTomatoStrength(_id);
                if (_strength >= _minStrength && _strength <= _maxStrength) {

                    ( , , _healthPercentage, _radiationPercentage) = farmhand.getTomatoCurrentHealthAndRadiation(_id);
                    if (_healthPercentage == MAX_PERCENTAGE && _radiationPercentage == MAX_PERCENTAGE) {

                        (_timestamp, , , , ) = farmhand.getTomatoHealthAndRadiation(_id);
                        if (_timestamp < _opponents[_timestampIndex].timestamp) {

                            _opponents[_timestampIndex] = Opponent(_id, _timestamp, _strength);
                            _timestampIndex = _iterateTimestampIndex(_timestampIndex);
                        }
                    }
                }
            }
        }
        return [
            _opponents[0].id,
            _opponents[1].id,
            _opponents[2].id,
            _opponents[3].id,
            _opponents[4].id,
            _opponents[5].id
        ];
    }

    function resetTomatoBuffs(uint256 _id) external onlyFarmer {
        farm.resetTomatoBuffs(_id);
    }

     

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        farm = Farm(_newDependencies[0]);
        clash = Clash(_newDependencies[1]);
        field = Field(_newDependencies[2]);
        farmhand = Farmhand(_newDependencies[3]);
        random = Random(_newDependencies[4]);
    }
}
