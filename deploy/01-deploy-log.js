const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network, ethers } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log, get } = deployments
    const { deployer } = await getNamedAccounts()

    const eventLog = await deploy("EventLog", {
        contract: "contracts/EventLog.sol:EventLog",
        from: deployer,
        //args: [],
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

module.exports.tags = ["all", "eventLog"]
//"yarn hardhat deploy --tags eventLog"
