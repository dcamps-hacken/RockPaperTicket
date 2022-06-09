const { networkConfig } = require("../helper-hardhat-config")
const { network } = require("hardhat")

module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // parametrize constructor args depending on chainId --> helper-hardhat-config
    const eventLogAddress = networkConfig[chainId]["eventLog"]
    const vrfAddress = networkConfig[chainId]["vrf"]

    const eventFactory = await deploy("EventFactory", {
        from: deployer,
        args: [],
        log: true,
    })
}
