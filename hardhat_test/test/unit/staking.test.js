const { expect } = require("chai");
const { deployments, ethers, getNamedAccounts } = require("hardhat");

describe("Staking Test", function () {
  let deployer, testAcc1, NFT, Token, Staking;
  
  before(async function () {
    [deployer, testAcc1, ...accs] = await ethers.getSigners();
    await deployments.fixture(["deploy", "deploy-rewards-token", "deploy-staking"]);
    NFT = await ethers.getContract("OptimuhsSingle", deployer);
    Token = await ethers.getContract("RewardToken", deployer);
    Staking = await ethers.getContract("TokenStaking", deployer);
  });

  beforeEach(async function () {
    connectNFTAcc = await NFT.connect(testAcc1);
    connectStakingAcc = await Staking.connect(testAcc1);
    connectRWTAcc = await Token.connect(testAcc1);
  });
    
  describe("Staking", function () {
    it("Mints a token to stake", async function () {
      await connectNFTAcc.mintNFT({ value: ethers.utils.parseEther("0.0012") });
      await expect(await NFT.ownerOf(0)).to.equal(testAcc1.address);
    });
  });
});
