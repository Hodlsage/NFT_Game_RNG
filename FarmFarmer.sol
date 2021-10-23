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
import "./Farm.sol";
import "./Farmhand.sol";
import "./Field.sol";
import "./Harvest.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract FarmFarmer 
// ----------------------------------------------------------------------------

contract FarmFarmer is Upgradable {
    using SafeMath256 for uint256;

    Farm farm;
    Field field;
    Farmhand farmhand;
    Harvest harvest;

    function _isTomatoOwner(address _user, uint256 _id) internal view returns (bool) {
        return farmhand.isTomatoOwner(_user, _id);
    }

    function _checkTheTomatoIsNotInCropClash(uint256 _id) internal view {
        require(!farmhand.isTomatoInCropClash(_id), "tomato participates in crop clash");
    }

    function _checkTheTomatoIsNotOnSale(uint256 _id) internal view {
        require(!farmhand.isTomatoOnSale(_id), "tomato is on sale");
    }

    function _checkTheTomatoIsNotOnCloning(uint256 _id) internal view {
        require(!farmhand.isCloningOnSale(_id), "tomato is on cloning sale");
    }

    function _checkThatEnoughDNAPoints(uint256 _id) internal view {
        require(farmhand.isTomatoCloningAllowed(_id), "tomato has no enough DNA points for cloning");
    }

    function _checkTomatoOwner(address _user, uint256 _id) internal view {
        require(_isTomatoOwner(_user, _id), "not an owner");
    }

    function claimSeed(
        address _sender,
        uint8 _tomatoType
    ) external onlyFarmer returns (
        uint256 seedId,
        uint256 restAmount,
        uint256 lastBlock,
        uint256 interval
    ) {
        (restAmount, lastBlock, interval) = harvest.claim(_tomatoType);
        seedId = farm.createSeed(_sender, _tomatoType);

        uint256 _beanReward = field.sproutingPrice();
        uint256 _beanAmount = field.remainingBean();
        if (_beanReward > _beanAmount) _beanReward = _beanAmount;
        field.giveBean(_sender, _beanReward);
    }

    function sendToSoil(
        address _sender,
        uint256 _seedId
    ) external onlyFarmer returns (bool, uint256, uint256, address) {
        require(!farmhand.isSeedOnSale(_seedId), "seed is on sale");
        require(farm.isSeedOwner(_sender, _seedId), "not a seed owner");

        uint256 _sproutingPrice = field.sproutingPrice();
        field.takeBean(_sproutingPrice);
        if (farmhand.getTomatosAmount() > 2997) { 
            field.burnBean(_sproutingPrice.div(2));
        }

        return farm.sendToSoil(_seedId);
    }

    function cultivar(
        address _sender,
        uint256 _a_donorId,
        uint256 _b_donorId
    ) external onlyFarmer returns (uint256 seedId) {
        _checkThatEnoughDNAPoints(_a_donorId);
        _checkThatEnoughDNAPoints(_b_donorId);
        _checkTheTomatoIsNotOnCloning(_a_donorId);
        _checkTheTomatoIsNotOnCloning(_b_donorId);
        _checkTheTomatoIsNotOnSale(_a_donorId);
        _checkTheTomatoIsNotOnSale(_b_donorId);
        _checkTheTomatoIsNotInCropClash(_a_donorId);
        _checkTheTomatoIsNotInCropClash(_b_donorId);
        _checkTomatoOwner(_sender, _a_donorId);
        _checkTomatoOwner(_sender, _b_donorId);
        require(_a_donorId != _b_donorId, "the same tomato");
        return farm.cultivar(_sender, _a_donorId, _b_donorId);
    }

    function upgradeTomatoGenes(
        address _sender,
        uint256 _id,
        uint16[10] _dnaPoints
    ) external onlyFarmer {
        _checkTheTomatoIsNotOnCloning(_id);
        _checkTheTomatoIsNotOnSale(_id);
        _checkTheTomatoIsNotInCropClash(_id);
        _checkTomatoOwner(_sender, _id);
        farm.upgradeTomatoGenes(_id, _dnaPoints);
    }

    function setTomatoTactics(
        address _sender,
        uint256 _id,
        uint8 _melee,
        uint8 _attack
    ) external onlyFarmer {
        _checkTomatoOwner(_sender, _id);
        farm.setTomatoTactics(_id, _melee, _attack);
    }

    function setTomatoName(
        address _sender,
        uint256 _id,
        string _name
    ) external onlyFarmer returns (bytes32) {
        _checkTomatoOwner(_sender, _id);

        uint256 _length = bytes(_name).length;
        uint256 _price = farmhand.getTomatoNamePriceByLength(_length);

        if (_price > 0) {
            field.takeBean(_price);
        }

        return farm.setTomatoName(_id, _name);
    }

    function setTomatoSpecialPeacefulAbility(address _sender, uint256 _id, uint8 _class) external onlyFarmer {
        _checkTomatoOwner(_sender, _id);
        farm.setTomatoSpecialPeacefulAbility(_id, _class);
    }

    function useTomatoSpecialPeacefulAbility(address _sender, uint256 _id, uint256 _target) external onlyFarmer {
        _checkTomatoOwner(_sender, _id);
        _checkTheTomatoIsNotInCropClash(_id);
        _checkTheTomatoIsNotInCropClash(_target);
        farm.useTomatoSpecialPeacefulAbility(_sender, _id, _target);
    }

    function distributeRankingRewards() external onlyFarmer returns (
        uint256[10] tomatos,
        address[10] users
    ) {
        farm.updateRankingRewardTime();
        uint256 _remainingBean = field.remainingBean();
        uint256[10] memory _rewards = farm.getRankingRewards(_remainingBean);

        tomatos = farm.getTomatosFromRanking();
        uint8 i;
        for (i = 0; i < tomatos.length; i++) {
            if (tomatos[i] == 0) continue;
            users[i] = farmhand.ownerOfTomato(tomatos[i]);
        }

        uint256 _reward;
        for (i = 0; i < users.length; i++) {
            if (_remainingBean == 0) break;
            if (users[i] == address(0)) continue;

            _reward = _rewards[i];
            if (_reward > _remainingBean) {
                _reward = _remainingBean;
            }
            field.giveBean(users[i], _reward);
            _remainingBean = _remainingBean.sub(_reward);
        }
    }  

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        farm = Farm(_newDependencies[0]);
        field = Field(_newDependencies[1]);
        farmhand = Farmhand(_newDependencies[2]);
        harvest = Harvest(_newDependencies[3]);
    }
}
