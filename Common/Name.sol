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

import "../Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract Name 
// ----------------------------------------------------------------------------

contract Name {
    using SafeMath256 for uint256;

    uint8 constant MIN_NAME_LENGTH = 2;
    uint8 constant MAX_NAME_LENGTH = 32;

    function _convertName(string _input) internal pure returns(bytes32 _initial, bytes32 _lowercase) {
        bytes memory _initialBytes = bytes(_input);
        assembly {
            _initial := mload(add(_initialBytes, 32))
        }
        _lowercase = _toLowercase(_input);
    }

    function _toLowercase(string _input) internal pure returns(bytes32 result) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        require (_length <= 32 && _length >= 2, "string must be between 2 and 32 characters");
        require(_temp[0] != 0x20 && _temp[_length.sub(1)] != 0x20, "string cannot start or end with a space");
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        bool _hasNonNumber;

        for (uint256 i = 0; i < _length; i = i.add(1))
        {
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                _temp[i] = byte(uint256(_temp[i]).add(32));

                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    _temp[i] == 0x20 ||
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );

                if (_temp[i] == 0x20)
                    require(_temp[i.add(1)] != 0x20, "string cannot contain consecutive spaces");

                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        assembly {
            result := mload(add(_temp, 32))
        }
    }
}
