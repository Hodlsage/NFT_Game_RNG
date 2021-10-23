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

import "./ERC20.sol";
import "../Common/Upgradable.sol";

// ----------------------------------------------------------------------------
// --- Contract Bean 
// ----------------------------------------------------------------------------

contract Bean is ERC20, Upgradable {
    uint256 constant DEVS_STAKE = 6;

    address[3] founders = [
        0x,
        0x,
        0x
    ];

    address foundation = 0x;
    address Blockhaus = 0x;

    string constant WP_IPFS_HASH = "QmfR75tK12q2LpkU5dzYqykUUpYswSiewpCbDuwYhRb6M5";


    constructor(address field) public {
        name = "Tomatoereum Bean";
        symbol = "BEAN";
        decimals = 18;

        uint256 _foundersBean = 6000000 * 10**18; 
        uint256 _foundationBean = 6000000 * 10**18; 
        uint256 _BlockhausBean = 3000000 * 10**18; 
        uint256 _gameAccountBean = 45000000 * 10**18;

        uint256 _founderStake = _foundersBean.div(founders.length);
        for (uint256 i = 0; i < founders.length; i++) {
            _mint(founders[i], _founderStake);
        }

        _mint(foundation, _foundationBean);
        _mint(Blockhaus, _BlockhausBean);
        _mint(field, _gameAccountBean);

        require(_totalSupply == 60000000 * 10**18, "wrong total supply");
    }

    function remoteTransfer(address _to, uint256 _value) external onlyFarmer {
        _transfer(tx.origin, _to, _value); 
    }

    function burn(uint256 _value) external onlyFarmer {
        _burn(msg.sender, _value);
    }
}
