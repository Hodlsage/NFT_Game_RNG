pragma solidity 0.4.25;

import "../CropClash/Participants/CropClash.sol";

contract CropClashMock is CropClash {

    function setAUTO_SELECT_TIME(uint _c) public {
        AUTO_SELECT_TIME = _c;
    }
}
