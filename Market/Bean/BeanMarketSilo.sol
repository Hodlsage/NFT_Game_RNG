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
// --- Contract BeanMarketSilo 
// ----------------------------------------------------------------------------

contract BeanMarketSilo is Upgradable {
    using SafeMath256 for uint256;

    Bean beanStalks;

    struct Order {
        address user;
        uint256 price;
        uint256 amount;
    }

    mapping (address => uint256) public userToSellOrderIndex;
    mapping (address => uint256) public userToBuyOrderIndex;

    Order[] public sellOrders;
    Order[] public buyOrders;

    constructor() public {
        sellOrders.length = 1;
        buyOrders.length = 1;
    }

    function _ordersShouldExist(uint256 _amount) internal pure {
        require(_amount > 1, "no orders"); 
    }

    function _orderShouldNotExist(uint256 _index) internal pure {
        require(_index == 0, "order already exists");
    }

    function _orderShouldExist(uint256 _index) internal pure {
        require(_index != 0, "order does not exist");
    }

    function _sellOrderShouldExist(address _user) internal view {
        _orderShouldExist(userToSellOrderIndex[_user]);
    }

    function _buyOrderShouldExist(address _user) internal view {
        _orderShouldExist(userToBuyOrderIndex[_user]);
    }

    function transferBean(address _to, uint256 _value) external onlyFarmer {
        beanStalks.transfer(_to, _value);
    }

    function transferEth(address _to, uint256 _value) external onlyFarmer {
        _to.transfer(_value);
    }

    function createSellOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        _orderShouldNotExist(userToSellOrderIndex[_user]);

        Order memory _order = Order(_user, _price, _amount);
        userToSellOrderIndex[_user] = sellOrders.length;
        sellOrders.push(_order);
    }

    function cancelSellOrder(
        address _user
    ) external onlyFarmer {
        _sellOrderShouldExist(_user);
        _ordersShouldExist(sellOrders.length);

        uint256 _orderIndex = userToSellOrderIndex[_user];

        uint256 _lastOrderIndex = sellOrders.length.sub(1);
        Order memory _lastOrder = sellOrders[_lastOrderIndex];

        userToSellOrderIndex[_lastOrder.user] = _orderIndex;
        sellOrders[_orderIndex] = _lastOrder;

        sellOrders.length--;
        delete userToSellOrderIndex[_user];
    }

    function updateSellOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        _sellOrderShouldExist(_user);
        uint256 _index = userToSellOrderIndex[_user];
        sellOrders[_index].price = _price;
        sellOrders[_index].amount = _amount;
    }

    function () external payable onlyFarmer {}

    function createBuyOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        _orderShouldNotExist(userToBuyOrderIndex[_user]);

        Order memory _order = Order(_user, _price, _amount);
        userToBuyOrderIndex[_user] = buyOrders.length;
        buyOrders.push(_order);
    }

    function cancelBuyOrder(address _user) external onlyFarmer {
        _buyOrderShouldExist(_user);
        _ordersShouldExist(buyOrders.length);

        uint256 _orderIndex = userToBuyOrderIndex[_user];

        uint256 _lastOrderIndex = buyOrders.length.sub(1);
        Order memory _lastOrder = buyOrders[_lastOrderIndex];

        userToBuyOrderIndex[_lastOrder.user] = _orderIndex;
        buyOrders[_orderIndex] = _lastOrder;

        buyOrders.length--;
        delete userToBuyOrderIndex[_user];
    }

    function updateBuyOrder(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyFarmer {
        _buyOrderShouldExist(_user);
        uint256 _index = userToBuyOrderIndex[_user];
        buyOrders[_index].price = _price;
        buyOrders[_index].amount = _amount;
    }

    function orderOfSeller(
        address _user
    ) external view returns (
        uint256 index,
        address user,
        uint256 price,
        uint256 amount
    ) {
        _sellOrderShouldExist(_user);
        index = userToSellOrderIndex[_user];
        Order memory order = sellOrders[index];
        return (
            index,
            order.user,
            order.price,
            order.amount
        );
    }

    function orderOfBuyer(
        address _user
    ) external view returns (
        uint256 index,
        address user,
        uint256 price,
        uint256 amount
    ) {
        _buyOrderShouldExist(_user);
        index = userToBuyOrderIndex[_user];
        Order memory order = buyOrders[index];
        return (
            index,
            order.user,
            order.price,
            order.amount
        );
    }

    function sellOrdersAmount() external view returns (uint256) {
        return sellOrders.length;
    }

    function buyOrdersAmount() external view returns (uint256) {
        return buyOrders.length;
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        beanStalks = Bean(_newDependencies[0]);
    }
}
