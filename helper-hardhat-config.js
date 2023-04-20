//we import this file during testing in test dir
//here we store cutom price feed address of diffeent chains on CHAINLINK
//here we also define our development chains

const networkConfig = {
    default: {
        name: "hardhat",
        keepersUpdateInterval: "30",
    },
    31337: {
        name: "localhost",
    },
    5: {
        name: "goerli",
    },
    11155111: {
        name: "sepolia",
    },
    1: {
        name: "mainnet",
    },
    80001: {
        name: "mumbai",
    },
}

const developmentChains = ["hardhat", "localhost"]
const VERIFICATION_BLOCK_CONFIRMATIONS = 6
const frontEndContractsFile = "../nft-marketplace-frontend-moralis/constants/networkMapping.json"
const frontEndContractsFile2 = "../nft-marketplace-frontend-graph/constants/networkMapping.json"
const frontEndAbiLocation = "../nft-marketplace-frontend-moralis/constants/"
const frontEndAbiLocation2 = "../nft-marketplace-frontend-graph/constants/"

module.exports = {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
    frontEndContractsFile,
    frontEndContractsFile2,
    frontEndAbiLocation,
    frontEndAbiLocation2,
}
