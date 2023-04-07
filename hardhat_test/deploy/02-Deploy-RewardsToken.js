const {network, ethers} = require("hardhat");
const { verify } = require("../utils/verify");
const { developmentChains } = require("../helper-hardhat-config")

module.exports = async({getNamedAccounts, deployments}) => {
    const {deploy, log} = deployments
    const {deployer} = await getNamedAccounts()
    const chainId = network.config.chainId 
    
    console.log(`Deploying rewards token contract on ${network.name}.`)
    const rewardTokenDep = await deploy("RewardToken", {
        from: deployer,
        args: [], //
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
        log("----------------------------------------------")
        await verify(rewardTokenDep.address, [])
    }
}
module.exports.tags = ['deploy-rewards-token']