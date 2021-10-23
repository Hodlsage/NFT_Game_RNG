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
import "../../Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract CropClashSilo 
// ----------------------------------------------------------------------------

contract CropClashSilo is Upgradable {
    using SafeMath256 for uint256;

    Bean beanStalks;

    uint256 EXTENSION_TIME_START_PRICE;

    struct Participant { 
        address user;
        uint256 tomatoId;
    }

    struct Challenge {
        bool isBean; 
        uint256 bet;
        uint16 counter; 
    }

    Challenge[] public challenges;

    mapping (uint256 => Participant) public creator;
    mapping (uint256 => Participant) public opponent;
    mapping (uint256 => Participant) public winner; 
    mapping (uint256 => uint256) public clashBlockNumber;
    mapping (uint256 => bool) public clashOccurred;
    mapping (uint256 => uint256) public autoSelectBlock;
    mapping (uint256 => bool) public challengeCancelled;
    mapping (uint256 => uint256) public challengeCompensation;
    mapping (uint256 => uint256) extensionTimePrice;

    struct TomatoApplication {
        uint256 challengeId;
        uint8[2] tactics;
        address owner;
    }

    struct UserApplication {
        uint256 index;
        bool exist;
        uint256 tomatoId; 
    }

    mapping (address => uint256[]) userChallenges;
    mapping (uint256 => uint256[]) public challengeApplicants;
    mapping (uint256 => uint256) applicantIndex;
    mapping (address => uint256[]) userApplications;
    mapping (address => mapping(uint256 => UserApplication)) public userApplicationIndex;
    mapping (uint256 => TomatoApplication) tomatoApplication;
    mapping (uint256 => uint256) challengeClashId;

    constructor() public {
        challenges.length = 1; 
        EXTENSION_TIME_START_PRICE = 50 * (10 ** 18);
    }

    function() external payable {}

    function payOut(address _user, bool _isBean, uint256 _value) external onlyFarmer {
        if (_isBean) {
            beanStalks.transfer(_user, _value);
        } else {
            _user.transfer(_value);
        }
    }

    function create(
        bool _isBean,
        uint256 _bet,
        uint16 _counter
    ) external onlyFarmer returns (uint256 challengeId) {
        Challenge memory _challenge = Challenge({
            isBean: _isBean,
            bet: _bet,
            counter: _counter
        });
        challengeId = challenges.length;
        challenges.push(_challenge);
    }

    function addUserChallenge(address _user, uint256 _challengeId) external onlyFarmer {
        userChallenges[_user].push(_challengeId);
    }

    function setCreator(
        uint256 _challengeId,
        address _user,
        uint256 _tomatoId
    ) external onlyFarmer {
        creator[_challengeId] = Participant(_user, _tomatoId);
    }

    function setOpponent(
        uint256 _challengeId,
        address _user,
        uint256 _tomatoId
    ) external onlyFarmer {
        opponent[_challengeId] = Participant(_user, _tomatoId);
    }

    function setWinner(
        uint256 _challengeId,
        address _user,
        uint256 _tomatoId
    ) external onlyFarmer {
        winner[_challengeId] = Participant(_user, _tomatoId);
    }

    function setTomatoApplication(
        uint256 _tomatoId,
        uint256 _challengeId,
        uint8[2] _tactics,
        address _user
    ) external onlyFarmer {
        tomatoApplication[_tomatoId] = TomatoApplication(_challengeId, _tactics, _user);
    }

    function removeTomatoApplication(
        uint256 _tomatoId,
        uint256 _challengeId
    ) external onlyFarmer {
        if (tomatoApplication[_tomatoId].challengeId == _challengeId) {
            uint256 _index = applicantIndex[_tomatoId];
            uint256 _lastIndex = challengeApplicants[_challengeId].length.sub(1);
            uint256 _lastItem = challengeApplicants[_challengeId][_lastIndex];
            challengeApplicants[_challengeId][_index] = _lastItem;
            challengeApplicants[_challengeId][_lastIndex] = 0;
            challengeApplicants[_challengeId].length--;
            delete applicantIndex[_tomatoId];
        }
        delete tomatoApplication[_tomatoId];
    }

    function addUserApplication(
        address _user,
        uint256 _challengeId,
        uint256 _tomatoId
    ) external onlyFarmer {
        uint256 _index = userApplications[_user].length;
        userApplications[_user].push(_challengeId);
        userApplicationIndex[_user][_challengeId] = UserApplication(_index, true, _tomatoId);
    }

    function removeUserApplication(
        address _user,
        uint256 _challengeId
    ) external onlyFarmer {
        uint256 _index = userApplicationIndex[_user][_challengeId].index;
        uint256 _lastIndex = userApplications[_user].length.sub(1);
        uint256 _lastItem = userApplications[_user][_lastIndex];
        userApplications[_user][_index] = _lastItem;
        userApplications[_user][_lastIndex] = 0;
        userApplications[_user].length--;
        delete userApplicationIndex[_user][_challengeId];
        userApplicationIndex[_user][_lastItem].index = _index;
    }

    function addChallengeApplicant(
        uint256 _challengeId,
        uint256 _tomatoId
    ) external onlyFarmer {
        uint256 _applicantIndex = challengeApplicants[_challengeId].length;
        challengeApplicants[_challengeId].push(_tomatoId);
        applicantIndex[_tomatoId] = _applicantIndex;
    }

    function setAutoSelectBlock(
        uint256 _challengeId,
        uint256 _number
    ) external onlyFarmer {
        autoSelectBlock[_challengeId] = _number;
    }

    function setClashBlockNumber(
        uint256 _challengeId,
        uint256 _number
    ) external onlyFarmer {
        clashBlockNumber[_challengeId] = _number;
    }

    function setCompensation(
        uint256 _challengeId,
        uint256 _value
    ) external onlyFarmer {
        challengeCompensation[_challengeId] = _value;
    }

    function setClashOccurred(
        uint256 _challengeId
    ) external onlyFarmer {
        clashOccurred[_challengeId] = true;
    }

    function setChallengeClashId(
        uint256 _challengeId,
        uint256 _clashId
    ) external onlyFarmer {
        challengeClashId[_challengeId] = _clashId;
    }

    function setChallengeCancelled(
        uint256 _challengeId
    ) external onlyFarmer {
        challengeCancelled[_challengeId] = true;
    }

    function setExtensionTimePrice(
        uint256 _challengeId,
        uint256 _value
    ) external onlyFarmer {
        extensionTimePrice[_challengeId] = _value;
    }

    function setExtensionTimeStartPrice(
        uint256 _value
    ) external onlyFarmer {
        EXTENSION_TIME_START_PRICE = _value;
    }

    function challengesAmount() external view returns (uint256) {
        return challenges.length;
    }

    function getUserChallenges(address _user) external view returns (uint256[]) {
        return userChallenges[_user];
    }

    function getChallengeApplicants(uint256 _challengeId) external view returns (uint256[]) {
        return challengeApplicants[_challengeId];
    }

    function challengeApplicantsAmount(uint256 _challengeId) external view returns (uint256) {
        return challengeApplicants[_challengeId].length;
    }

    function getTomatoApplication(uint256 _tomatoId) external view returns (uint256, uint8[2], address) {
        return (
            tomatoApplication[_tomatoId].challengeId,
            tomatoApplication[_tomatoId].tactics,
            tomatoApplication[_tomatoId].owner
        );
    }

    function getUserApplications(address _user) external view returns (uint256[]) {
        return userApplications[_user];
    }

    function getExtensionTimePrice(uint256 _challengeId) public view returns (uint256) {
        uint256 _price = extensionTimePrice[_challengeId];
        return _price != 0 ? _price : EXTENSION_TIME_START_PRICE;
    }

    function getChallengeParticipants(
        uint256 _challengeId
    ) external view returns (
        address firstUser,
        uint256 firstTomatoId,
        address secondUser,
        uint256 secondTomatoId,
        address winnerUser,
        uint256 winnerTomatoId
    ) {
        firstUser = creator[_challengeId].user;
        firstTomatoId = creator[_challengeId].tomatoId;
        secondUser = opponent[_challengeId].user;
        secondTomatoId = opponent[_challengeId].tomatoId;
        winnerUser = winner[_challengeId].user;
        winnerTomatoId = winner[_challengeId].tomatoId;
    }

    function getChallengeDetails(
        uint256 _challengeId
    ) external view returns (
        bool isBean,
        uint256 bet,
        uint16 counter,
        uint256 blockNumber,
        bool active,
        uint256 opponentAutoSelectBlock,
        bool cancelled,
        uint256 compensation,
        uint256 selectionExtensionTimePrice,
        uint256 clashId
    ) {
        isBean = challenges[_challengeId].isBean;
        bet = challenges[_challengeId].bet;
        counter = challenges[_challengeId].counter;
        blockNumber = clashBlockNumber[_challengeId];
        active = !clashOccurred[_challengeId];
        opponentAutoSelectBlock = autoSelectBlock[_challengeId];
        cancelled = challengeCancelled[_challengeId];
        compensation = challengeCompensation[_challengeId];
        selectionExtensionTimePrice = getExtensionTimePrice(_challengeId);
        clashId = challengeClashId[_challengeId];
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);
        beanStalks = Bean(_newDependencies[0]);
    }
}
