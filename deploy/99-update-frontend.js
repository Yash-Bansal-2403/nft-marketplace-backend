const { ethers, network } = require("hardhat");
const fs = require('fs');

const FRONTEND_ADDRESS_FILE = "../lottery decentralised frontend/client/src/constants/contractAddresses.json"
const FRONTEND_ABI_FILE = "../lottery decentralised frontend/client/src/constants/abi.json"

async function updateAbi() {
    const lottery = await ethers.getContract('Lottery')
    fs.writeFileSync(FRONTEND_ABI_FILE, lottery.interface.format(ethers.utils.FormatTypes.json))

}

async function updateContractAddresses() {
    const lottery = await ethers.getContract('Lottery')
    console.log('hello')
    console.log(lottery.address)
    const chainId = network.config.chainId.toString()
    const currentAddresses = JSON.parse(fs.readFileSync(FRONTEND_ADDRESS_FILE, "utf8"))
    if (chainId in currentAddresses) {
        if (!currentAddresses[chainId].includes(lottery.address)) {
            currentAddresses[chainId].push(lottery.address)
        }
    } {
        currentAddresses[chainId] = [lottery.address]
    }
    fs.writeFileSync(FRONTEND_ADDRESS_FILE, JSON.stringify(currentAddresses))
}
module.exports = async function () {
    console.log('updating frontend...........')
    updateContractAddresses()
    updateAbi()
}
module.exports.tags = ['all', 'frontend']