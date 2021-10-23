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

import "./Common/Ownable.sol";
import "./Common/Pausable.sol";
import "./Common/Upgradable.sol";

// ----------------------------------------------------------------------------
// --- Contract UpgradeFarmer 
// ----------------------------------------------------------------------------

contract UpgradeFarmer is Ownable {
    function migrate(address _oldAddress, address _newAddress) external onlyOwner {
        require(_oldAddress != _newAddress, "addresses are equal");
        Upgradable _oldContract = Upgradable(_oldAddress);
        Upgradable _newContract = Upgradable(_newAddress);
        Upgradable _externalDependency;
        Upgradable _internalDependency;
        address[] memory _externalDependenciesOfInternal;
        address[] memory _internalDependenciesOfExternal;
        address[] memory _externalDependencies = _oldContract.getExternalDependencies();
        address[] memory _internalDependencies = _oldContract.getInternalDependencies();
        require(
            _externalDependencies.length > 0 ||
            _internalDependencies.length > 0,
            "no dependencies"
        );
        uint256 i;
        uint256 j;

        for (i = 0; i < _externalDependencies.length; i++) {
            _externalDependency = Upgradable(_externalDependencies[i]);
            _internalDependenciesOfExternal = _externalDependency.getInternalDependencies();

            for (j = 0; j < _internalDependenciesOfExternal.length; j++) {
                if (_internalDependenciesOfExternal[j] == _oldAddress) {
                    _internalDependenciesOfExternal[j] = _newAddress;
                    break;
                }
            }

            _externalDependency.setInternalDependencies(_internalDependenciesOfExternal);
        }

        for (i = 0; i < _internalDependencies.length; i++) {
            _internalDependency = Upgradable(_internalDependencies[i]);
            _externalDependenciesOfInternal = _internalDependency.getExternalDependencies();

            for (j = 0; j < _externalDependenciesOfInternal.length; j++) {
                if (_externalDependenciesOfInternal[j] == _oldAddress) {
                    _externalDependenciesOfInternal[j] = _newAddress;
                    break;
                }
            }

            _internalDependency.setExternalDependencies(_externalDependenciesOfInternal);
        }

        _newContract.setInternalDependencies(_internalDependencies);
        _newContract.setExternalDependencies(_externalDependencies);
        returnOwnership(_oldAddress);
    }

    function returnOwnership(address _address) public onlyOwner {
        Upgradable(_address).transferOwnership(owner);
    }

    function pause(address _address) external onlyOwner {
        Pausable(_address).pause();
    }

    function unpause(address _address) external onlyOwner {
        Pausable(_address).unpause();
    }
}
