import {
  Contract,
  ContractFactory,
  Signer
} from "ethers"
import { ethers } from "hardhat"

const deployToken = async(contractName: string, signer: Signer|null = null): Promise<string> => {
  let Contract: ContractFactory = await ethers.getContractFactory(contractName)
  if (signer) {
    Contract = Contract.connect(signer)
  }

  console.log(`ContractFactory\'s signer for ${contractName} is ${await Contract.signer.getAddress()}: `)

  let contract: Contract = await Contract.deploy()
  await contract.deployed()
  console.log(`${contractName} deployed to: ${contract.address}`)
  return contract.address
}

const deployStore = async(
  contractName: string,
  tokenAddress: string,
  nftAddress: string,
  signer: Signer|null = null): Promise<string> => {
  
  let Contract: ContractFactory = await ethers.getContractFactory(contractName)
  if (signer) {
    Contract = Contract.connect(signer)
  }

  console.log(`ContractFactory\'s signer for ${contractName} is ${await Contract.signer.getAddress()}: `)

  let contract: Contract = await Contract.deploy(tokenAddress, nftAddress)
  await contract.deployed()
  console.log(`${contractName} deployed to: ${contract.address}`)
  return contract.address
}

const main = async () => {

  const [firstSigner, secondSigner] = await ethers.getSigners()
  const tokenAddress = await deployToken("Paw", firstSigner)
  const nftAddress = await deployToken("Pet", firstSigner)
  const storeAddress = await deployStore("Store", tokenAddress, nftAddress, secondSigner)

  console.log(`tokenAddress ${tokenAddress}`)
  console.log(`nftAddress ${nftAddress}`)
  console.log(`storeAddress ${storeAddress}`)
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error)
  process.exit(1)
})
