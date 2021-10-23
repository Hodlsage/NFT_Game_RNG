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

import "./Common/Pausable.sol";
import "./Common/Upgradable.sol";
import "./Common/HumanOriented.sol";
import "./FarmFarmer.sol";
import "./User.sol";
import "./Hoedown.sol";

// ----------------------------------------------------------------------------
// --- Contract PrimeFarmhouse 
// ----------------------------------------------------------------------------

contract PrimeFarmhouse is Pausable, Upgradable, HumanOriented {
    FarmFarmer farmFarmer;
    User user;
    Hoedown hoedown;

    function claimSeed(uint8 _tomatoType) external onlyHuman whenNotPaused {
        (
            uint256 _seedId,
            uint256 _restAmount,
            uint256 _lastBlock,
            uint256 _interval
        ) = farmFarmer.claimSeed(msg.sender, _tomatoType);

        hoedown.emitSeedClaimed(msg.sender, _seedId);
        hoedown.emitHarvestUpdated(_restAmount, _lastBlock, _interval);
    }

    function sendToSoil(
        uint256 _seedId
    ) external onlyHuman whenNotPaused {
        (
            bool _isSprouted,
            uint256 _newTomatoId,
            uint256 _sproutedId,
            address _owner
        ) = farmFarmer.sendToSoil(msg.sender, _seedId);

        hoedown.emitSeedSentToSoil(msg.sender, _seedId);

        if (_isSprouted) {
            hoedown.emitSeedSprouted(_owner, _newTomatoId, _sproutedId);
        }
    }

    function cultivar(uint256 _a_donorId, uint256 _b_donorId) external onlyHuman whenNotPaused {
        uint256 seedId = farmFarmer.cultivar(msg.sender, _a_donorId, _b_donorId);
        hoedown.emitSeedCreated(msg.sender, seedId);
    }

    function upgradeTomatoGenes(uint256 _id, uint16[10] _dnaPoints) external onlyHuman whenNotPaused {
        farmFarmer.upgradeTomatoGenes(msg.sender, _id, _dnaPoints);
        hoedown.emitTomatoUpgraded(_id);
    }

    function setTomatoTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyHuman whenNotPaused {
        farmFarmer.setTomatoTactics(msg.sender, _id, _melee, _attack);
        hoedown.emitTomatoTacticsSet(_id, _melee, _attack);
    }

    function setTomatoName(uint256 _id, string _name) external onlyHuman whenNotPaused returns (bytes32 name) {
        name = farmFarmer.setTomatoName(msg.sender, _id, _name);
        hoedown.emitTomatoNameSet(_id, name);
    }

    function setTomatoSpecialPeacefulAbility(uint256 _id, uint8 _class) external onlyHuman whenNotPaused {
        farmFarmer.setTomatoSpecialPeacefulAbility(msg.sender, _id, _class);
        hoedown.emitAbilitySet(_id);
    }

    function useTomatoSpecialPeacefulAbility(uint256 _id, uint256 _target) external onlyHuman whenNotPaused {
        farmFarmer.useTomatoSpecialPeacefulAbility(msg.sender, _id, _target);
        hoedown.emitAbilityUsed(_id, _target);
    }

    function distributeRankingRewards() external onlyHuman whenNotPaused {
        (
            uint256[10] memory _tomatos,
            address[10] memory _users
        ) = farmFarmer.distributeRankingRewards();
        hoedown.emitRankingRewardsDistributed(_tomatos, _users);
    }

    function setName(string _name) external onlyHuman whenNotPaused returns (bytes32 name) {
        name = user.setName(msg.sender, _name);
        hoedown.emitUserNameSet(msg.sender, name);
    }

    function getName(address _user) external view returns (bytes32) {
        return user.getName(_user);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies)
        farmFarmer = FarmFarmer(_newDependencies[0]);
        user = User(_newDependencies[1]);
        hoedown = Hoedown(_newDependencies[2]);
    }
}
