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
import "../../Common/SafeMath256.sol";
import "./BeanMarketSilo.sol";
import "../../Bean/Bean.sol";

// ----------------------------------------------------------------------------
// --- Contract BeanMarket 
// ----------------------------------------------------------------------------

contract BeanMarket is Upgradable {
    using SafeMath256 for uint256;

    BeanMarketSilo _silo_;
    Bean beanStalks;

    uint256 constant BEAN_DECIMALS = uint256(10) ** 18;


    function _calculateFullPrice(
        uint256 _price,
        uint256 _amount
    ) internal pure returns (uint256) {
        return _price.mul(_amount).div(BEAN_DECIMALS);
    }

    function _transferBean(address _to, uint256 _value) internal {
        beanStalks.remoteTransfer(_to, _value);
    }

    function _min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a <= _b ? _a : _b;
    }

    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        return b > a ? 0 : a.sub(b);
    }

    function _checkPrice(uint256 _value) internal pure {
        require(_value > 0, "price must be greater than 0");
    }

    function _checkAmount(uint256 _value) internal pure {
        require(_value > 0, "amount must be greater than 0");
    }

    function _checkActualPrice(uint256 _expected, uint256 _actual) internal pure {
        require(_expected == _actual, "wrong actual price");
    }

    function createSellOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        _checkPrice(_price);
        _checkAmount(_amount);
        _transferBean(address(_silo_), _amount);
        _silo_.createSellOrder(_user, _price, _amount);
    }

    function cancelSellOrder(address _user) external onlyFarmer {
        ( , , , uint256 _amount) = _silo_.orderOfSeller(_user);
        _silo_.transferBean(_user, _amount);
        _silo_.cancelSellOrder(_user);
    }

    function fillSellOrder(
        address _buyer,
        uint256 _value,
        address _seller,
        uint256 _expectedPrice,
        uint256 _amount
    ) external onlyFarmer returns (uint256 price) {
        uint256 _available;
        ( , , price, _available) = _silo_.orderOfSeller(_seller);
        _checkAmount(_amount);
        require(_amount <= _available, "seller has no enough bean");
        _checkActualPrice(_expectedPrice, price);
        uint256 _fullPrice = _calculateFullPrice(price, _amount);
        require(_fullPrice > 0, "no free bean, sorry");
        require(_fullPrice <= _value, "not enough ether");

        _seller.transfer(_fullPrice);
        if (_value > _fullPrice) {
            _buyer.transfer(_value.sub(_fullPrice));
        }
        _silo_.transferBean(_buyer, _amount);

        _available = _available.sub(_amount);

        if (_available == 0) {
            _silo_.cancelSellOrder(_seller);
        } else {
            _silo_.updateSellOrder(_seller, price, _available);
        }
    }

    function () external payable onlyFarmer {}

    function createBuyOrder(
        address _user,
        uint256 _value,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        _checkPrice(_price);
        _checkAmount(_amount);
        uint256 _fullPrice = _calculateFullPrice(_price, _amount);
        require(_fullPrice == _value, "wrong eth value");

        address(_silo_).transfer(_value);

        _silo_.createBuyOrder(_user, _price, _amount);
    }

    function cancelBuyOrder(address _user) external onlyFarmer {
        ( , address _buyer, uint256 _price, uint256 _amount) = _silo_.orderOfBuyer(_user);
        require(_buyer == _user, "user addresses are not equal");
        uint256 _fullPrice = _calculateFullPrice(_price, _amount);
        _silo_.transferEth(_user, _fullPrice);
        _silo_.cancelBuyOrder(_user);
    }

    function fillBuyOrder(
        address _seller,
        address _buyer,
        uint256 _expectedPrice,
        uint256 _amount
    ) external onlyFarmer returns (uint256 price) {
        uint256 _needed;
        ( , , price, _needed) = _silo_.orderOfBuyer(_buyer);

        _checkAmount(_amount);
        require(_amount <= _needed, "buyer do not need so much");
        _checkActualPrice(_expectedPrice, price);

        uint256 _fullPrice = _calculateFullPrice(price, _amount);

        _transferBean(_buyer, _amount);
        _silo_.transferEth(_seller, _fullPrice);

        _needed = _needed.sub(_amount);

        if (_needed == 0) {
            _silo_.cancelBuyOrder(_buyer);
        } else {
            _silo_.updateBuyOrder(_buyer, price, _needed);
        }
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        _silo_ = BeanMarketSilo(_newDependencies[0]);
        beanStalks = Bean(_newDependencies[1]);
    }
}
