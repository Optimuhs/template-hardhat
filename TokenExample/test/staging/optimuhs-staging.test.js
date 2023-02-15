const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect, assert } = require("chai");
const {deployments, ethers, network, getNamedAccounts} = require("hardhat")
const {developmentChains} = require("../../helper-hardhat-config")

developmentChains.includes(network.name) ? describe.skip :   
    describe("Optimuhs", async function () {
        // We load a fixture to reuse the same setup in every test.
        beforeEach(async function() {
            deployer = (await getNamedAccounts()).deployer
            testAcc1 = (await getNamedAccounts()).testAcc1
            await deployments.fixture(["deploy"])
            optimuhs = await ethers.getContract("OptimuhsSingle", deployer)
        }) 

        it("Prevent non-owners from withdrawing", async function(){
            const connectTestAcc = await optimuhs.connect(testAcc1) 
            await expect(connectTestAcc.withdraw({from: testAcc1.address})).to.be.revertedWith("Ownable: caller is not the owner")
        })
        
    
    })