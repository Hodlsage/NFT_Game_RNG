pragma solidity 0.4.25;


import "../Clash.sol";

contract ClashMock is Clash {

    function calculateTomatoTypeMultiply(uint8[11] _attackerTypesArray, uint8[11] _defenderTypesArray) public pure returns (uint32) {
        return _calculateTomatoTypeMultiply(_attackerTypesArray, _defenderTypesArray);
    }

    function initTomato(
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics,
        bool _isCrop
    ) public view returns ( uint32 attack, uint32 defense, uint32 health, uint32 speed, uint32 radiation) {
        Tomato memory tomato;
        tomato = _initTomato(_id, _opponentId, _tactics, _isCrop);
        attack = tomato.attack;
        defense = tomato.defense;
        health = tomato.health;
        speed = tomato.speed;
        radiation = tomato.radiation;
    }

    function initFarmhouseTomato(
        uint256 _id,
        uint256 _opponentId,
        uint8 _meleeChance,
        uint8 _attackChance,
        bool _isCrop
    ) public view returns (uint32 attack) {
        Tomato memory tomato;
        tomato = _initFarmhouseTomato(_id, _opponentId, _meleeChance, _attackChance, _isCrop);
        attack = tomato.attack;
    }
}
