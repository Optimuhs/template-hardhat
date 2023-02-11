const {run} = require("hardhat")
const {modules} = require("web3")

const verify = async (contractAddress, args) => {
    console.log("Beginning contract verification...")
    try{
        await run("verify:verify", {
            adress: contractAddress,
            constructorArguments: args,
        })
    }catch(err){
        if(err.message.toLowerCase().includes("already verified")){
            console.log("Already verified")
        }else{
            console.log(e)
        }
    }
}

module.exports ={ verify }
     
