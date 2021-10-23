pragma solidity 0.4.25;


import "../Tomato/TomatoMutation.sol";

contract TomatoMutationMock is TomatoMutation {

    function getWeightedRandom(uint256 _random) public view returns (uint8) {
        return _getWeightedRandom(_random);
    }

    function generateGen(uint8 _tomatoType, uint256 _random) public view returns (uint8[16]) {
        return _generateGen(_tomatoType, _random);
    }

    function getSpecialRandom(
        uint256 _seed_,
        uint8 _digits
    ) public pure returns (uint256, uint256) {
        return _getSpecialRandom(_seed_, _digits);
    }

    function testComposed(uint256[4] _composed) public pure returns (uint256[4]){
        uint8[16][10] memory decomposed = _parseGenome(_composed);
        return _composeGenome(decomposed);
    }

    function calculateGen(
        uint8[16] _a_donorGen,
        uint8[16] _b_donorGen,
        uint8 _random
    ) external pure returns (uint8[16] gen) {
        gen = _calculateGen(_a_donorGen, _b_donorGen, _random);
    }

    function mutateGene(uint8[16] _gene, uint8 _genType) public pure returns (uint8[16]) {
        return _mutateGene(_gene, _genType);
    }

    function calculateTomatoTypes(uint256[4] _composed) public pure returns (uint8[11] tomatoTypesArray) {
        uint8[16][10] memory _genome = _parseGenome(_composed);
        return _calculateTomatoTypes(_genome);

    }
    function checkIncloning(uint256[2] _donors) external view returns (uint8 chance) {
        return _checkIncloning(_donors);
    }

}
