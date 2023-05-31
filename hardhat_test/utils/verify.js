const { run } = require("hardhat");
const { modules } = require("web3");

const verify = async (contractAddress, args) => {
  console.log("Beginning contract verification...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (err) {
    if (err.message.toLowerCase().includes("already verified")) {
      console.log("Already verified");
    } else {
      console.log(err);
    }
  }
};

module.exports = { verify };
