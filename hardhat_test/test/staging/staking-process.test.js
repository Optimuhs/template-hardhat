
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

  

    it("Mints, stakes, and unstakes a user's token and transfers the user their rewards", async function(){
      await connectNFTAcc.mintNFT({ value: ethers.utils.parseEther("0.0012") });
      await connectNFTAcc.mintNFT({ value: ethers.utils.parseEther("0.0012") });
      const owner = await NFT.ownerOf(1);
      await expect(owner).to.equal(testAcc1.address);

      // Approve tokens for staking and check they are approved
      await connectNFTAcc.setApprovalForAll(Staking.address, true);
      await connectNFTAcc.approve(Staking.address, 1);
      const isApproved = await NFT.isApprovedForAll(testAcc1.address, Staking.address);
    
      // Stake token and check if the 2 tokens are staked (1st yes, 2nd no)
      await connectStakingAcc.stakeToken(1);
      const isStaked = await connectStakingAcc.checkTokenIsStaked(testAcc1.address, 1)
      const isNotStaked = await connectStakingAcc.checkTokenIsStaked(testAcc1.address, 2);
      await expect(isStaked).to.equal(true);
      await expect(isNotStaked).to.equal(false);

      // Authorize staking contract to mint and distribute
      await Token.connect(deployer).setAuthorized(Staking.address);

      // Wait for 4 seconds, 1 second is accounted for when starting the staking of tokens
      await new Promise( resolve =>  setTimeout(resolve, 4000));
      // Unstake the token and distribute rewards
      await connectStakingAcc.unstakeToken(testAcc1.address, 1);
      const checkStaked = await connectStakingAcc.checkTokenIsStaked(testAcc1.address, 1);
      await expect(checkStaked).to.equal(false) 

      const balance = await Token.balanceOf(testAcc1.address)
      const n = Number(balance)
      await expect(n).to.equal(5);
    })

  });
});
