const { inputToConfig } = require("@ethereum-waffle/compiler")
const { assert } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

describe("EventLog", async function () {
    let eventLog, deployer
    beforeEach(async function () {
        //deploy contract using hardhat-deploy
        deployer = (await getNamedAccounts()).deployer //get named accounts from that section in hardhat-config
        //const accounts = await ethers.getSigners() //will return whatever is in the accounts section in network of hardhat-config
        await deployments.fixture(["all"]) //fixtures allows to deploy any deploy file with set tags
        eventLog = await ethers.getContract("EventLog", deployer) //get most recently deployed contract
    })

    describe("constructor", async function () {
        it("sets the number of events correctly", async function () {
            const numberOfEvents = await eventLog.getNumberOfEvents()
            assert.equal(numberOfEvents, 0)
        })
    })
})
