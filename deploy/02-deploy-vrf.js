const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network, ethers } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let vrfCoordinatorV2Address, subscriptionId, gasLane
    const FUND_AMOUNT = "10000000000000000000"

    if (developmentChains.includes(network.name)) {
        log("Local network detected! Deploying mocks...")
        const vrfCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        )
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        //Create a fake subscription to work with the coordinator
        const tx = await vrfCoordinatorV2Mock.createSubscription()
        const txReceipt = await tx.wait(1)
        subscriptionId = txReceipt.events[0].args.subId //get the subId from the event's first arg "subId"
        // Fund the fake subscription with Link
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT)
        gasLane = networkConfig[chainId]["gasLane"]
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"]
        gasLane = networkConfig[chainId]["gasLane"]
    }

    const vrf = await deploy("VRF", {
        contract: "contracts/VFR.sol:VRF",
        from: deployer,
        args: [vrfCoordinatorV2Address, gasLane],
        log: true,
    })

    log("-------------------------")

    // VERIFY CONTRACT
    //if (
    //    !developmentChains.includes(network.name) &&
    //    process.env.ETHERSCAN_API_KEY
    //) {
    //    await verify(eventLog.address)
    //}
}

module.exports.tags = ["all", "VRF"]
//"yarn hardhat deploy --tags eventLog"
