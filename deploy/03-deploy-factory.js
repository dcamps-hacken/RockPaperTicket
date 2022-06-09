const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network, ethers } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log, get } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const eventLog = await ethers.getContract("EventLog")
    const vrf = await ethers.getContract("VRF")

    const eventFactory = await deploy("EventFactory", {
        from: deployer,
        args: [eventLog.address, vrf.address],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1, // if no block confirmations, wait 1 block
    })
    log("-------------------------------")

    // VERIFY CONTRACT
    //if (
    //    !developmentChains.includes(network.name) &&
    //    process.env.ETHERSCAN_API_KEY
    //) {
    //    await verify(eventLog.address)
    //}
}
module.exports.tags = ["all", "eventFactory"]
//"yarn hardhat deploy --tags eventFactory"
