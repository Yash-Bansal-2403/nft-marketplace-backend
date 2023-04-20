const { network } = require("hardhat")//network will be used to extract network name using network.name
const { developmentChains, VERIFICATION_BLOCK_CONFIRMATIONS } = require("../helper-hardhat-config")//develpmentChains include localhost/hardhat network
const { verify } = require("../utils/verify")// for progrmmatic verification of deployment using hardhat-etherscan package

module.exports = async ({ getNamedAccounts, deployments }) => {
     //getNamedAccounts, deployments are extracted from hre as hre is by default passed to this async function

    //deploy- to deploy contract
    //log - to use in place of console.log()
    const { deploy, log } = deployments//deployments is an object

    //to accress deployer account defined in hardhat.config
    const { deployer } = await getNamedAccounts()//getNamedAccounts is a function
    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS

    log("----------------------------------------------------")
    const arguments = []
    const nftMarketplace = await deploy("NftMarketplace", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
//we do verification only if we are NOT on local hardhat network and ETHERSCAN_API_KEY is available
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(nftMarketplace.address, arguments)
    }
    log("----------------------------------------------------")
}

module.exports.tags = ["all", "nftmarketplace"]
