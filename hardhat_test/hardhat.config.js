require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("@nomiclabs/hardhat-etherscan")
require("dotenv").config()
require("solidity-coverage")
require("hardhat-deploy")
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
require("@nomiclabs/hardhat-web3")
=======
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
=======
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
=======
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
=======
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
=======
>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const GOERLI_RPC_URL =
    process.env.GOERLI_RPC_URL || "https://eth-goerli.alchemyapi.io/v2/your-api-key"
const PRIVATE_KEY = process.env.OWNER_PK || ""
const TEST_ACC_PK = process.env.TEST_ACCOUNT_PK || ""
// const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ""

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
            // gasPrice: 130000000000,
        },
        goerli: {
            url: GOERLI_RPC_URL,
            accounts: [PRIVATE_KEY, TEST_ACC_PK],
            chainId: 5,
            blockConfirmations: 6,
        },
        // mainnet: {
        //     url: process.env.MAINNET_RPC_URL,
        //     accounts: [PRIVATE_KEY],
        //     chainId: 1,
        //     blockConfirmations: 6,
        // },
    },
    solidity: {
        compilers: [
            {
                version: "0.8.8",
            },
            {
                version: "0.6.6",
            },
        ],
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
    gasReporter: {
        enabled: true,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true,
        // coinmarketcap: COINMARKETCAP_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0, // here this will by default take the first account as deployer
            1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
        },
        testAcc1: {
            default: 2,
            1: 2
        }
    },
    mocha: {
        timeout: 200000, // 200 seconds max for running tests
    },
}