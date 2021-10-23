pragma solidity 0.4.25;


import "../Farm.sol";

contract FarmMock is Farm {
    function _openSeed(
        address _owner,
        uint256 _seedId,
        uint256 _random
    ) public returns (uint256 newTomatoId) {
        return openSeed(_owner, _seedId, _random);
    }
}
