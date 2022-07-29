# Pet O' Rama

Open-source Pet store with PET and PAW tokens.

Implement the contracts in the "contracts" folder according to the instructions laid out in the files.  Then, you can proceed with the following steps to test your smart contracts.

## Testing your Smart Contracts

First, create a .env file in the root folder and fill it with the following:
```shell
GOERLI_API_URL=https://goerli.infura.io/v3/
METAMASK_PRIVATE_KEY=

# Obtained after deploying contracts
TOKEN_ADDRESS=
NFT_ADDRESS=
STORE_ADDRESS=
```

You will need to put in your own MetaMask private key.  This project will only use the command line, and no one will have access to your private key, but delete the key after completing the project for security reasons.  You will obtain the contract addresses later on.

Run `yarn` in the project root to install all the dependencies, including [hardhat](https://hardhat.org).

Then, start a hardhat node with command `yarn run hardhat node`. This local node will be the blockchain to interact with.

Compile all contracts with `yarn run hardhat compile`.

Deploy contracts with `yarn run hardhat run scripts/deploy.ts --network localhost`. After this, the addresses of the deployed contracts will be printed in the console. Save these addresses in .env.

## Interacting with smart contracts

We can interact with the smart contracts by running the Hardhat console locally with the command (make sure the Hardhat node is running):

```shell
yarn run hardhat console --network localhost
```

You will land in a console environment where you can interact with each smart contracts.

```shell
Welcome to Node.js v16.15.1.
Type ".help" for more information.
>
```

First, run the following line to load variables from process.env.
```shell
> const { TOKEN_ADDRESS, NFT_ADDRESS, STORE_ADDRESS } = process.env
```

### PAW fungible token

Start by initializing a PAW contract instance:

```shell
> let Paw = await ethers.getContractFactory("Paw")
> let paw = await Paw.attach(TOKEN_ADDRESS)
```

Test that you can call the contract's methods from the console:

```shell
> await paw.name()
'Paw'
```

Let's query the PAW token balance of the contract's owner account. Remember the printed address when you deployed the contracts? You can call this function to list all available accounts too:

```shell
> let accounts = await ethers.provider.listAccounts()
> accounts
```

The first listed address is the signer's address or the same address who deployed the contracts.

Now query the PAW token balance of the signing account, and see how many tokens there is (hopefully it isn't zero.). Integers are treated as a `BigNumber` in ethers.js, so you will have to call `toNumber()` on the result you get:

```shell
> let balance = await paw.balanceOf(accounts[0])
> balance.toNumber()
```

Now, let's try to transfer some tokens to another address, say, the second address in `accounts`:

```shell
> let tx = await paw.transfer(accounts[1], 100)
```

Wait a few seconds for the transaction to go through, and try to query the signer's balance one more time. Hopefully, the account should now have 100 less PAW tokens.

Then, what if we want the second account to transfer half of the tokens to the third account?

The PAW `Contract` instance (instantiated as `paw` in the example) is implicitly connected to the signer account. That's how we could just call `paw.transfer(recipient, amount)` to send tokens to the recipient.

To connect to another account, call `connect(signer)` on the `Contract` instance before calling `transfer`.
This signer is created by taking one of the possible accounts and doing the following.

```shell
> let provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/")
> let account1 = provider.getSigner(accounts[1])
> await paw.connect(account1).transfer(accounts[2], 50)
```

Query the balance of the second account and see if it only has half of the tokens.

You can also request an airdrop, as follows:

```shell
> await paw.connect(account1).requestAirdrop()
```

You can check the balances of accounts to verify that the airdrop of tokens based on the value of airDropAmount in Paw.sol occurred.

### PET non-fungible token

Start by initializing a PET contract instance:

```shell
> let Pet = await ethers.getContractFactory("Pet")
> let pet = await Pet.attach(NFT_ADDRESS)
```

Let's try to mint the first ever PET token to the signer:

```shell
> await pet.mintTo(accounts[0], "/images/1.jpg")
```

> Note: The file URI passed as a string to `mintTo` is meant to be a relative or absolute URI to a resource relevant to the mint. In this case, a local image file of a pet is being used for illustrative purposes. In practice, you would use a permanent URI on the internet as a tokenURI, like a URI to an AWS S3 resource or an IPFS URI to the image stored on IPFS/Filecoin network.

Let's query the balance of the first account:

```shell
> (await pet.balanceOf(accounts[0])).toNumber()
```

Hopefully, the account only have 1 PET token at the moment.

Now, let's transfer this minted PET to the second account:

```shell
> let currentTokenId = await pet.currentTokenId()
> await pet.transferFrom(accounts[0], accounts[1], currentTokenId)
```

Now query the owner of the current PET token:

```shell
> await pet.ownerOf(currentTokenId)
```

Hopefully it should print out the address for accounts[1].

### NFT Pet Store

Now, we're ready to initialize the store contract.

```shell
> let Store = await ethers.getContractFactory("Store")
> let store = await Store.attach(STORE_ADDRESS)
```

You can see that the current token, which belongs to accounts[1], is not for sale and has a price of 0.  This can change, though, by putting the NFT up for sale:

```shell
> await store.isOnSale(currentTokenId)
> await store.tokenPrice(currentTokenId)
> await store.connect(account1).nftSale(currentTokenId, 10)
```

Note that approve() takes the account connected to the contract and gives allowance to the chosen account, which is often required of various functions when transferring tokens.

```shell
> await paw.approve(accounts[0], 10000)
> await paw.approve(accounts[1], 10000)
> await paw.approve(STORE_ADDRESS, 10000)
> await pet.connect(account1).approve(STORE_ADDRESS, currentTokenId)
```

After these approvals, accounts[0] can now purchase the NFT from accounts[1] at the chosen price:

```shell
> await store.nftBuy(currentTokenId)
> await pet.ownerOf(currentTokenId)
```

You can also have the owner of the pet and paw contracts (accounts[0] by default) directly mint and purchase an NFT as well:

```shell
> await store.nftMintBuy(100, "/images/pet1.jpg")
> let currentTokenId = await pet.currentTokenId()
> await pet.ownerOf(currentTokenId)
```

## Credits
We would like to thank Pan Chasinga from the Filecoin Foundation for being the originator of this project!
