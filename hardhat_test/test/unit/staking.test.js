const { expect } = require("chai");
const { deployments, ethers } = require("hardhat");
const { expectRevert } = require("@openzeppelin/test-helpers");

describe("Staking Test", function () {
  let deployer, testAcc1, NFT, Token, Staking;

  before(async function () {
    [deployer, testAcc1, ...accs] = await ethers.getSigners();
    await deployments.fixture([
      "deploy",
      "deploy-rewards-token",
      "deploy-staking",
    ]);
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
    const TokenMetadata = {
      name: "Optimuhs' Token",
      description: "Thank you token",
      image: "ipfs/someCID",
    };
    it("Mints a token to stake", async function () {
      await NFT.connect(deployer).updateBase("https://ipfs.io/");

      await connectNFTAcc.mintNFT(TokenMetadata, {
        value: ethers.utils.parseEther("0.0012"),
      });
      await expect(await connectNFTAcc.ownerOf(0)).to.equal(testAcc1.address);
    });

    it("Prevents users from minting more than allowed", async function () {
      await NFT.connect(deployer).updateBase("https://ipfs.io/");

      const TokenMetadata = {
        name: "Optimuhs' Token",
        description: "Thank you token",
        image: "ipfs/someCID",
      };
      await connectNFTAcc.mintNFT(TokenMetadata, {
        value: ethers.utils.parseEther("0.0012"),
      });
      await connectNFTAcc.mintNFT(TokenMetadata, {
        value: ethers.utils.parseEther("0.0012"),
      });
      await expectRevert(
        connectNFTAcc.mintNFT(TokenMetadata, x{
          value: ethers.utils.parseEther("0.0012"),
        }),
        "Max mint limit per wallet reached"
      );
    });

    it("Receives tokens", async function () {
      const amountToSend = ethers.utils.parseEther("1.0"); // send 1 ETH
      const startBalance = await connectNFTAcc.currentBalance();
      const txn = await testAcc1.sendTransaction({
        to: NFT.address,
        value: amountToSend,
      });
      const endBalance = await connectNFTAcc.currentBalance();
      const difference = Number(endBalance) - Number(startBalance);
      await expect(difference).to.equal(Number(amountToSend));
    });

    it("Only allows owner to withdraw", async function () {
      const amountToSend = ethers.utils.parseEther("1.0"); // send 1 ETH
      const startBalance = await connectNFTAcc.currentBalance();
      const txn = await testAcc1.sendTransaction({
        to: NFT.address,
        value: amountToSend,
      });
      await expectRevert(
        connectNFTAcc.withdraw(),
        "Ownable: caller is not the owner"
      );
    });

    it("Only owner updates the token URI", async function () {
      const TokenMetadata = {
        name: "Optimuhs' Token",
        description: "Thank you token",
        image: "ipfs/someCID",
      };

      const TokenMetadata2 = {
        name: "Optimuhs' Token",
        description: "Thank you token",
        image: "hehehe",
      };
      // Update base, it cannot be empty for metadata updates
      await NFT.connect(deployer).updateBase("https://ipfs.io/");

      // Mint
      await NFT.connect(deployer).mintNFT(TokenMetadata, {
        value: ethers.utils.parseEther("0.0012"),
      });

      // Mint
      await NFT.connect(deployer).mintNFT(TokenMetadata, {
        value: ethers.utils.parseEther("0.0012"),
      });

      // Only owner check
      await expectRevert(
        NFT.connect(testAcc1).updateTokenMetadataExternal(1, TokenMetadata2),
        "Ownable: caller is not the owner"
      );
    });

    it("Updates the token URI", async function () {
      const TokenMetadata = {
        name: "Optimuhs' Token",
        description: "Thank you token",
        image: "ipfs/someCID",
      };

      const TokenMetadata2 = {
        name: "Optimuhs' Token",
        description: "Thank you token",
        image: "hehehe",
      };
      // Update base, it cannot be empty for metadata updates
      await NFT.connect(deployer).updateBase("https://ipfs.io/ipfs/");

      // Mint
      await NFT.connect(deployer).mintNFT(TokenMetadata, {
        value: ethers.utils.parseEther("0.0012"),
      });

      await NFT.connect(deployer).updateTokenMetadataExternal(
        0,
        TokenMetadata2
      );
      const testChange = await NFT.connect(deployer).tokenURI(0);

      expect(testChange).to.equal("https://ipfs.io/ipfs/hehehe");
    });

    it("Set staking status", async function () {
      await Staking.connect(deployer).setStaking();
      const stat = await Staking.connect(deployer).getStakingStatus();
      await expect(stat).to.equal(true);
    });
  });
});
