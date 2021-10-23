pragma solidity 0.4.25;

import "../FarmFarmer.sol";

contract FarmFarmerV2 is FarmFarmer {
    uint256 public additionalVariable;

    function additionalFunctionality(uint _add) public {
        additionalVariable += _add;
    }
}
