pragma solidity 0.4.25;

import "../Common/ERC721/ERC721Token.sol";

contract SeedSilo is ERC721Token {
    struct Seed {
        uint256[2] donors;
        uint8 tomatoType; // used for genesis only
    }

    Seed[] seeds;

    constructor(string _name, string _symbol) public ERC721Token(_name, _symbol) {
        seeds.length = 1; // to avoid some issues with 0
    }

    function push(address _sender, uint256[2] _donors, uint8 _tomatoType) public onlyFarmer returns (uint256 id) {
        Seed memory _seed = Seed(_donors, _tomatoType);
        id = seeds.push(_seed).sub(1);
        _mint(_sender, id);
    }

    function get(uint256 _id) external view returns (uint256[2], uint8) {
        return (seeds[_id].donors, seeds[_id].tomatoType);
    }

    function remove(address _owner, uint256 _id) external onlyFarmer {
        delete seeds[_id];
        _burn(_owner, _id);
    }
}
