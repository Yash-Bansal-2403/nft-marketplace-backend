//this file is the heart of hardhat and is used to control it
//in this file we configure all the hardhat plugins

require("@nomiclabs/hardhat-waffle")//used to work with waffle testing framework
require("hardhat-gas-reporter")//package which tells how much gas each of our contract function consumes
require("@nomiclabs/hardhat-etherscan")//to programmatically verify our deployment
require("dotenv").config()//to use .env encrypted file
require("solidity-coverage")//package which tells how many lines of our.sol file are covered in test
require("hardhat-deploy")//to use for deployment and easy testing
require("hardhat-contract-sizer")

/** @type import('hardhat/config').HardhatUserConfig */

const GOERLI_RPC_URL =
  "https://eth-mainnet.alchemyapi.io/v2/your-api-key"//end node for goerli network from infura/alchemy/quicknode
const PRIVATE_KEY =
  "0x11ee3108a03081fe260ecdc106554d09d9d1209bcafd46942b10e02943effc4a"//private key of our metamask account
const ETHERSCAN_API_KEY = 'K1ITDA9PWNWCYWX43FJ61ET6WN33ADP2Y2' //using ybansal2403   etherscan api to programmatically verify our deployment
const COINMARKETCAP_API_KEY = "a6027d7d-91eb-429c-8570-470bf35ffe54"// bobabraham API key on coinmarket cap
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      blockConfirmations: 1,
      // gasPrice: 130000000000,
    },//this is our local network config and we do not provide accounts here as they are automatically fetched from hardhat local network
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
      blockConfirmations: 6,
    },//goerli network config
  },
  solidity: {
    compilers: [
      {
        version: "0.8.7",
      },
      {
        version: "0.6.0",//for MockV3Aggregator
      },
    ],
  },//using multiple solidity version
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },//setting up etherscan api
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    // coinmarketcap: COINMARKETCAP_API_KEY,
  },//configuring hadhat-gas-reporter package
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
      //for different chainIds we can specify what will be the default deployer account
      31337: 2//on hardhat deployer account will be 2nd account
    },
    player: {
      default: 1,
    },
  },//this property is used to name different accounts on our chainId
  mocha: {
    timeout: 500000,
  },//configuring mocha
};
