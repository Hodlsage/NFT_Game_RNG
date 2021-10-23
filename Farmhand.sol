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

import "./Common/Upgradable.sol";
import "./Farm.sol";
import "./Tomato/TomatoSpecs.sol";
import "./Tomato/TomatoFarmhand.sol";
import "./Harvest.sol";
import "./Market/CloningMarket.sol";
import "./Market/SeedMarket.sol";
import "./Market/TomatoMarket.sol";
import "./Market/AbilityMarket.sol";
import "./Field.sol";
import "./CropClash/Participants/CropClash.sol";
import "./CropClash/Participants/CropClashSilo.sol";

// ----------------------------------------------------------------------------
// --- Contract Farmhand 
// ----------------------------------------------------------------------------

contract Farmhand is Upgradable {

    Farm farm;
    TomatoSpecs tomatoSpecs;
    TomatoFarmhand tomatoFarmhand;
    AbilityMarket abilityMarket;
    Harvest harvest;
    Field field;
    CropClash cropClash;
    CropClashSilo cropClashSilo;

    CloningMarket public cloningMarket;
    SeedMarket public seedMarket;
    TomatoMarket public tomatoMarket;

    function _isValidAddress(address _addr) internal pure returns (bool) {
        return _addr != address(0);
    }

    function getSeed(uint256 _id) external view returns (
      uint16 gen, uint32 rarity, uint256[2] donors, uint8[11] a_donorTomatoTypes, uint8[11] b_donorTomatoTypes
    ) {
        return farm.getSeed(_id);
    }

    function getTomatoGenome(uint256 _id) external view returns (uint8[30]) {
        return tomatoFarmhand.getGenome(_id);
    }

    function getTomatoTypes(uint256 _id) external view returns (uint8[11]) {
        return tomatoFarmhand.getTomatoTypes(_id);
    }

    function getTomatoProfile(uint256 _id) external view returns (
        bytes32 name, uint16 generation, uint256 birth, uint8 level, uint8 experience, uint16 dnaPoints, bool isCloningAllowed, uint32 rarity
    ) {
        return tomatoFarmhand.getProfile(_id);
    }

    function getTomatoTactics(uint256 _id) external view returns (uint8 melee, uint8 attack) {
        return tomatoFarmhand.getTactics(_id);
    }

    function getTomatoClashs(uint256 _id) external view returns (uint16 wins, uint16 defeats) {
        return tomatoFarmhand.getClashs(_id);
    }

    function getTomatoAbilitys(uint256 _id) external view returns (
      uint32 attack, uint32 defense, uint32 stamina, uint32 speed, uint32 intelligence
    ) {
        return tomatoFarmhand.getAbilitys(_id);
    }

    function getTomatoStrength(uint256 _id) external view returns (uint32) {
        return tomatoFarmhand.getTomatoStrength(_id);
    }

    function getTomatoCurrentHealthAndRadiation(uint256 _id) external view returns (
      uint32 health, uint32 radiation, uint8 healthPercentage, uint8 radiationPercentage
    ) {
        return tomatoFarmhand.getCurrentHealthAndRadiation(_id);
    }

    function getTomatoMaxHealthAndRadiation(uint256 _id) external view returns (uint32 maxHealth, uint32 maxRadiation) {
        ( , , , maxHealth, maxRadiation) = tomatoFarmhand.getHealthAndRadiation(_id);
    }

    function getTomatoHealthAndRadiation(uint256 _id) external view returns (
        uint256 timestamp, uint32 remainingHealth, uint32 remainingRadiation, uint32 maxHealth, uint32 maxRadiation
    ) {
        return tomatoFarmhand.getHealthAndRadiation(_id);
    }

    function getTomatoDonors(uint256 _id) external view returns (uint256[2]) {
        return tomatoFarmhand.getDonors(_id);
    }

    function getTomatoSpecialAttack(uint256 _id) external view returns (
      uint8 tomatoType, uint32 cost, uint8 factor, uint8 chance
    ) {
        return tomatoFarmhand.getSpecialAttack(_id);
    }

    function getTomatoSpecialDefense(uint256 _id) external view returns (
      uint8 tomatoType, uint32 cost, uint8 factor, uint8 chance
    ) {
        return tomatoFarmhand.getSpecialDefense(_id);
    }

    function getTomatoSpecialPeacefulAbility(uint256 _id) external view returns (
      uint8 class, uint32 cost, uint32 effect
    ) {
        return tomatoFarmhand.getSpecialPeacefulAbility(_id);
    }

    function getTomatosAmount() external view returns (uint256) {
        return tomatoFarmhand.getAmount();
    }

    function getTomatoChildren(uint256 _id) external view returns (uint256[10] tomatos, uint256[10] seeds) {
        return farm.getTomatoChildren(_id);
    }

    function getTomatoBuffs(uint256 _id) external view returns (uint32[5]) {
        return tomatoFarmhand.getBuffs(_id);
    }

    function isTomatoCloningAllowed(uint256 _id) external view returns (bool) {
        return tomatoFarmhand.isCloningAllowed(_id);
    }

    function isTomatoUsed(uint256 _id) external view returns (
        bool isOnSale,
        bool isOnCloning,
        bool isInCropClash
    ) {
        return (
            isTomatoOnSale(_id),
            isCloningOnSale(_id),
            isTomatoInCropClash(_id)
        );
    }

    function getTomatoExperienceToNextLevel() external view returns (uint8[10]) {
        return tomatoSpecs.getExperienceToNextLevel();
    }

    function getTomatoGeneUpgradeDNAPoints() external view returns (uint8[99]) {
        return tomatoSpecs.getGeneUpgradeDNAPoints();
    }

    function getTomatoLevelUpDNAPoints() external view returns (uint16[11]) {
        return tomatoSpecs.getDNAPoints();
    }

    function getTomatoTypesFactors() external view returns (uint8[55]) {
        return tomatoSpecs.getTomatoTypesFactors();
    }

    function getTomatoBodyPartsFactors() external view returns (uint8[50]) {
        return tomatoSpecs.getBodyPartsFactors();
    }

    function getTomatoGeneTypesFactors() external view returns (uint8[50]) {
        return tomatoSpecs.getGeneTypesFactors();
    }

    function getSproutingPrice() external view returns (uint256) {
        return field.sproutingPrice();
    }

    function getTomatoNamePrices() external view returns (uint8[3] lengths, uint256[3] prices) {
        return tomatoFarmhand.getTomatoNamePrices();
    }

    function getTomatoNamePriceByLength(uint256 _length) external view returns (uint256 price) {
        return tomatoFarmhand.getTomatoNamePriceByLength(_length);
    }

     

    function getTomatoOnSaleInfo(uint256 _id) public view returns (
        address seller,
        uint256 currentPrice,
        uint256 startPrice,
        uint256 endPrice,
        uint16 period,
        uint256 created,
        bool isBean
    ) {
        return tomatoMarket.getAuction(_id);
    }

    function getCloningOnSaleInfo(uint256 _id) public view returns (
        address seller,
        uint256 currentPrice,
        uint256 startPrice,
        uint256 endPrice,
        uint16 period,
        uint256 created,
        bool isBean
    ) {
        return cloningMarket.getAuction(_id);
    }

    function getSeedOnSaleInfo(uint256 _id) public view returns (
        address seller,
        uint256 currentPrice,
        uint256 startPrice,
        uint256 endPrice,
        uint16 period,
        uint256 created,
        bool isBean
    ) {
        return seedMarket.getAuction(_id);
    }

    function getAbilityOnSaleInfo(uint256 _id) public view returns (address seller, uint256 price) {
        seller = ownerOfTomato(_id);
        price = abilityMarket.getAuction(_id);
    }

    function isSeedOnSale(uint256 _tokenId) external view returns (bool) {
        (address _seller, , , , , , ) = getSeedOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function isTomatoOnSale(uint256 _tokenId) public view returns (bool) {
        (address _seller, , , , , , ) = getTomatoOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function isCloningOnSale(uint256 _tokenId) public view returns (bool) {
        (address _seller, , , , , , ) = getCloningOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function isAbilityOnSale(uint256 _tokenId) external view returns (bool) {
        (address _seller, ) = getAbilityOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function getAbilitysOnSale() public view returns (uint256[]) {
        return abilityMarket.getAllTokens();
    }

    function isTomatoOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return tomatoFarmhand.isOwner(_user, _tokenId);
    }

    function ownerOfTomato(uint256 _tokenId) public view returns (address) {
        return tomatoFarmhand.ownerOf(_tokenId);
    }

    function isSeedInSoil(uint256 _id) external view returns (bool) {
        return farm.isSeedInSoil(_id);
    }

    function getSeedsInSoil() external view returns (uint256[2]) {
        return farm.getSeedsInSoil();
    }

    function getTomatosFromRanking() external view returns (uint256[10]) {
        return farm.getTomatosFromRanking();
    }

    function getRankingRewards() external view returns (uint256[10]) {
        return farm.getRankingRewards(field.remainingBean());
    }

    function getRankingRewardDate() external view returns (uint256 lastRewardDate, uint256 rewardPeriod) {
        return farm.getRankingRewardDate();
    }

    function getHarvestInfo() external view returns (
        uint256 restAmount,
        uint256 releasedAmount,
        uint256 lastBlock,
        uint256 intervalInBlocks,
        uint256 numberOfTypes
    ) {
        return harvest.getInfo();
    }

    function cropClashsAmount() external view returns (uint256) {
        return cropClashSilo.challengesAmount();
    }

    function getUserCropClashs(address _user) external view returns (uint256[]) {
        return cropClashSilo.getUserChallenges(_user);
    }

    function getCropClashApplicants(uint256 _challengeId) external view returns (uint256[]) {
        return cropClashSilo.getChallengeApplicants(_challengeId);
    }

    function getTomatoApplicationForCropClash(
        uint256 _tomatoId
    ) external view returns (
        uint256 cropClashId,
        uint8[2] tactics,
        address owner
    ) {
        return cropClashSilo.getTomatoApplication(_tomatoId);
    }

    function getUserApplicationsForCropClashs(address _user) external view returns (uint256[]) {
        return cropClashSilo.getUserApplications(_user);
    }

    function getCropClashDetails(
        uint256 _challengeId
    ) external view returns (
        bool isBean, uint256 bet, uint16 counter,
        uint256 blockNumber, bool active,
        uint256 autoSelectBlock, bool cancelled,
        uint256 compensation, uint256 extensionTimePrice,
        uint256 clashId
    ) {
        return cropClashSilo.getChallengeDetails(_challengeId);
    }

    function getCropClashParticipants(
        uint256 _challengeId
    ) external view returns (
        address firstUser, uint256 firstTomatoId,
        address secondUser, uint256 secondTomatoId,
        address winnerUser, uint256 winnerTomatoId
    ) {
        return cropClashSilo.getChallengeParticipants(_challengeId);
    }

    function isTomatoInCropClash(uint256 _clashId) public view returns (bool) {
        return cropClash.isTomatoChallenging(_clashId);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);
        farm = Farm(_newDependencies[0]);
        tomatoSpecs = TomatoSpecs(_newDependencies[1]);
        tomatoFarmhand = TomatoFarmhand(_newDependencies[2]);
        tomatoMarket = TomatoMarket(_newDependencies[3]);
        cloningMarket = CloningMarket(_newDependencies[4]);
        seedMarket = SeedMarket(_newDependencies[5]);
        abilityMarket = AbilityMarket(_newDependencies[6]);
        harvest = Harvest(_newDependencies[7]);
        field = Field(_newDependencies[8]);
        cropClash = CropClash(_newDependencies[9]);
        cropClashSilo = CropClashSilo(_newDependencies[10]);
    }
}
