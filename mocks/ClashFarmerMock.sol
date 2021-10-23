pragma solidity 0.4.25;


import "../ClashFarmer.sol";

contract ClashFarmerMock is ClashFarmer {

    function isTouchable(uint id) public view returns (bool) {
        return _isTouchable(id);
    }

    function calculateExperience(
        bool _isAttackerWinner,
        uint32 _attackerStrength,
        uint32 _opponentStrength
    ) public pure returns (uint256) {
        return _calculateExperience(_isAttackerWinner, _attackerStrength, _opponentStrength);
    }

    function payBeanReward(address _sender, uint256 _id, uint256 _factor ) public {
        return _payBeanReward( _sender, _id, _factor);
    }

    function calculateBeanRewardFactor(uint256 _ws, uint256 _ls) public pure returns (uint256) {
        return _calculateBeanRewardFactor(_ws, _ls);
    }
}
