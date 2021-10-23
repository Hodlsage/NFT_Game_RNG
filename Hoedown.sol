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

// ----------------------------------------------------------------------------
// --- Contract Hoedown 
// ----------------------------------------------------------------------------

contract Hoedown is Upgradable {
    event SeedClaimed(address indexed user, uint256 indexed id);
    event SeedSentToSoil(address indexed user, uint256 indexed id);
    event SeedSprouted(address indexed user, uint256 indexed tomatoId, uint256 indexed seedId);
    event TomatoUpgraded(uint256 indexed id);
    event SeedCreated(address indexed user, uint256 indexed id);
    event TomatoOnSale(address indexed seller, uint256 indexed id);
    event TomatoRemovedFromSale(address indexed seller, uint256 indexed id);
    event TomatoRemovedFromCloning(address indexed seller, uint256 indexed id);
    event TomatoOnCloning(address indexed seller, uint256 indexed id);
    event TomatoBought(address indexed buyer, address indexed seller, uint256 indexed id, uint256 price);
    event TomatoCloningBought(address indexed buyer, address indexed seller, uint256 indexed id, uint256 price);
    event HarvestUpdated(uint256 restAmount, uint256 lastBlock, uint256 interval);
    event SeedOnSale(address indexed seller, uint256 indexed id);
    event SeedRemovedFromSale(address indexed seller, uint256 indexed id);
    event SeedBought(address indexed buyer, address indexed seller, uint256 indexed id, uint256 price);
    event BeanSellOrderCreated(address indexed seller, uint256 price, uint256 amount);
    event BeanSellOrderCancelled(address indexed seller);
    event BeanSold(address indexed buyer, address indexed seller, uint256 amount, uint256 price);
    event BeanBuyOrderCreated(address indexed buyer, uint256 price, uint256 amount);
    event BeanBuyOrderCancelled(address indexed buyer);
    event BeanBought(address indexed seller, address indexed buyer, uint256 amount, uint256 price);
    event AbilityOnSale(address indexed seller, uint256 indexed id);
    event AbilityRemovedFromSale(address indexed seller, uint256 indexed id);
    event AbilityBought(address indexed buyer, address indexed seller, uint256 id, uint256 indexed target, uint256 price);
    event AbilitySet(uint256 indexed id);
    event AbilityUsed(uint256 indexed id, uint256 indexed target);
    event TomatoNameSet(uint256 indexed id, bytes32 name);
    event TomatoTacticsSet(uint256 indexed id, uint8 melee, uint8 attack);
    event UserNameSet(address indexed user, bytes32 name);
    event ClashEnded(
        uint256 indexed clashId,
        uint256 date,
        uint256 seed,
        uint256 attackerId,
        uint256 indexed winnerId,
        uint256 indexed looserId,
        bool isCrop,
        uint256 cropClashId
    );
    event ClashTomatosDetails(
        uint256 indexed clashId,
        uint8 winnerLevel,
        uint32 winnerRarity,
        uint8 looserLevel,
        uint32 looserRarity
    );
    event ClashHealthAndRadiation(
        uint256 indexed clashId,
        uint32 attackerMaxHealth,
        uint32 attackerMaxRadiation,
        uint32 attackerInitHealth,
        uint32 attackerInitRadiation,
        uint32 opponentMaxHealth,
        uint32 opponentMaxRadiation,
        uint32 opponentInitHealth,
        uint32 opponentInitRadiation
    );
    event ClashAbilitys(
        uint256 indexed clashId,
        uint32 attackerAttack,
        uint32 attackerDefense,
        uint32 attackerStamina,
        uint32 attackerSpeed,
        uint32 attackerIntelligence,
        uint32 opponentAttack,
        uint32 opponentDefense,
        uint32 opponentStamina,
        uint32 opponentSpeed,
        uint32 opponentIntelligence
    );
    event ClashTacticsAndBuffs(
        uint256 indexed clashId,
        uint8 attackerMeleeChance,
        uint8 attackerAttackChance,
        uint8 opponentMeleeChance,
        uint8 opponentAttackChance,
        uint32[5] attackerBuffs,
        uint32[5] opponentBuffs
    );
    event CropClashEnded(
        uint256 indexed id,
        uint256 clashId,
        address indexed winner,
        address indexed looser,
        uint256 reward,
        bool isBean
    );
    event CropClashCreated(
        uint256 indexed id,
        address indexed user,
        uint256 indexed tomatoId,
        uint256 bet,
        bool isBean
    );
    event CropClashApplicantAdded(
        uint256 indexed id,
        address indexed user,
        uint256 indexed tomatoId
    );
    event CropClashOpponentSelected(
        uint256 indexed id,
        uint256 indexed tomatoId
    );
    event CropClashCancelled(uint256 indexed id);
    event CropClashBetReturned(uint256 indexed id, address indexed user);
    event CropClashOpponentSelectTimeUpdated(uint256 indexed id, uint256 blockNumber);
    event CropClashBlockNumberUpdated(uint256 indexed id, uint256 blockNumber);
    event CropClashFanBetPlaced(
        uint256 indexed id,
        address indexed user,
        bool indexed willCreatorWin,
        uint256 bet,
        bool isBean
    );
    event CropClashFanBetRemoved(uint256 indexed id, address indexed user);
    event CropClashFanRewardPaidOut(
        uint256 indexed id,
        address indexed user,
        uint256 reward,
        bool isBean
    );
    event RankingRewardsDistributed(uint256[10] tomatos, address[10] users);

    function emitSeedClaimed(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit SeedClaimed(_user, _id);
    }

    function emitSeedSentToSoil(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit SeedSentToSoil(_user, _id);
    }

    function emitTomatoUpgraded(
        uint256 _id
    ) external onlyFarmer {
        emit TomatoUpgraded(_id);
    }

    function emitSeedSprouted(
        address _user,
        uint256 _tomatoId,
        uint256 _seedId
    ) external onlyFarmer {
        emit SeedSprouted(_user, _tomatoId, _seedId);
    }

    function emitSeedCreated(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit SeedCreated(_user, _id);
    }

    function emitTomatoOnSale(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit TomatoOnSale(_user, _id);
    }

    function emitTomatoRemovedFromSale(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit TomatoRemovedFromSale(_user, _id);
    }

    function emitTomatoRemovedFromCloning(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit TomatoRemovedFromCloning(_user, _id);
    }

    function emitTomatoOnCloning(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit TomatoOnCloning(_user, _id);
    }

    function emitTomatoBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _price
    ) external onlyFarmer {
        emit TomatoBought(_buyer, _seller, _id, _price);
    }

    function emitTomatoCloningBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _price
    ) external onlyFarmer {
        emit TomatoCloningBought(_buyer, _seller, _id, _price);
    }

    function emitHarvestUpdated(
        uint256 _restAmount,
        uint256 _lastBlock,
        uint256 _interval
    ) external onlyFarmer {
        emit HarvestUpdated(_restAmount, _lastBlock, _interval);
    }

    function emitSeedOnSale(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit SeedOnSale(_user, _id);
    }

    function emitSeedRemovedFromSale(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit SeedRemovedFromSale(_user, _id);
    }

    function emitSeedBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _price
    ) external onlyFarmer {
        emit SeedBought(_buyer, _seller, _id, _price);
    }

    function emitBeanSellOrderCreated(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        emit BeanSellOrderCreated(_user, _price, _amount);
    }

    function emitBeanSellOrderCancelled(
        address _user
    ) external onlyFarmer {
        emit BeanSellOrderCancelled(_user);
    }

    function emitBeanSold(
        address _buyer,
        address _seller,
        uint256 _amount,
        uint256 _price
    ) external onlyFarmer {
        emit BeanSold(_buyer, _seller, _amount, _price);
    }

    function emitBeanBuyOrderCreated(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        emit BeanBuyOrderCreated(_user, _price, _amount);
    }

    function emitBeanBuyOrderCancelled(
        address _user
    ) external onlyFarmer {
        emit BeanBuyOrderCancelled(_user);
    }

    function emitBeanBought(
        address _buyer,
        address _seller,
        uint256 _amount,
        uint256 _price
    ) external onlyFarmer {
        emit BeanBought(_buyer, _seller, _amount, _price);
    }

    function emitAbilityOnSale(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit AbilityOnSale(_user, _id);
    }

    function emitAbilityRemovedFromSale(
        address _user,
        uint256 _id
    ) external onlyFarmer {
        emit AbilityRemovedFromSale(_user, _id);
    }

    function emitAbilityBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _target,
        uint256 _price
    ) external onlyFarmer {
        emit AbilityBought(_buyer, _seller, _id, _target, _price);
    }

    function emitAbilitySet(
        uint256 _id
    ) external onlyFarmer {
        emit AbilitySet(_id);
    }

    function emitAbilityUsed(
        uint256 _id,
        uint256 _target
    ) external onlyFarmer {
        emit AbilityUsed(_id, _target);
    }

    function emitTomatoNameSet(
        uint256 _id,
        bytes32 _name
    ) external onlyFarmer {
        emit TomatoNameSet(_id, _name);
    }

    function emitTomatoTacticsSet(
        uint256 _id,
        uint8 _melee,
        uint8 _attack
    ) external onlyFarmer {
        emit TomatoTacticsSet(_id, _melee, _attack);
    }

    function emitUserNameSet(
        address _user,
        bytes32 _name
    ) external onlyFarmer {
        emit UserNameSet(_user, _name);
    }

    function emitClashEnded(
        uint256 _clashId,
        uint256 _date,
        uint256 _seed,
        uint256 _attackerId,
        uint256 _winnerId,
        uint256 _looserId,
        bool _isCrop,
        uint256 _cropClashId
    ) external onlyFarmer {
        emit ClashEnded(
            _clashId,
            _date,
            _seed,
            _attackerId,
            _winnerId,
            _looserId,
            _isCrop,
            _cropClashId
        );
    }

    function emitClashTomatosDetails(
        uint256 _clashId,
        uint8 _winnerLevel,
        uint32 _winnerRarity,
        uint8 _looserLevel,
        uint32 _looserRarity
    ) external onlyFarmer {
        emit ClashTomatosDetails(
            _clashId,
            _winnerLevel,
            _winnerRarity,
            _looserLevel,
            _looserRarity
        );
    }

    function emitClashHealthAndRadiation(
        uint256 _clashId,
        uint32 _attackerMaxHealth,
        uint32 _attackerMaxRadiation,
        uint32 _attackerInitHealth,
        uint32 _attackerInitRadiation,
        uint32 _opponentMaxHealth,
        uint32 _opponentMaxRadiation,
        uint32 _opponentInitHealth,
        uint32 _opponentInitRadiation
    ) external onlyFarmer {
        emit ClashHealthAndRadiation(
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

    function emitClashAbilitys(
        uint256 _clashId,
        uint32 _attackerAttack,
        uint32 _attackerDefense,
        uint32 _attackerStamina,
        uint32 _attackerSpeed,
        uint32 _attackerIntelligence,
        uint32 _opponentAttack,
        uint32 _opponentDefense,
        uint32 _opponentStamina,
        uint32 _opponentSpeed,
        uint32 _opponentIntelligence
    ) external onlyFarmer {
        emit ClashAbilitys(
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

    function emitClashTacticsAndBuffs(
        uint256 _clashId,
        uint8 _attackerMeleeChance,
        uint8 _attackerAttackChance,
        uint8 _opponentMeleeChance,
        uint8 _opponentAttackChance,
        uint32[5] _attackerBuffs,
        uint32[5] _opponentBuffs
    ) external onlyFarmer {
        emit ClashTacticsAndBuffs(
            _clashId,
            _attackerMeleeChance,
            _attackerAttackChance,
            _opponentMeleeChance,
            _opponentAttackChance,
            _attackerBuffs,
            _opponentBuffs
        );
    }

    function emitCropClashEnded(
        uint256 _id,
        uint256 _clashId,
        address _winner,
        address _looser,
        uint256 _reward,
        bool _isBean
    ) external onlyFarmer {
        emit CropClashEnded(
            _id,
            _clashId,
            _winner,
            _looser,
            _reward,
            _isBean
        );
    }

    function emitCropClashCreated(
        uint256 _id,
        address _user,
        uint256 _tomatoId,
        uint256 _bet,
        bool _isBean
    ) external onlyFarmer {
        emit CropClashCreated(
            _id,
            _user,
            _tomatoId,
            _bet,
            _isBean
        );
    }

    function emitCropClashApplicantAdded(
        uint256 _id,
        address _user,
        uint256 _tomatoId
    ) external onlyFarmer {
        emit CropClashApplicantAdded(
            _id,
            _user,
            _tomatoId
        );
    }

    function emitCropClashOpponentSelected(
        uint256 _id,
        uint256 _tomatoId
    ) external onlyFarmer {
        emit CropClashOpponentSelected(
            _id,
            _tomatoId
        );
    }

    function emitCropClashCancelled(
        uint256 _id
    ) external onlyFarmer {
        emit CropClashCancelled(
            _id
        );
    }

    function emitCropClashBetReturned(
        uint256 _id,
        address _user
    ) external onlyFarmer {
        emit CropClashBetReturned(
            _id,
            _user
        );
    }

    function emitCropClashOpponentSelectTimeUpdated(
        uint256 _id,
        uint256 _blockNumber
    ) external onlyFarmer {
        emit CropClashOpponentSelectTimeUpdated(
            _id,
            _blockNumber
        );
    }

    function emitCropClashBlockNumberUpdated(
        uint256 _id,
        uint256 _blockNumber
    ) external onlyFarmer {
        emit CropClashBlockNumberUpdated(
            _id,
            _blockNumber
        );
    }

    function emitCropClashFanBetPlaced(
        uint256 _id,
        address _user,
        bool _willCreatorWin,
        uint256 _value,
        bool _isBean
    ) external onlyFarmer {
        emit CropClashFanBetPlaced(
            _id,
            _user,
            _willCreatorWin,
            _value,
            _isBean
        );
    }

    function emitCropClashFanBetRemoved(
        uint256 _id,
        address _user
    ) external onlyFarmer {
        emit CropClashFanBetRemoved(
            _id,
            _user
        );
    }

    function emitCropClashFanRewardPaidOut(
        uint256 _id,
        address _user,
        uint256 _value,
        bool _isBean
    ) external onlyFarmer {
        emit CropClashFanRewardPaidOut(
            _id,
            _user,
            _value,
            _isBean
        );
    }

    function emitRankingRewardsDistributed(
        uint256[10] _tomatos,
        address[10] _users
    ) external onlyFarmer {
        emit RankingRewardsDistributed(
            _tomatos,
            _users
        );
    }
}
