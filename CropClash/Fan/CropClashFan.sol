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

import "../../Common/Upgradable.sol";
import "../../Bean/Bean.sol";
import "./CropClashFanSilo.sol";
import "../Participants/CropClashSilo.sol";
import "../../Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract CropClashFan 
// ----------------------------------------------------------------------------

contract CropClashFan is Upgradable {
    using SafeMath256 for uint256;

    Bean beanStalks;
    CropClashFanSilo _silo_;
    CropClashSilo clashSilo;

    uint256 constant MULTIPLIER = 10**6;

    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return b > a ? 0 : a.sub(b);
    }

    function _validateChallengeId(uint256 _challengeId) internal view {
        require(
            _challengeId > 0 &&
            _challengeId < clashSilo.challengesAmount(),
            "wrong challenge id"
        );
    }

    function _validateBetId(uint256 _betId) internal view {
        require(
            _betId > 0 &&
            _betId < _silo_.betsAmount(),
            "wrong bet id"
        );
        ( , , , , bool _active) = _silo_.allBets(_betId);
        require(_active, "the bet is not active");
    }

    function _getChallengeCurrency(
        uint256 _challengeId
    ) internal view returns (bool isBean) {
        (isBean, , ) = clashSilo.challenges(_challengeId);
    }

    function _getChallengeBetsAmount(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view returns (uint256) {
        return _silo_.challengeBetsAmount(_challengeId, _willCreatorWin);
    }

    function _getChallengeBetsValue(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view returns (uint256) {
        return _silo_.challengeBetsValue(_challengeId, _willCreatorWin);
    }

    function _getChallengeBalance(
        uint256 _challengeId
    ) internal view returns (uint256) {
        return _silo_.challengeBalance(_challengeId);
    }

    function _setChallengeBetsAmount(
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value
    ) internal {
        _silo_.setChallengeBetsAmount(_challengeId, _willCreatorWin, _value);
    }

    function _setChallengeBetsValue(
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value
    ) internal {
        _silo_.setChallengeBetsValue(_challengeId, _willCreatorWin, _value);
    }

    function _setChallengeBalance(
        uint256 _challengeId,
        uint256 _value
    ) internal {
        _silo_.setChallengeBalance(_challengeId, _value);
    }

    function _updateBetsValues(
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value,
        bool _increase
    ) internal {
        uint256 _betsAmount = _getChallengeBetsAmount(_challengeId, _willCreatorWin);
        uint256 _betsValue = _getChallengeBetsValue(_challengeId, _willCreatorWin);
        uint256 _betsTotalValue = _getChallengeBalance(_challengeId);

        if (_increase) {
            _betsAmount = _betsAmount.add(1);
            _betsValue = _betsValue.add(_value);
            _betsTotalValue = _betsTotalValue.add(_value);
        } else {
            _betsAmount = _betsAmount.sub(1);
            _betsValue = _betsValue.sub(_value);
            _betsTotalValue = _betsTotalValue.sub(_value);
        }

        _setChallengeBetsAmount(_challengeId, _willCreatorWin, _betsAmount);
        _setChallengeBetsValue(_challengeId, _willCreatorWin, _betsValue);
        _setChallengeBalance(_challengeId, _betsTotalValue);
    }

    function _checkThatOpponentIsSelected(
        uint256 _challengeId
    ) internal view returns (bool) {
        ( , uint256 _tomatoId) = clashSilo.opponent(_challengeId);
        require(_tomatoId != 0, "the opponent is not selected");
    }

    function _hasClashOccurred(uint256 _challengeId) internal view returns (bool) {
        return clashSilo.clashOccurred(_challengeId);
    }

    function _checkThatClashHasNotOccurred(
        uint256 _challengeId
    ) internal view {
        require(!_hasClashOccurred(_challengeId), "the clash has already occurred");
    }

    function _checkThatClashHasOccurred(
        uint256 _challengeId
    ) internal view {
        require(_hasClashOccurred(_challengeId), "the clash has not yet occurred");
    }

    function _checkThatWeDoNotKnowTheResult(
        uint256 _challengeId
    ) internal view {
        uint256 _blockNumber = clashSilo.clashBlockNumber(_challengeId);
        require(
            _blockNumber > block.number || _blockNumber < _safeSub(block.number, 256),
            "we already know the result"
        );
    }

    function _isWinningBet(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view returns (bool) {
        (address _winner, ) = clashSilo.winner(_challengeId);
        (address _creator, ) = clashSilo.creator(_challengeId);
        bool _isCreatorWinner = _winner == _creator;
        return _isCreatorWinner == _willCreatorWin;
    }

    function _checkWinner(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal view {
        require(_isWinningBet(_challengeId, _willCreatorWin), "you did not win the bet");
    }

    function _checkThatBetIsActive(bool _active) internal pure {
        require(_active, "bet is not active");
    }

    function _payForBet(
        uint256 _value,
        bool _isBean,
        uint256 _bet
    ) internal {
        if (_isBean) {
            require(_value == 0, "specify isBean as false to send eth");
            beanStalks.remoteTransfer(address(_silo_), _bet);
        } else {
            require(_value == _bet, "wrong eth amount");
            address(_silo_).transfer(_value);
        }
    }

    function() external payable {}

    function _create(
        address _user,
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value
    ) internal {
        uint256 _betId = _silo_.addBet(_user, _challengeId, _willCreatorWin, _value);
        _silo_.addChallengeBet(_challengeId, _betId);
        _silo_.addUserChallenge(_user, _challengeId, _betId);
    }

    function placeBet(
        address _user,
        uint256 _challengeId,
        bool _willCreatorWin,
        uint256 _value,
        uint256 _ethValue
    ) external onlyFarmer returns (bool isBean) {
        _validateChallengeId(_challengeId);
        _checkThatOpponentIsSelected(_challengeId);
        _checkThatClashHasNotOccurred(_challengeId);
        _checkThatWeDoNotKnowTheResult(_challengeId);
        require(_value > 0, "a bet must be more than 0");

        isBean = _getChallengeCurrency(_challengeId);
        _payForBet(_ethValue, isBean, _value);

        uint256 _existingBetId = _silo_.userChallengeBetId(_user, _challengeId);
        require(_existingBetId == 0, "you have already placed a bet");

        _create(_user, _challengeId, _willCreatorWin, _value);

        _updateBetsValues(_challengeId, _willCreatorWin, _value, true);
    }

    function _remove(
        address _user,
        uint256 _challengeId,
        uint256 _betId
    ) internal {
        _silo_.deactivateBet(_betId);
        _silo_.removeChallengeBet(_challengeId, _betId);
        _silo_.removeUserChallenge(_user, _challengeId);
    }

    function removeBet(
        address _user,
        uint256 _challengeId
    ) external onlyFarmer {
        _validateChallengeId(_challengeId);

        uint256 _betId = _silo_.userChallengeBetId(_user, _challengeId);
        (
            address _realUser,
            uint256 _realChallengeId,
            bool _willCreatorWin,
            uint256 _value,
            bool _active
        ) = _silo_.allBets(_betId);

        require(_realUser == _user, "not your bet");
        require(_realChallengeId == _challengeId, "wrong challenge");
        _checkThatBetIsActive(_active);

        if (_hasClashOccurred(_challengeId)) {
            require(!_isWinningBet(_challengeId, _willCreatorWin), "request a reward instead");
            uint256 _opponentBetsAmount = _getChallengeBetsAmount(_challengeId, !_willCreatorWin);
            require(_opponentBetsAmount == 0, "your bet lost");
        } else {
            _checkThatWeDoNotKnowTheResult(_challengeId);
        }

        _remove(_user, _challengeId, _betId);

        bool _isBean = _getChallengeCurrency(_challengeId);
        _silo_.payOut(_user, _isBean, _value);

        _updateBetsValues(_challengeId, _willCreatorWin, _value, false);
    }

    function _updateWinningBetsAmount(
        uint256 _challengeId,
        bool _willCreatorWin
    ) internal returns (bool) {
        uint256 _betsAmount = _getChallengeBetsAmount(_challengeId, _willCreatorWin);
        uint256 _existingWinningBetsAmount = _silo_.challengeWinningBetsAmount(_challengeId);
        uint256 _winningBetsAmount = _existingWinningBetsAmount == 0 ? _betsAmount : _existingWinningBetsAmount;
        _winningBetsAmount = _winningBetsAmount.sub(1);
        _silo_.setChallengeWinningBetsAmount(_challengeId, _winningBetsAmount);
        return _winningBetsAmount == 0;
    }

    function requestReward(
        address _user,
        uint256 _challengeId
    ) external onlyFarmer returns (uint256 reward, bool isBean) {
        _validateChallengeId(_challengeId);
        _checkThatClashHasOccurred(_challengeId);
        (
            uint256 _betId,
            bool _willCreatorWin,
            uint256 _value,
            bool _active
        ) = _silo_.getUserBet(_user, _challengeId);
        _checkThatBetIsActive(_active);

        _checkWinner(_challengeId, _willCreatorWin);

        bool _isLast = _updateWinningBetsAmount(_challengeId, _willCreatorWin);

        uint256 _betsValue = _getChallengeBetsValue(_challengeId, _willCreatorWin);
        uint256 _opponentBetsValue = _getChallengeBetsValue(_challengeId, !_willCreatorWin);

        uint256 _percentage = _value.mul(MULTIPLIER).div(_betsValue);
        reward = _opponentBetsValue.mul(85).div(100).mul(_percentage).div(MULTIPLIER); 
        reward = reward.add(_value);

        uint256 _challengeBalance = _getChallengeBalance(_challengeId);
        require(_challengeBalance >= reward, "not enough coins, something went wrong");

        reward = _isLast ? _challengeBalance : reward; 

        isBean = _getChallengeCurrency(_challengeId);
        _silo_.payOut(_user, isBean, reward);

        _setChallengeBalance(_challengeId, _challengeBalance.sub(reward));
        _silo_.deactivateBet(_betId);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        beanStalks = Bean(_newDependencies[0]);
        _silo_ = CropClashFanSilo(_newDependencies[1]);
        clashSilo = CropClashSilo(_newDependencies[2]);
    }
}
