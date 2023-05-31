const { network, ethers } = require("hardhat");
const { verify } = require("../utils/verify");
const { developmentChains } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  console.log(`Deploying optimuhs single mint contract on ${network.name}.`);
  const optimuhsDep = await deploy("OptimuhsSingle", {
    from: deployer,
    args: [0, 5, 10000],
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log("----------------------------------------------");
    await verify(optimuhsDep.address, [0, 5, 10000]);
  }
};
module.exports.tags = ["deploy"];
