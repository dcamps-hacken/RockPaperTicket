# Advanced Sample Hardhat Project

This project demonstrates an advanced Hardhat use case, integrating other tools commonly used alongside Hardhat in the ecosystem.

The project comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts. It also comes with a variety of other tools, preconfigured to work with the project code.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```

yarn init
yarn add --dev hardhat
yarn hardhat
advanced sample project + install all dependencies

yarn add --dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @nomiclabs/hardhat-etherscan @nomiclabs/hardhat-waffle chai ethereum-waffle hardhat hardhat-contract-sizer hardhat-deploy hardhat-gas-reporter prettier prettier-plugin-solidity solhint solidity-coverage dotenv


First steps:
eslint (js linting)
solhing (solidity linting) --> yarn solhint <files> --> yarn solhint contracts/*.sol
prettierrc (code formatting) --> add content
prettierignore --> add content
.env --> add content


yarn add @chainlink/contracts


Add hardhat-deploy
yarn add hardhat-deploy
require("hardhat-deploy")

yarn hardhat --> deploy task appears

create deploy folder
add hardhat-deploy ethers: yarn add --save-dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers --> 
allows to keep track and remember all deployments


to use getNamedAccounts() we need to add to hardhat config:
namedAccounts: {
      deployer: {
        default: 0, //takes account #0
      },
      user: { //we can create a user
        default: 1 //takes account #1
      }
    }


create helper-hardhat-config.js file to define network config