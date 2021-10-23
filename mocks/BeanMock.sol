pragma solidity 0.4.25;

import "../Bean/Bean.sol";

contract BeanMock is Bean {

    constructor (address _treasure) Bean(_treasure) public { }

    function mint(address _who, uint256 _value) public {
        _mint(_who, _value);
    }
}
