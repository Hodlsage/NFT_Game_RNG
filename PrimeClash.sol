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
import "./Common/Pausable.sol";
import "./Common/HumanOriented.sol";
import "./ClashFarmer.sol";
import "./CropClash/Participants/CropClash.sol";
import "./CropClash/Fan/CropClashFan.sol";
import "./Hoedown.sol";

// ----------------------------------------------------------------------------
// --- Contract PrimeClash 
// ----------------------------------------------------------------------------

contract PrimeClash is Upgradable, Pausable, HumanOriented {
    ClashFarmer clashFarmer;
    Farmhand farmhand;
    CropClash cropClash;
    CropClashFan cropClashFan;
    Hoedown hoedown;

    function matchOpponents(uint256 _id) external view returns (uint256[6]) {
        return clashFarmer.matchOpponents(_id);
    }

    function clash(
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics
    ) external onlyHuman whenNotPaused {
        uint32 _attackerInitHealth;
        uint32 _attackerInitRadiation;
        uint32 _opponentInitHealth;
        uint32 _opponentInitRadiation;
        (_attackerInitHealth, _attackerInitRadiation, , ) = farmhand.getTomatoCurrentHealthAndRadiation(_id);
        (_opponentInitHealth, _opponentInitRadiation, , ) = farmhand.getTomatoCurrentHealthAndRadiation(_opponentId);

        uint256 _clashId;
        uint256 _seed;
        uint256[2] memory _winnerLooserIds;
        (
            _clashId,
            _seed,
            _winnerLooserIds
        ) = clashFarmer.startClash(msg.sender, _id, _opponentId, _tactics);

        _emitClashHoedownPure(
            _id,
            _opponentId,
            _tactics,
            _winnerLooserIds,
            _clashId,
            _seed,
            _attackerInitHealth,
            _attackerInitRadiation,
            _opponentInitHealth,
            _opponentInitRadiation
        );
    }

    function _emitClashHoedownPure(
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics,
        uint256[2] _winnerLooserIds,
        uint256 _clashId,
        uint256 _seed,
        uint32 _attackerInitHealth,
        uint32 _attackerInitRadiation,
        uint32 _opponentInitHealth,
        uint32 _opponentInitRadiation
    ) internal {
        _saveClashHealthAndRadiation(
            _clashId,
            _id,
            _opponentId,
            _attackerInitHealth,
            _attackerInitRadiation,
            _opponentInitHealth,
            _opponentInitRadiation
        );
        _emitClashHoedown(
            _id,
            _opponentId,
            _tactics,
            [0, 0],
            _winnerLooserIds[0],
            _winnerLooserIds[1],
            _clashId,
            _seed,
            0
        );
    }

    function _emitClashHoedownForCropClash(
        uint256 _clashId,
        uint256 _seed,
        uint256 _cropClashId
    ) internal {
        uint256 _firstTomatoId;
        uint256 _secondTomatoId;
        uint256 _winnerTomatoId;
        (
          , _firstTomatoId,
          , _secondTomatoId,
          , _winnerTomatoId
        ) = farmhand.getCropClashParticipants(_cropClashId);

        _saveClashHealthAndRadiationFull(
            _clashId,
            _firstTomatoId,
            _secondTomatoId
        );

        uint8[2] memory _tactics;
        uint8[2] memory _tactics2;

        ( , _tactics, ) = farmhand.getTomatoApplicationForCropClash(_firstTomatoId);
        ( , _tactics2, ) = farmhand.getTomatoApplicationForCropClash(_secondTomatoId);

        _emitClashHoedown(
            _firstTomatoId,
            _secondTomatoId,
            _tactics,
            _tactics2,
            _winnerTomatoId,
            _winnerTomatoId != _firstTomatoId ? _firstTomatoId : _secondTomatoId,
            _clashId,
            _seed,
            _cropClashId
        );
    }

    function _emitClashHoedown(
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics,
        uint8[2] _tactics2,
        uint256 _winnerId,
        uint256 _looserId,
        uint256 _clashId,
        uint256 _seed,
        uint256 _cropClashId
    ) internal {
        _saveClashData(
            _clashId,
            _seed,
            _id,
            _winnerId,
            _looserId,
            _cropClashId
        );

        _saveClashTomatosDetails(
            _clashId,
            _id,
            _opponentId
        );

        _saveClashAbilitys(
            _clashId,
            _id,
            _opponentId
        );
        _saveClashTacticsAndBuffs(
            _clashId,
            _id,
            _opponentId,
            _tactics[0],
            _tactics[1],
            _tactics2[0],
            _tactics2[1]
        );
    }

    function _saveClashData(
        uint256 _clashId,
        uint256 _seed,
        uint256 _attackerId,
        uint256 _winnerId,
        uint256 _looserId,
        uint256 _cropClashId
    ) internal {

        hoedown.emitClashEnded(
            _clashId,
            now, 
            _seed,
            _attackerId,
            _winnerId,
            _looserId,
            _cropClashId > 0,
            _cropClashId
        );
    }

    function _saveClashTomatosDetails(
        uint256 _clashId,
        uint256 _winnerId,
        uint256 _looserId
    ) internal {
        uint8 _winnerLevel;
        uint32 _winnerRarity;
        uint8 _looserLevel;
        uint32 _looserRarity;
        (, , , _winnerLevel, , , , _winnerRarity) = farmhand.getTomatoProfile(_winnerId);
        (, , , _looserLevel, , , , _looserRarity) = farmhand.getTomatoProfile(_looserId);

        hoedown.emitClashTomatosDetails(
            _clashId,
            _winnerLevel,
            _winnerRarity,
            _looserLevel,
            _looserRarity
        );
    }

    function _saveClashHealthAndRadiationFull(
        uint256 _clashId,
        uint256 _firstId,
        uint256 _secondId
    ) internal {
        uint32 _firstInitHealth;
        uint32 _firstInitRadiation;
        uint32 _secondInitHealth;
        uint32 _secondInitRadiation;

        (_firstInitHealth, _firstInitRadiation) = farmhand.getTomatoMaxHealthAndRadiation(_firstId);
        (_secondInitHealth, _secondInitRadiation) = farmhand.getTomatoMaxHealthAndRadiation(_secondId);

        _saveClashHealthAndRadiation(
            _clashId,
            _firstId,
            _secondId,
            _firstInitHealth,
            _firstInitRadiation,
            _secondInitHealth,
            _secondInitRadiation
        );
    }

    function _saveClashHealthAndRadiation(
        uint256 _clashId,
        uint256 _attackerId,
        uint256 _opponentId,
        uint32 _attackerInitHealth,
        uint32 _attackerInitRadiation,
        uint32 _opponentInitHealth,
        uint32 _opponentInitRadiation
    ) internal {
        uint32 _attackerMaxHealth;
        uint32 _attackerMaxRadiation;
        uint32 _opponentMaxHealth;
        uint32 _opponentMaxRadiation;
        (_attackerMaxHealth, _attackerMaxRadiation) = farmhand.getTomatoMaxHealthAndRadiation(_attackerId);
        (_opponentMaxHealth, _opponentMaxRadiation) = farmhand.getTomatoMaxHealthAndRadiation(_opponentId);

        hoedown.emitClashHealthAndRadiation(
            _clashId,
            _attackerMaxHealth,
            _attackerMaxRadiation,
            _attackerInitHealth,
            _attackerInitRadiation,
            _opponentMaxHealth,
            _opponentMaxRadiation,
            _opponentInitHealth,
            _opponentInitRadiation
        );
    }

    function _saveClashAbilitys(
        uint256 _clashId,
        uint256 _attackerId,
        uint256 _opponentId
    ) internal {
        uint32 _attackerAttack;
        uint32 _attackerDefense;
        uint32 _attackerStamina;
        uint32 _attackerSpeed;
        uint32 _attackerIntelligence;
        uint32 _opponentAttack;
        uint32 _opponentDefense;
        uint32 _opponentStamina;
        uint32 _opponentSpeed;
        uint32 _opponentIntelligence;

        (
            _attackerAttack,
            _attackerDefense,
            _attackerStamina,
            _attackerSpeed,
            _attackerIntelligence
        ) = farmhand.getTomatoAbilitys(_attackerId);
        (
            _opponentAttack,
            _opponentDefense,
            _opponentStamina,
            _opponentSpeed,
            _opponentIntelligence
        ) = farmhand.getTomatoAbilitys(_opponentId);

        hoedown.emitClashAbilitys(
            _clashId,
            _attackerAttack,
            _attackerDefense,
            _attackerStamina,
            _attackerSpeed,
            _attackerIntelligence,
            _opponentAttack,
            _opponentDefense,
            _opponentStamina,
            _opponentSpeed,
            _opponentIntelligence
        );
    }

    function _saveClashTacticsAndBuffs(
        uint256 _clashId,
        uint256 _id,
        uint256 _opponentId,
        uint8 _attackerMeleeChance,
        uint8 _attackerAttackChance,
        uint8 _opponentMeleeChance,
        uint8 _opponentAttackChance
    ) internal {
        if (_opponentMeleeChance == 0 || _opponentAttackChance == 0) {
            (
                _opponentMeleeChance,
                _opponentAttackChance
            ) = farmhand.getTomatoTactics(_opponentId);
        }

        uint32[5] memory _buffs = farmhand.getTomatoBuffs(_id);
        uint32[5] memory _opponentBuffs = farmhand.getTomatoBuffs(_opponentId);

        clashFarmer.resetTomatoBuffs(_id);
        clashFarmer.resetTomatoBuffs(_opponentId);

        hoedown.emitClashTacticsAndBuffs(
            _clashId,
            _attackerMeleeChance,
            _attackerAttackChance,
            _opponentMeleeChance,
            _opponentAttackChance,
            _buffs,
            _opponentBuffs
        );
    }

    // CROP CLASHS

    function createCropClash(
        uint256 _tomatoId,
        uint8[2] _tactics,
        bool _isBean,
        uint256 _bet,
        uint16 _counter
    ) external payable onlyHuman whenNotPaused {
        address(cropClash).transfer(msg.value);
        uint256 _id = cropClash.create(msg.sender, _tomatoId, _tactics, _isBean, _bet, _counter, msg.value);
        hoedown.emitCropClashCreated(_id, msg.sender, _tomatoId, _bet, _isBean);
    }

    function applyForCropClash(
        uint256 _clashId,
        uint256 _tomatoId,
        uint8[2] _tactics
    ) external payable onlyHuman whenNotPaused {
        address(cropClash).transfer(msg.value);
        cropClash.apply(_clashId, msg.sender, _tomatoId, _tactics, msg.value);
        hoedown.emitCropClashApplicantAdded(_clashId, msg.sender, _tomatoId);
    }

    function chooseOpponentForCropClash(
        uint256 _clashId,
        uint256 _opponentId,
        bytes32 _applicantsHash
    ) external onlyHuman whenNotPaused {
        cropClash.chooseOpponent(msg.sender, _clashId, _opponentId, _applicantsHash);
        hoedown.emitCropClashOpponentSelected(_clashId, _opponentId);
    }

    function autoSelectOpponentForCropClash(
        uint256 _clashId,
        bytes32 _applicantsHash
    ) external onlyHuman whenNotPaused {
        uint256 _opponentId = cropClash.autoSelectOpponent(_clashId, _applicantsHash);
        hoedown.emitCropClashOpponentSelected(_clashId, _opponentId);
    }

    function _emitCropClashEnded(
        uint256 _cropClashId,
        uint256 _clashId,
        address _winner,
        address _looser,
        uint256 _reward,
        bool _isBean
    ) internal {
        hoedown.emitCropClashEnded(
            _cropClashId,
            _clashId,
            _winner,
            _looser,
            _reward,
            _isBean
        );
    }

    function startCropClash(
        uint256 _cropClashId
    ) external onlyHuman whenNotPaused returns (uint256) {
        (
            uint256 _seed,
            uint256 _clashId,
            uint256 _reward,
            bool _isBean
        ) = cropClash.start(_cropClashId);

        (
            address _firstUser, ,
            address _secondUser, ,
            address _winner,
            uint256 _winnerId
        ) = farmhand.getCropClashParticipants(_cropClashId);

        _emitCropClashEnded(
            _cropClashId,
            _clashId,
            _winner,
            _winner != _firstUser ? _firstUser : _secondUser,
            _reward,
            _isBean
        );

        _emitClashHoedownForCropClash(
            _clashId,
            _seed,
            _cropClashId
        );

        return _winnerId;
    }

    function cancelCropClash(
        uint256 _clashId,
        bytes32 _applicantsHash
    ) external onlyHuman whenNotPaused {
        cropClash.cancel(msg.sender, _clashId, _applicantsHash);
        hoedown.emitCropClashCancelled(_clashId);
    }

    function returnBetFromCropClash(uint256 _clashId) external onlyHuman whenNotPaused {
        cropClash.returnBet(msg.sender, _clashId);
        hoedown.emitCropClashBetReturned(_clashId, msg.sender);
    }

    function addTimeForOpponentSelectForCropClash(uint256 _clashId) external onlyHuman whenNotPaused {
        uint256 _blockNumber = cropClash.addTimeForOpponentSelect(msg.sender, _clashId);
        hoedown.emitCropClashOpponentSelectTimeUpdated(_clashId, _blockNumber);
    }

    function updateBlockNumberOfCropClash(uint256 _clashId) external onlyHuman whenNotPaused {
        uint256 _blockNumber = cropClash.updateClashBlockNumber(_clashId);
        hoedown.emitCropClashBlockNumberUpdated(_clashId, _blockNumber);
    }

    function placeFanBetOnCropClash(
        uint256 _clashId,
        bool _willCreatorWin,
        uint256 _value
    ) external payable onlyHuman whenNotPaused {
        address(cropClashFan).transfer(msg.value);
        bool _isBean = cropClashFan.placeBet(msg.sender, _clashId, _willCreatorWin, _value, msg.value);
        hoedown.emitCropClashFanBetPlaced(_clashId, msg.sender, _willCreatorWin, _value, _isBean);
    }

    function removeFanBetFromCropClash(
        uint256 _clashId
    ) external onlyHuman whenNotPaused {
        cropClashFan.removeBet(msg.sender, _clashId);
        hoedown.emitCropClashFanBetRemoved(_clashId, msg.sender);
    }

    function requestFanRewardForCropClash(
        uint256 _clashId
    ) external onlyHuman whenNotPaused {
        (uint256 _reward, bool _isBean) = cropClashFan.requestReward(msg.sender, _clashId);
        hoedown.emitCropClashFanRewardPaidOut(_clashId, msg.sender, _reward, _isBean);
    }

     

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        clashFarmer = ClashFarmer(_newDependencies[0]);
        cropClash = CropClash(_newDependencies[1]);
        cropClashFan = CropClashFan(_newDependencies[2]);
        farmhand = Farmhand(_newDependencies[3]);
        hoedown = Hoedown(_newDependencies[4]);
    }
}
