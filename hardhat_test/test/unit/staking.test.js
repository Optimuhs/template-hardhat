const { expect } = require("chai");
<<<<<<< HEAD
const { deployments, ethers, getNamedAccounts, hre } = require("hardhat");
require("@nomiclabs/hardhat-ethers");
=======
const { deployments, ethers, getNamedAccounts } = require("hardhat");
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2

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
<<<<<<< HEAD

    it("Prevents users from minting more than allowed", async function() {
      await connectNFTAcc.mintNFT({ value: ethers.utils.parseEther("0.0012") });
      await connectNFTAcc.mintNFT({ value: ethers.utils.parseEther("0.0012") });
      await expect(connectNFTAcc.mintNFT({ value: ethers.utils.parseEther("0.0012") })).to.be.revertedWith('Max mint limit per wallet reached')
    })

    it("Receives tokens", async function() {
      const amountToSend = ethers.utils.parseEther("1.0");   // send 1 ETH
      const startBalance = await connectNFTAcc.currentBalance()
      const txn = await testAcc1.sendTransaction({
        to: NFT.address,
        value: amountToSend
      })
      const endBalance = await connectNFTAcc.currentBalance()
      const difference = Number(endBalance) - Number(startBalance)
      await expect(difference).to.equal(Number(amountToSend))

    })

    it("Only allows owner to withdraw", async function() {
      const amountToSend = ethers.utils.parseEther("1.0");   // send 1 ETH
      const startBalance = await connectNFTAcc.currentBalance()
      const txn = await testAcc1.sendTransaction({
        to: NFT.address,
        value: amountToSend
      })
      await expect(connectNFTAcc.withdraw()).to.be.revertedWith("Ownable: caller is not the owner")
    })

    
=======
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
  });
});
