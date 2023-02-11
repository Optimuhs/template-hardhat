
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect, assert } = require("chai");
const {deployments, ethers, getNamedAccounts} = require("hardhat")


describe("Optimuhs", async function () {
  let optimuhs;
  let deployer;
  let testAcc;
  
  // We load a fixture to reuse the same setup in every test.
  beforeEach(async function() {
    deployer = (await getNamedAccounts()).deployer
    await deployments.fixture(["deploy"])
    optimuhs = await ethers.getContract("OptimuhsSingle", deployer)
    const contractBalance =  await optimuhs.currentBalance()
  })
  

  describe("Sale config", async function () {
    it("Checks contract sale configuration", async function () {
      const response = await optimuhs.salesConfig()
      const responseVal = {
        "price": response["mintPrice"].toNumber(), 
        "amountPer": response["amountPerWallet"].toNumber(),
        "totalSupply": response["totalSupply"].toNumber()
      }
      const expectedVal = {
        "price":ethers.utils.parseEther("0.001"), 
        "amountPer": 3,
        "totalSupply": 10000,
      }
      expect(
        responseVal.price === expectedVal.price.toNumber() && 
        responseVal.amountPer === expectedVal.amountPer &&
        responseVal.totalSupply === expectedVal.totalSupply).to.be.true
    })
  })

  describe("minting", async function(){
    it("Reverts minting, too little ether", async function(){
      await expect(optimuhs.mintNFT()).to.be.revertedWith("Not enough ETH")
    })
    it("Prevents users from minting over limit", async function(){
      for(let i = 0 ; i < 2; i++){
        await optimuhs.mintNFT({value: ethers.utils.parseEther("0.0012")})
      }
      await expect(optimuhs.mintNFT({value: ethers.utils.parseEther("0.0012")})).to.be.revertedWith("Max mint limit per wallet reached")
      
    })
    it("returns a user the amount of ether left over minus gas", async function(){
      // Cache balance for contract and user wallet
      const preContractBal =  await optimuhs.currentBalance()
      const preMintBal = await ethers.provider.getBalance(deployer)

      // Mint token
      let mintTxn = await optimuhs.mintNFT({value: ethers.utils.parseEther("0.003")})

      const postMintBal = await ethers.provider.getBalance(deployer)    
      const postContractBal = await optimuhs.currentBalance()
      // Wallet balance difference
      const difference = preMintBal - postMintBal
      expect(
        String(postContractBal) === String(ethers.utils.parseEther("0.001")) && 
        String(difference) <= String(ethers.utils.parseEther("0.003") - ethers.utils.parseEther("0.001"))).to.be.true
    })
    it("mints a token with an id based on the current count of tokens minted", async function(){
      const startingCount = await optimuhs.currentCount()
      let mintTxn = await optimuhs.mintNFT({value: ethers.utils.parseEther("0.0015")})
      const currentCount = await optimuhs.currentCount()
      expect(startingCount + 1, currentCount).to.be.equal
    })

   
  })

  describe("Security and functional components", async function() {
    
    beforeEach(async function() {
      await optimuhs.mintNFT({value:ethers.utils.parseEther("0.0015")})
    })

    it("withdraws contract balance to the owner wallet", async function() {
      // Arrange
      const startContractBal = await optimuhs.provider.getBalance(optimuhs.address)
      const startOwnerBal = await optimuhs.provider.getBalance(deployer)
      // Act
      const txnResponse = await optimuhs.withdraw()
      const txnRecipt =  await txnResponse.wait(1)
      const {gasUsed, effectiveGasPrice } = txnRecipt
      const gasCost = gasUsed.mul(effectiveGasPrice)
      const postContractBal = await optimuhs.provider.getBalance(optimuhs.address)
      const postOwnerBal = await optimuhs.provider.getBalance(deployer)
      // Assert
      assert.equal(postContractBal, 0)
      assert.equal(startContractBal.add(startOwnerBal).toString(), postOwnerBal.add(gasCost).toString())
    })

  })

});

 