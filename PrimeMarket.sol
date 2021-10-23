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
import "./MarketFarmer.sol";
import "./Market/Bean/BeanMarket.sol";
import "./Hoedown.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract PrimeMarket 
// ----------------------------------------------------------------------------

contract PrimeMarket is Pausable, Upgradable, HumanOriented {
    using SafeMath256 for uint256;

    MarketFarmer public marketplaceFarmer;
    BeanMarket beanMarket;
    Hoedown hoedown;

    function _transferEth(
        address _from,
        address _to,
        uint256 _available,
        uint256 _required_,
        bool _isBean
    ) internal {
        uint256 _required = _required_;
        if (_isBean) {
            _required = 0;
        }

        _to.transfer(_required);
        if (_available > _required) {
            _from.transfer(_available.sub(_required));
        }
    }

    function buySeed(
        uint256 _id,
        uint256 _expectedPrice,
        bool _isBean
    ) external onlyHuman whenNotPaused payable {
        (
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceFarmer.buySeed(
            msg.sender,
            msg.value,
            _id,
            _expectedPrice,
            _isBean
        );
        if (_success) {
            _transferEth(msg.sender, _seller, msg.value, _price, _isBean);
            hoedown.emitSeedBought(msg.sender, _seller, _id, _price);
        } else {
            msg.sender.transfer(msg.value);
            hoedown.emitSeedRemovedFromSale(_seller, _id);
        }
    }

    function sellSeed(
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isBean
    ) external onlyHuman whenNotPaused {
        marketplaceFarmer.sellSeed(msg.sender, _id, _maxPrice, _minPrice, _period, _isBean);
        hoedown.emitSeedOnSale(msg.sender, _id);
    }

    function removeSeedFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceFarmer.removeSeedFromSale(msg.sender, _id);
        hoedown.emitSeedRemovedFromSale(msg.sender, _id);
    }

    function buyTomato(
        uint256 _id,
        uint256 _expectedPrice,
        bool _isBean
    ) external onlyHuman whenNotPaused payable {
        (
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceFarmer.buyTomato(
            msg.sender,
            msg.value,
            _id,
            _expectedPrice,
            _isBean
        );
        if (_success) {
            _transferEth(msg.sender, _seller, msg.value, _price, _isBean);
            hoedown.emitTomatoBought(msg.sender, _seller, _id, _price);
        } else {
            msg.sender.transfer(msg.value);
            hoedown.emitTomatoRemovedFromSale(_seller, _id);
        }
    }

    function sellTomato(
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isBean
    ) external onlyHuman whenNotPaused {
        marketplaceFarmer.sellTomato(msg.sender, _id, _maxPrice, _minPrice, _period, _isBean);
        hoedown.emitTomatoOnSale(msg.sender, _id);
    }

    function removeTomatoFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceFarmer.removeTomatoFromSale(msg.sender, _id);
        hoedown.emitTomatoRemovedFromSale(msg.sender, _id);
    }

    function buyCloning(
        uint256 _a_donorId,
        uint256 _b_donorId,
        uint256 _expectedPrice,
        bool _isBean
    ) external onlyHuman whenNotPaused payable {
        (
            uint256 _seedId,
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceFarmer.buyCloning(
            msg.sender,
            msg.value,
            _a_donorId,
            _b_donorId,
            _expectedPrice,
            _isBean
        );
        if (_success) {
            hoedown.emitSeedCreated(msg.sender, _seedId);
            _transferEth(msg.sender, _seller, msg.value, _price, _isBean);
            hoedown.emitTomatoCloningBought(msg.sender, _seller, _b_donorId, _price);
        } else {
            msg.sender.transfer(msg.value);
            hoedown.emitTomatoRemovedFromCloning(_seller, _b_donorId);
        }
    }

    function sellCloning(
        uint256 _id,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint16 _period,
        bool _isBean
    ) external onlyHuman whenNotPaused {
        marketplaceFarmer.sellCloning(msg.sender, _id, _maxPrice, _minPrice, _period, _isBean);
        hoedown.emitTomatoOnCloning(msg.sender, _id);
    }

    function removeCloningFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceFarmer.removeCloningFromSale(msg.sender, _id);
        hoedown.emitTomatoRemovedFromCloning(msg.sender, _id);
    }

    function fillBeanSellOrder(
        address _seller,
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused payable {
        address(beanMarket).transfer(msg.value);
        uint256 _priceForOne = beanMarket.fillSellOrder(msg.sender, msg.value, _seller, _price, _amount);
        hoedown.emitBeanSold(msg.sender, _seller, _amount, _priceForOne);
    }

    function createBeanSellOrder(
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused {
        beanMarket.createSellOrder(msg.sender, _price, _amount);
        hoedown.emitBeanSellOrderCreated(msg.sender, _price, _amount);
    }

    function cancelBeanSellOrder() external onlyHuman whenNotPaused {
        beanMarket.cancelSellOrder(msg.sender);
        hoedown.emitBeanSellOrderCancelled(msg.sender);
    }

    function fillBeanBuyOrder(
        address _buyer,
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused {
        uint256 _priceForOne = beanMarket.fillBuyOrder(msg.sender, _buyer, _price, _amount);
        hoedown.emitBeanBought(msg.sender, _buyer, _amount, _priceForOne);
    }

    function createBeanBuyOrder(
        uint256 _price,
        uint256 _amount
    ) external onlyHuman whenNotPaused payable {
        address(beanMarket).transfer(msg.value);
        beanMarket.createBuyOrder(msg.sender, msg.value, _price, _amount);
        hoedown.emitBeanBuyOrderCreated(msg.sender, _price, _amount);
    }

    function cancelBeanBuyOrder() external onlyHuman whenNotPaused {
        beanMarket.cancelBuyOrder(msg.sender);
        hoedown.emitBeanBuyOrderCancelled(msg.sender);
    }

    function buyAbility(
        uint256 _id,
        uint256 _target,
        uint256 _expectedPrice,
        uint32 _expectedEffect
    ) external onlyHuman whenNotPaused {
        (
            address _seller,
            uint256 _price,
            bool _success
        ) = marketplaceFarmer.buyAbility(
            msg.sender,
            _id,
            _target,
            _expectedPrice,
            _expectedEffect
        );

        if (_success) {
            hoedown.emitAbilityBought(msg.sender, _seller, _id, _target, _price);
        } else {
            hoedown.emitAbilityRemovedFromSale(_seller, _id);
        }
    }

    function sellAbility(
        uint256 _id,
        uint256 _price
    ) external onlyHuman whenNotPaused {
        marketplaceFarmer.sellAbility(msg.sender, _id, _price);
        hoedown.emitAbilityOnSale(msg.sender, _id);
    }

    function removeAbilityFromSale(uint256 _id) external onlyHuman whenNotPaused {
        marketplaceFarmer.removeAbilityFromSale(msg.sender, _id);
        hoedown.emitAbilityRemovedFromSale(msg.sender, _id);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        marketplaceFarmer = MarketFarmer(_newDependencies[0]);
        beanMarket = BeanMarket(_newDependencies[1]);
        hoedown = Hoedown(_newDependencies[2]);
    }
}
