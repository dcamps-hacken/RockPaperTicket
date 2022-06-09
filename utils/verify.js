const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
    // constructor arguments must be specified in args
    console.log("Verifying contract...")
    try {
        //we use try-cath bc sometimes it says the contract is already verified
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!")
        } else {
            console.log(e)
        }
    }
}

module.exports = { verify }
