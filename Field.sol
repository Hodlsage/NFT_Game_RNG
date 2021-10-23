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

import "./Bean/Bean.sol";
import "./Common/Upgradable.sol";
import "./Common/SafeMath256.sol";

// ----------------------------------------------------------------------------
// --- Contract Farmhand 
// ----------------------------------------------------------------------------

contract Field is Upgradable {
    using SafeMath256 for uint256;

    Bean beanStalks;

    uint256 constant BEAN_DECIMALS = 10 ** 18;
    uint256 constant public sproutingPrice = 1000 * BEAN_DECIMALS;

    function giveBean(address _user, uint256 _amount) external onlyFarmer {
        beanStalks.transfer(_user, _amount);
    }

    function takeBean(uint256 _amount) external onlyFarmer {
        beanStalks.remoteTransfer(this, _amount);
    }

    function burnBean(uint256 _amount) external onlyFarmer {
        beanStalks.burn(_amount);
    }

    function remainingBean() external view returns (uint256) {
        return beanStalks.balanceOf(this);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        beanStalks = Bean(_newDependencies[0]);
    }

    function migrate(address _newAddress) public onlyOwner {
        beanStalks.transfer(_newAddress, beanStalks.balanceOf(this));
    }
}
