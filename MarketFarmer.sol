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
import "./Market/CloningMarket.sol";
import "./Market/SeedMarket.sol";
import "./Market/TomatoMarket.sol";
import "./Market/Bean/BeanMarket.sol";
import "./Market/AbilityMarket.sol";
import "./Tomato/TomatoSilo.sol";
import "./Seed/SeedSilo.sol";
import "./Bean/Bean.sol";
import "./Farmhand.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract MarketFarmer 
// ----------------------------------------------------------------------------

contract MarketFarmer is Upgradable {
    using SafeMath256 for uint256;
    Farm farm;
    CloningMarket cloningMarket;
    SeedMarket seedMarket;
    TomatoMarket tomatoMarket;
    BeanMarket beanMarket;
    AbilityMarket abilityMarket;
    TomatoSilo tomatoSilo;
    SeedSilo seedSilo;
    Bean beanStalks;
    Farmhand farmhand;

    function _isSeedOwner(address _user, uint256 _tokenId) internal view returns (bool) {
        return _user == seedSilo.ownerOf(_tokenId);
    }

    function _isTomatoOwner(address _user, uint256 _tokenId) internal view returns (bool) {
        return _user == tomatoSilo.ownerOf(_tokenId);
    }

    function _checkOwner(bool _isOwner) internal pure {
        require(_isOwner, "not an owner");
    }

    function _checkSeedOwner(uint256 _tokenId, address _user) internal view {
        _checkOwner(_isSeedOwner(_user, _tokenId));
    }

    function _checkTomatoOwner(uint256 _tokenId, address _user) internal view {
        _checkOwner(_isTomatoOwner(_user, _tokenId));
    }

    function _compareBuyerAndSeller(address _buyer, address _seller) internal pure {
        require(_buyer != _seller, "seller can't be buyer");
    }

    function _checkTheTomatoIsNotInCropClash(uint256 _id) internal view {
        require(!farmhand.isTomatoInCropClash(_id), "tomato participates in crop clash");
    }

    function _checkIfCloningIsAllowed(uint256 _id) internal view {
        require(farmhand.isTomatoCloningAllowed(_id), "tomato has no enough DNA points for cloning");
    }

    function _checkEnoughBean(uint256 _required, uint256 _available) internal pure {
        require(_required <= _available, "not enough bean");
    }

    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return b > a ? 0 : a.sub(b);
    }

    function _transferBean(address _to, uint256 _value) internal {
        beanStalks.remoteTransfer(_to, _value);
    }

    function buySeed(
        address _sender,
        uint256 _value,
        uint256 _id,
        uint256 _expectedPrice,
        bool _isBean
    ) external onlyFarmer returns (address seller, uint256 price, bool success) {
        seller = seedMarket.sellerOf(_id);
        _compareBuyerAndSeller(_sender, seller);

        if (seedSilo.isApprovedOrOwner(this, _id) && _isSeedOwner(seller, _id)) {
            uint256 _balance = beanStalks.balanceOf(_sender);
            price = seedMarket.buyToken(_id, _isBean ? _balance : _value, _expectedPrice, _isBean);
            seedSilo.transferFrom(seller, _sender, _id);
            if (_isBean) {
                _transferBean(seller, price);
            }
            success = true;
        } else {
            seedMarket.removeFromAuction(_id);
            success = false;
        }
    }

    function sellSeed(
        address _sender,
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isBean
    ) external onlyFarmer {
        _checkSeedOwner(_id, _sender);
        require(!farm.isSeedInSoil(_id), "seed is in soil");
        seedSilo.remoteApprove(this, _id);
        seedMarket.sellToken(_id, _sender, _maxPrice, _minPrice, _period, _isBean);
    }

    function removeSeedFromSale(
        address _sender,
        uint256 _id
    ) external onlyFarmer {
        _checkSeedOwner(_id, _sender);
        seedMarket.removeFromAuction(_id);
    }

    function buyTomato(
        address _sender,
        uint256 _value,
        uint256 _id,
        uint256 _expectedPrice,
        bool _isBean
    ) external onlyFarmer returns (address seller, uint256 price, bool success) {
        seller = tomatoMarket.sellerOf(_id);
        _compareBuyerAndSeller(_sender, seller);

        if (tomatoSilo.isApprovedOrOwner(this, _id) && _isTomatoOwner(seller, _id)) {
            uint256 _balance = beanStalks.balanceOf(_sender);
            price = tomatoMarket.buyToken(_id, _isBean ? _balance : _value, _expectedPrice, _isBean);
            tomatoSilo.transferFrom(seller, _sender, _id);
            if (_isBean) {
                _transferBean(seller, price);
            }
            success = true;
        } else {
            tomatoMarket.removeFromAuction(_id);
            success = false;
        }
    }

    function sellTomato(
        address _sender,
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isBean
    ) external onlyFarmer {
        _checkTomatoOwner(_id, _sender);
        _checkTheTomatoIsNotInCropClash(_id);
        require(cloningMarket.sellerOf(_id) == address(0), "tomato is on cloning sale");
        tomatoSilo.remoteApprove(this, _id);

        tomatoMarket.sellToken(_id, _sender, _maxPrice, _minPrice, _period, _isBean);
    }

    function removeTomatoFromSale(
        address _sender,
        uint256 _id
    ) external onlyFarmer {
        _checkTomatoOwner(_id, _sender);
        tomatoMarket.removeFromAuction(_id);
    }

    function buyCloning(
        address _sender,
        uint256 _value,
        uint256 _a_donorId,
        uint256 _b_donorId,
        uint256 _expectedPrice,
        bool _isBean
    ) external onlyFarmer returns (uint256 seedId, address seller, uint256 price, bool success) {
        _checkIfCloningIsAllowed(_a_donorId);
        require(_a_donorId != _b_donorId, "the same tomato");
        _checkTomatoOwner(_a_donorId, _sender);
        seller = cloningMarket.sellerOf(_b_donorId);
        _compareBuyerAndSeller(_sender, seller);

        if (farmhand.isTomatoCloningAllowed(_b_donorId) && _isTomatoOwner(seller, _b_donorId)) {
            uint256 _balance = beanStalks.balanceOf(_sender);
            price = cloningMarket.buyToken(_b_donorId, _isBean ? _balance : _value, _expectedPrice, _isBean);
            seedId = farm.cultivar(_sender, _a_donorId, _b_donorId);
            if (_isBean) {
                _transferBean(seller, price);
            }
            success = true;
        } else {
            cloningMarket.removeFromAuction(_b_donorId);
            success = false;
        }
    }

    function sellCloning(
        address _sender,
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isBean
    ) external onlyFarmer {
        _checkIfCloningIsAllowed(_id);
        _checkTomatoOwner(_id, _sender);
        _checkTheTomatoIsNotInCropClash(_id);
        require(tomatoMarket.sellerOf(_id) == address(0), "tomato is on sale");
        cloningMarket.sellToken(_id, _sender, _maxPrice, _minPrice, _period, _isBean);
    }

    function removeCloningFromSale(
        address _sender,
        uint256 _id
    ) external onlyFarmer {
        _checkTomatoOwner(_id, _sender);
        cloningMarket.removeFromAuction(_id);
    }

    function buyAbility(
        address _sender,
        uint256 _id,
        uint256 _target,
        uint256 _expectedPrice,
        uint32 _expectedEffect
    ) external onlyFarmer returns (address seller, uint256 price, bool success) {
        if (tomatoSilo.exists(_id)) {
            price = abilityMarket.getAuction(_id);
            seller = tomatoSilo.ownerOf(_id);
            _compareBuyerAndSeller(_sender, seller);
            _checkTheTomatoIsNotInCropClash(_id);
            _checkTheTomatoIsNotInCropClash(_target);
            require(price <= _expectedPrice, "wrong price");
            uint256 _balance = beanStalks.balanceOf(_sender);
            _checkEnoughBean(price, _balance);

            ( , , uint32 _effect) = farmhand.getTomatoSpecialPeacefulAbility(_id);
            require(_effect >= _expectedEffect, "effect decreased");
            farm.useTomatoSpecialPeacefulAbility(seller, _id, _target);
            _transferBean(seller, price);
            success = true;
        } else {
            abilityMarket.removeFromAuction(_id);
            success = false;
        }
    }

    function sellAbility(
        address _sender,
        uint256 _id,
        uint256 _price
    ) external onlyFarmer {
        _checkTomatoOwner(_id, _sender);
        _checkTheTomatoIsNotInCropClash(_id);
        (uint8 _abilityClass, , ) = farmhand.getTomatoSpecialPeacefulAbility(_id);
        require(_abilityClass > 0, "special peaceful ability is not yet set");
        abilityMarket.sellToken(_id, _price);
    }

    function removeAbilityFromSale(
        address _sender,
        uint256 _id
    ) external onlyFarmer {
        _checkTomatoOwner(_id, _sender);
        abilityMarket.removeFromAuction(_id);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);
        farm = Farm(_newDependencies[0]);
        tomatoSilo = TomatoSilo(_newDependencies[1]);
        seedSilo = SeedSilo(_newDependencies[2]);
        tomatoMarket = TomatoMarket(_newDependencies[3]);
        cloningMarket = CloningMarket(_newDependencies[4]);
        seedMarket = SeedMarket(_newDependencies[5]);
        beanMarket = BeanMarket(_newDependencies[6]);
        abilityMarket = AbilityMarket(_newDependencies[7]);
        beanStalks = Bean(_newDependencies[8]);
        farmhand = Farmhand(_newDependencies[9]);
    }
}
