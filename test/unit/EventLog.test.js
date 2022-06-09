const { inputToConfig } = require("@ethereum-waffle/compiler")
const { assert, expect } = require("chai")
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
        it("sets the number of events", async function () {
            const numberOfEvents = await eventLog.getNumberOfEvents()
            assert.equal(numberOfEvents, "0")
        })
    })

    describe("function logEvent()", async function () {
        beforeEach(async function () {
            const numberOfEvents = await eventLog.getNumberOfEvents()
            const tx = await eventLog._logEvent(
                "1",
                "0x14dC79964da2C08b23698B3D3cc7Ca32193d9955",
                "severus",
                "testname",
                "100",
                "10"
            )
            await tx.wait(1)
        })
        it("logs an event into mapping and increases #events", async function () {
            const newEvent = await eventLog.getEvent("1")
            console.log(newEvent)
        })
        it("increases the number of events by 1", async function () {
            const updatedNumberOfEvents = await eventLog.getNumberOfEvents()
            assert.equal(numberOfEvents.add(1), updatedNumberOfEvents) //add is better when BN
        })
    })

    describe("updateName", async function () {
        //beforeEach(async function () {
        //    await eventLog._logEvent(
        //        "1",
        //        "0x14dC79964da2C08b23698B3D3cc7Ca32193d9955",
        //        "severus",
        //        "testname",
        //        "100",
        //        "10"
        //    )
        //})
        it("reverts if not called from eventGame", async function () {
            await expect(
                eventLog._updateName("1", "newName")
            ).to.be.revertedWith("EventLog__NotCalledFromEventGame")
            //await expect(eventLog._updateName("1", "newName").to.be.reverted)
        })
    })

    describe("_gameStart", async function () {
        it("reverts if not called from eventGame", async function () {
            await expect(eventLog._gameStart("1")).to.be.revertedWith(
                "EventLog__NotCalledFromEventGame"
            )
        })
        it("reverts if game is not in Registering status", async function () {
            await expect(eventLog._gameStart("1")).to.be.revertedWith(
                "EventLog__GameNotRegistering"
            )
        })
        it("changes the game status to Started", async function () {
            await eventLog._gameStart("1")
            const gameStatus = await eventLog.getEventStatus("1")
            assert.equal(gameStatus.toString(), "1")
        })
        it("emits GameStarted event", async function () {
            await expect(eventLog._gameStart("1")).to.emit(
                eventLog,
                "GameStarted"
            )
        })
    })
})

describe("EventGame", async function () {
    let eventGame, deployer
    beforeEach(async function () {
        deployer = (await getNamedAccounts()).deployer //get named accounts from that section in hardhat-config
        await deployments.fixture(["all"]) //fixtures allows to deploy any deploy file with set tags
        eventGame = await ethers.getContract("EventGame", deployer) //get most recently deployed contract
    })
})
