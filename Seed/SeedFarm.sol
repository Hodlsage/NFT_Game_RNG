pragma solidity 0.4.25;

import "../Common/Upgradable.sol";
import "./SeedSilo.sol";

contract SeedFarm is Upgradable {
    SeedSilo _silo_;

    function getAmount() external view returns (uint256) {
        return _silo_.totalSupply();
    }

    function getAllSeeds() external view returns (uint256[]) {
        return _silo_.getAllTokens();
    }

    function isOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return _user == _silo_.ownerOf(_tokenId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _silo_.ownerOf(_tokenId);
    }

    function create(
        address _sender,
        uint256[2] _donors,
        uint8 _tomatoType
    ) external onlyFarmer returns (uint256) {
        return _silo_.push(_sender, _donors, _tomatoType);
    }

    function remove(address _owner, uint256 _id) external onlyFarmer {
        _silo_.remove(_owner, _id);
    }

    function get(uint256 _id) external view returns (uint256[2], uint8) {
        require(_silo_.exists(_id), "seed doesn't exist");
        return _silo_.get(_id);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        _silo_ = SeedSilo(_newDependencies[0]);
    }
}
