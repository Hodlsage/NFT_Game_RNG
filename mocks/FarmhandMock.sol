pragma solidity 0.4.25;


import "../Farmhand.sol";

contract FarmhandMock is Farmhand {

    uint tomatoAmount = 1;

    function getTomatosAmount() external view returns (uint256) {
        return tomatoAmount;
    }

    function setTomatosAmount(uint _a) external {
        tomatoAmount = _a;
    }

}
