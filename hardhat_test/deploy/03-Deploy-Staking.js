const {network, ethers} = require("hardhat");
const { verify } = require("../utils/verify");
const { developmentChains } = require("../helper-hardhat-config")

module.exports = async({getNamedAccounts, deployments}) => {
    const {deploy, log} = deployments
    const {deployer} = await getNamedAccounts()
    const chainId = network.config.chainId 
    const NFT = await ethers.getContract("OptimuhsSingle", deployer)
    const Token = await ethers.getContract("RewardToken", deployer)
    // console.log(Token, NFT, "deploy")


    console.log(`Deploying staking contract on ${network.name}.`)
    const stakingDep = await deploy("TokenStaking", {
        from: deployer,
        args: [ NFT.address, Token.address], // NFT Contract address, Rewards token address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
        log("----------------------------------------------")
        await verify(stakingDep.address, [NFT.address, Token.address])
    }
}
module.exports.tags = ['deploy-staking']