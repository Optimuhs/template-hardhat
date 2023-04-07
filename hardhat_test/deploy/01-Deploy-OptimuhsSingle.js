const {network, ethers} = require("hardhat");
const { verify } = require("../utils/verify");
const { developmentChains } = require("../helper-hardhat-config")

module.exports = async({getNamedAccounts, deployments}) => {
    const {deploy, log} = deployments
    const {deployer} = await getNamedAccounts()
    const chainId = network.config.chainId 
    
    console.log(`Deploying optimuhs single mint contract on ${network.name}.`)
    const optimuhsDep = await deploy("OptimuhsSingle", {
        from: deployer,
<<<<<<< HEAD
        args: [ethers.utils.parseEther("0.001"), 3, 10000], // mint price, amount per, total supply
=======
        args: [ethers.utils.parseEther("0.001"), 10, 10000], // mint price, amount per, total supply
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){
        log("----------------------------------------------")
        await verify(optimuhsDep.address, [ 0, 3, 10000])
    }
}
module.exports.tags = ['deploy']