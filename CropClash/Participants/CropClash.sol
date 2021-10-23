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
import "../../Common/Random.sol";
import "../../Clash.sol";
import "../../Bean/Bean.sol";
import "../../Farmhand.sol";
import "../../Field.sol";
import "./CropClashSilo.sol";
import "../Fan/CropClashFanSilo.sol";
import "../../Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract CropClash 
// ----------------------------------------------------------------------------

contract CropClash is Upgradable {
    using SafeMath256 for uint256;

    Clash clash;
    Random random;
    Bean beanStalks;
    Farmhand farmhand;
    Field field;
    CropClashSilo _silo_;
    CropClashFanSilo fanSilo;

    uint8 constant MAX_TACTICS_PERCENTAGE = 80;
    uint8 constant MIN_TACTICS_PERCENTAGE = 20;
    uint8 constant MAX_TOMATO_STRENGTH_PERCENTAGE = 120;
    uint8 constant PERCENTAGE = 100;
    uint256 AUTO_SELECT_TIME = 6000;
    uint256 INTERVAL_FOR_NEW_BLOCK = 1000; 

    function() external payable {}

    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return b > a ? 0 : a.sub(b);
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

    function _validateChallengeId(uint256 _challengeId) internal view {
        require(
            _challengeId > 0 &&
            _challengeId < _silo_.challengesAmount(),
            "wrong challenge id"
        );
    }

    function _validateTactics(uint8[2] _tactics) internal pure {
        require(
            _tactics[0] >= MIN_TACTICS_PERCENTAGE &&
            _tactics[0] <= MAX_TACTICS_PERCENTAGE &&
            _tactics[1] >= MIN_TACTICS_PERCENTAGE &&
            _tactics[1] <= MAX_TACTICS_PERCENTAGE,
            "tactics value must be between 20 and 80"
        );
    }

    function _checkTomatoAvailability(address _user, uint256 _tomatoId) internal view {
        require(farmhand.isTomatoOwner(_user, _tomatoId), "not a tomato owner");
        require(!farmhand.isTomatoOnSale(_tomatoId), "tomato is on sale");
        require(!farmhand.isCloningOnSale(_tomatoId), "tomato is on cloning sale");
        require(!isTomatoChallenging(_tomatoId), "this tomato has already applied");
    }

    function _checkTheClashHasNotOccurred(uint256 _challengeId) internal view {
        require(!_silo_.clashOccurred(_challengeId), "the clash has already occurred");
    }

    function _checkTheChallengeIsNotCancelled(uint256 _id) internal view {
        require(!_silo_.challengeCancelled(_id), "the challenge is cancelled");
    }

    function _checkTheOpponentIsNotSelected(uint256 _id) internal view {
        require(!_isOpponentSelected(_id), "opponent already selected");
    }

    function _checkThatTimeHasCome(uint256 _blockNumber) internal view {
        require(_blockNumber <= block.number, "time has not yet come");
    }

    function _checkChallengeCreator(uint256 _id, address _user) internal view {
        (address _creator, ) = _getCreator(_id);
        require(_creator == _user, "not a challenge creator");
    }

    function _checkForApplicants(uint256 _id) internal view {
        require(_getChallengeApplicantsAmount(_id) > 0, "no applicants");
    }

    function _compareApplicantsArrays(uint256 _challengeId, bytes32 _hash) internal view {
        uint256[] memory _applicants = _silo_.getChallengeApplicants(_challengeId);
        require(keccak256(abi.encode(_applicants)) == _hash, "wrong applicants array");
    }

    function _compareTomatoStrength(uint256 _challengeId, uint256 _applicantId) internal view {
        ( , uint256 _tomatoId) = _getCreator(_challengeId);
        uint256 _strength = farmhand.getTomatoStrength(_tomatoId);
        uint256 _applicantStrength = farmhand.getTomatoStrength(_applicantId);
        uint256 _maxStrength = _strength.mul(MAX_TOMATO_STRENGTH_PERCENTAGE).div(PERCENTAGE); // +20%
        require(_applicantStrength <= _maxStrength, "too strong tomato");
    }

    function _setChallengeCompensation(
        uint256 _challengeId,
        uint256 _bet,
        uint256 _applicantsAmount
    ) internal {
        _silo_.setCompensation(_challengeId, _bet.mul(3).div(10).div(_applicantsAmount));
    }

    function _isOpponentSelected(uint256 _challengeId) internal view returns (bool) {
        ( , uint256 _tomatoId) = _getOpponent(_challengeId);
        return _tomatoId != 0;
    }

    function _getChallengeApplicantsAmount(
        uint256 _challengeId
    ) internal view returns (uint256) {
        return _silo_.challengeApplicantsAmount(_challengeId);
    }

    function _getUserApplicationIndex(
        address _user,
        uint256 _challengeId
    ) internal view returns (uint256, bool, uint256) {
        return _silo_.userApplicationIndex(_user, _challengeId);
    }

    function _getChallenge(
        uint256 _id
    ) internal view returns (bool, uint256, uint256) {
        return _silo_.challenges(_id);
    }

    function _getCompensation(
        uint256 _id
    ) internal view returns (uint256) {
        return _silo_.challengeCompensation(_id);
    }

    function _getTomatoApplication(
        uint256 _id
    ) internal view returns (uint256, uint8[2], address) {
        return _silo_.getTomatoApplication(_id);
    }

    function _getClashBlockNumber(
        uint256 _id
    ) internal view returns (uint256) {
        return _silo_.clashBlockNumber(_id);
    }

    function _getCreator(
        uint256 _id
    ) internal view returns (address, uint256) {
        return _silo_.creator(_id);
    }

    function _getOpponent(
        uint256 _id
    ) internal view returns (address, uint256) {
        return _silo_.opponent(_id);
    }

    function _getFanBetsValue(
        uint256 _challengeId,
        bool _onCreator
    ) internal view returns (uint256) {
        return fanSilo.challengeBetsValue(_challengeId, _onCreator);
    }

    function isTomatoChallenging(uint256 _tomatoId) public view returns (bool) {
        (uint256 _challengeId, , ) = _getTomatoApplication(_tomatoId);
        if (_challengeId != 0) {
            if (_silo_.challengeCancelled(_challengeId)) {
                return false;
            }
            ( , uint256 _owner) = _getCreator(_challengeId);
            ( , uint256 _opponent) = _getOpponent(_challengeId);
            bool _isParticipant = (_tomatoId == _owner) || (_tomatoId == _opponent);

            if (_isParticipant) {
                return !_silo_.clashOccurred(_challengeId);
            }
            return !_isOpponentSelected(_challengeId);
        }
        return false;
    }

    function create(
        address _user,
        uint256 _tomatoId,
        uint8[2] _tactics,
        bool _isBean,
        uint256 _bet,
        uint16 _counter,
        uint256 _value 
    ) external onlyFarmer returns (uint256 challengeId) {
        _validateTactics(_tactics);
        _checkTomatoAvailability(_user, _tomatoId);
        require(_counter >= 5, "too few blocks");

        _payForBet(_value, _isBean, _bet);

        challengeId = _silo_.create(_isBean, _bet, _counter);
        _silo_.addUserChallenge(_user, challengeId);
        _silo_.setCreator(challengeId, _user, _tomatoId);
        _silo_.setTomatoApplication(_tomatoId, challengeId, _tactics, _user);
    }

    function apply(
        uint256 _challengeId,
        address _user,
        uint256 _tomatoId,
        uint8[2] _tactics,
        uint256 _value 
    ) external onlyFarmer {
        _validateChallengeId(_challengeId);
        _validateTactics(_tactics);
        _checkTheClashHasNotOccurred(_challengeId);
        _checkTheChallengeIsNotCancelled(_challengeId);
        _checkTheOpponentIsNotSelected(_challengeId);
        _checkTomatoAvailability(_user, _tomatoId);
        _compareTomatoStrength(_challengeId, _tomatoId);
        ( , bool _exist, ) = _getUserApplicationIndex(_user, _challengeId);
        require(!_exist, "you have already applied");

        (bool _isBean, uint256 _bet, ) = _getChallenge(_challengeId);

        _payForBet(_value, _isBean, _bet);

        _silo_.addUserApplication(_user, _challengeId, _tomatoId);
        _silo_.setTomatoApplication(_tomatoId, _challengeId, _tactics, _user);
        _silo_.addChallengeApplicant(_challengeId, _tomatoId);

        if (_getChallengeApplicantsAmount(_challengeId) == 1) {
            _silo_.setAutoSelectBlock(_challengeId, block.number.add(AUTO_SELECT_TIME));
        }
    }

    function chooseOpponent(
        address _user,
        uint256 _challengeId,
        uint256 _applicantId,
        bytes32 _applicantsHash
    ) external onlyFarmer {
        _validateChallengeId(_challengeId);
        _checkChallengeCreator(_challengeId, _user);
        _compareApplicantsArrays(_challengeId, _applicantsHash);
        _selectOpponent(_challengeId, _applicantId);
    }

    function autoSelectOpponent(
        uint256 _challengeId,
        bytes32 _applicantsHash
    ) external onlyFarmer returns (uint256 applicantId) {
        _validateChallengeId(_challengeId);
        _compareApplicantsArrays(_challengeId, _applicantsHash);
        uint256 _autoSelectBlock = _silo_.autoSelectBlock(_challengeId);
        require(_autoSelectBlock != 0, "no auto select");
        _checkThatTimeHasCome(_autoSelectBlock);

        _checkForApplicants(_challengeId);

        uint256 _applicantsAmount = _getChallengeApplicantsAmount(_challengeId);
        uint256 _index = random.random(2**256 - 1) % _applicantsAmount;
        applicantId = _silo_.challengeApplicants(_challengeId, _index);

        _selectOpponent(_challengeId, applicantId);
    }

    function _selectOpponent(uint256 _challengeId, uint256 _tomatoId) internal {
        _checkTheChallengeIsNotCancelled(_challengeId);
        _checkTheOpponentIsNotSelected(_challengeId);

        (
            uint256 _tomatoChallengeId, ,
            address _opponentUser
        ) = _getTomatoApplication(_tomatoId);
        ( , uint256 _creatorTomatoId) = _getCreator(_challengeId);

        require(_tomatoChallengeId == _challengeId, "wrong opponent");
        require(_creatorTomatoId != _tomatoId, "the same tomato");

        _silo_.setOpponent(_challengeId, _opponentUser, _tomatoId);

        ( , uint256 _bet, uint256 _counter) = _getChallenge(_challengeId);
        _silo_.setClashBlockNumber(_challengeId, block.number.add(_counter));

        _silo_.addUserChallenge(_opponentUser, _challengeId);
        _silo_.removeUserApplication(_opponentUser, _challengeId);

        // if there are more applicants than one just selected then set challenge compensation
        uint256 _applicantsAmount = _getChallengeApplicantsAmount(_challengeId);
        if (_applicantsAmount > 1) {
            uint256 _otherApplicants = _applicantsAmount.sub(1);
            _setChallengeCompensation(_challengeId, _bet, _otherApplicants);
        }
    }

    function _checkClashBlockNumber(uint256 _blockNumber) internal view {
        require(_blockNumber != 0, "opponent is not selected");
        _checkThatTimeHasCome(_blockNumber);
    }

    function _checkClashPossibilityAndGenerateRandom(uint256 _challengeId) internal view returns (uint256) {
        uint256 _blockNumber = _getClashBlockNumber(_challengeId);
        _checkClashBlockNumber(_blockNumber);
        require(_blockNumber >= _safeSub(block.number, 256), "time has passed");
        _checkTheClashHasNotOccurred(_challengeId);
        _checkTheChallengeIsNotCancelled(_challengeId);

        return random.randomOfBlock(2**256 - 1, _blockNumber);
    }

    function _payReward(uint256 _challengeId) internal returns (uint256 reward, bool isBean) {
        uint8 _factor = _getCompensation(_challengeId) > 0 ? 17 : 20;
        uint256 _bet;
        (isBean, _bet, ) = _getChallenge(_challengeId);
        ( , uint256 _creatorId) = _getCreator(_challengeId);
        (address _winner, uint256 _winnerId) = _silo_.winner(_challengeId);

        reward = _bet.mul(_factor).div(10);
        _silo_.payOut(
            _winner,
            isBean,
            reward
        );

        bool _didCreatorWin = _creatorId == _winnerId;
        uint256 _winnerBetsValue = _getFanBetsValue(_challengeId, _didCreatorWin);
        uint256 _opponentBetsValue = _getFanBetsValue(_challengeId, !_didCreatorWin);
        if (_opponentBetsValue > 0 && _winnerBetsValue > 0) {
            uint256 _rewardFromFanBets = _opponentBetsValue.mul(15).div(100);

            uint256 _challengeBalance = fanSilo.challengeBalance(_challengeId);
            require(_challengeBalance >= _rewardFromFanBets, "not enough coins, something went wrong");

            fanSilo.payOut(_winner, isBean, _rewardFromFanBets);

            _challengeBalance = _challengeBalance.sub(_rewardFromFanBets);
            fanSilo.setChallengeBalance(_challengeId, _challengeBalance);

            reward = reward.add(_rewardFromFanBets);
        }
    }

    function _setWinner(uint256 _challengeId, uint256 _tomatoId) internal {
        ( , , address _user) = _getTomatoApplication(_tomatoId);
        _silo_.setWinner(_challengeId, _user, _tomatoId);
    }

    function start(
        uint256 _challengeId
    ) external onlyFarmer returns (
        uint256 seed,
        uint256 clashId,
        uint256 reward,
        bool isBean
    ) {
        _validateChallengeId(_challengeId);
        seed = _checkClashPossibilityAndGenerateRandom(_challengeId);

        ( , uint256 _firstTomatoId) = _getCreator(_challengeId);
        ( , uint256 _secondTomatoId) = _getOpponent(_challengeId);

        ( , uint8[2] memory _firstTactics, ) = _getTomatoApplication(_firstTomatoId);
        ( , uint8[2] memory _secondTactics, ) = _getTomatoApplication(_secondTomatoId);

        uint256[2] memory winnerLooserIds;
        (
            winnerLooserIds, , , , , clashId
        ) = clash.start(
            _firstTomatoId,
            _secondTomatoId,
            _firstTactics,
            _secondTactics,
            seed,
            true
        );

        _setWinner(_challengeId, winnerLooserIds[0]);

        _silo_.setClashOccurred(_challengeId);
        _silo_.setChallengeClashId(_challengeId, clashId);

        (reward, isBean) = _payReward(_challengeId);
    }

    function cancel(
        address _user,
        uint256 _challengeId,
        bytes32 _applicantsHash
    ) external onlyFarmer {
        _validateChallengeId(_challengeId);
        _checkChallengeCreator(_challengeId, _user);
        _checkTheOpponentIsNotSelected(_challengeId);
        _checkTheChallengeIsNotCancelled(_challengeId);
        _compareApplicantsArrays(_challengeId, _applicantsHash);

        (bool _isBean, uint256 _value /* bet */, ) = _getChallenge(_challengeId);
        uint256 _applicantsAmount = _getChallengeApplicantsAmount(_challengeId);
        
        if (_applicantsAmount > 0) {
            _setChallengeCompensation(_challengeId, _value, _applicantsAmount); 
            _value = _value.mul(7).div(10); 
        }
        _silo_.payOut(_user, _isBean, _value);
        _silo_.setChallengeCancelled(_challengeId);
    }

    function returnBet(address _user, uint256 _challengeId) external onlyFarmer {
        _validateChallengeId(_challengeId);
        ( , bool _exist, uint256 _tomatoId) = _getUserApplicationIndex(_user, _challengeId);
        require(_exist, "wrong challenge");

        (bool _isBean, uint256 _bet, ) = _getChallenge(_challengeId);
        uint256 _compensation = _getCompensation(_challengeId);
        uint256 _value = _bet.add(_compensation);
        _silo_.payOut(_user, _isBean, _value);
        _silo_.removeTomatoApplication(_tomatoId, _challengeId);
        _silo_.removeUserApplication(_user, _challengeId);

        if (_getChallengeApplicantsAmount(_challengeId) == 0) {
            _silo_.setAutoSelectBlock(_challengeId, 0);
        }
    }

    function addTimeForOpponentSelect(
        address _user,
        uint256 _challengeId
    ) external onlyFarmer returns (uint256 newAutoSelectBlock) {
        _validateChallengeId(_challengeId);
        _checkChallengeCreator(_challengeId, _user);
        _checkForApplicants(_challengeId);
        _checkTheOpponentIsNotSelected(_challengeId);
        _checkTheChallengeIsNotCancelled(_challengeId);
        uint256 _price = _silo_.getExtensionTimePrice(_challengeId);

        field.takeBean(_price);
        _silo_.setExtensionTimePrice(_challengeId, _price.mul(2));
        uint256 _autoSelectBlock = _silo_.autoSelectBlock(_challengeId);
        newAutoSelectBlock = _autoSelectBlock.add(AUTO_SELECT_TIME);
        _silo_.setAutoSelectBlock(_challengeId, newAutoSelectBlock);
    }

    function updateClashBlockNumber(
        uint256 _challengeId
    ) external onlyFarmer returns (uint256 newClashBlockNumber) {
        _validateChallengeId(_challengeId);
        _checkTheClashHasNotOccurred(_challengeId);
        _checkTheChallengeIsNotCancelled(_challengeId);
        uint256 _blockNumber = _getClashBlockNumber(_challengeId);
        _checkClashBlockNumber(_blockNumber);
        require(_blockNumber < _safeSub(block.number, 256), "you can start a clash");

        newClashBlockNumber = block.number.add(INTERVAL_FOR_NEW_BLOCK);
        _silo_.setClashBlockNumber(_challengeId, newClashBlockNumber);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        clash = Clash(_newDependencies[0]);
        random = Random(_newDependencies[1]);
        beanStalks = Bean(_newDependencies[2]);
        farmhand = Farmhand(_newDependencies[3]);
        field = Field(_newDependencies[4]);
        _silo_ = CropClashSilo(_newDependencies[5]);
        fanSilo = CropClashFanSilo(_newDependencies[6]);
    }
}
