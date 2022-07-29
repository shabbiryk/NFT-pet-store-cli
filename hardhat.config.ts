import { task } from "hardhat/config"
import "@nomiclabs/hardhat-waffle"
import "@nomiclabs/hardhat-ethers"
require('dotenv').config();

let { GOERLI_API_URL, METAMASK_PRIVATE_KEY } = process.env

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(`${account.address}`);
  }
});

task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs, hre) => {
    const account = taskArgs.account;
    const provider = hre.ethers.getDefaultProvider();
    const balance = await provider.getBalance(account);
    console.log(`${balance.toNumber()} ETH`);
  });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      gas: 0,
      from: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
    },
    goerli: {
      url: GOERLI_API_URL,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`]
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.4"
      }
    ]
  }
};
