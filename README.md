## Template-hardhat
This is a set of contracts and tests that will interact together for a minting and staking experience that rewards users with a token based on how long they stake their nft's for. This repository goes in hand with [react-dapp-template](https://github.com/Optimuhs/react-dapp-template). The two respositories can be used together for creating and testing minting and staking of ERC721 and ERC20 tokens. 

## Installation

1. Clone the repo

2. Install the dependencies using your prefered package manager
` npm / yarn install `

3. Run the tests on a network of your choice
` npm / yarn hardhat test --network <network>`

4. Deploy the contracts to the network of your choice.
` npm / yarn hardhat deploy --network <network>`

##### These contracts may need changes depending on use and network deployment, especially to the hardhat configuation files and deployment scripts. Similarly the tests may need modification based on your contract's features and function signatures. 
