# NFT Marketplace Backend

# Getting Started

## Requirements

-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
    -   You can run `git --version` and you see a response like `git version x.x.x`
-   [Nodejs](https://nodejs.org/en/)
    -   You can run:
        -   `node --version` and get an ouput like: `vx.x.x`

## Quickstart

```
git clone  https://github.com/Yash-Bansal-2403/nft-marketplace-backend.git
npm install
```

# Usage

Deploy:

```
npm hardhat deploy
```

## Testing

```
npx hardhat test
```

# Deployment to a testnet or mainnet

1. Setup environment variables

You have to set your environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

2. Deploy

run:

```
npx hardhat deploy --network mumbai
```

And copy / remember the contract address (for TheGraph protocol).

3. Enter your NFT Marketplace!

You're contract is now setup to be a tamper proof NFT Marketplace.You can mint and list your NFT by running-

```
npx hardhat run scripts/mint-and-list-item.js --network mumbai
```

## Verify on etherscan

If you deploy to a testnet or mainnet, you can verify it if you get an [API Key](https://etherscan.io/myapikey) from Etherscan and set it as an environemnt variable named `ETHERSCAN_API_KEY`. You can pop it into your `.env` file as seen in the `.env.example`.

In it's current state, if you have your api key set, it will auto verify goerli contracts!

However, you can manual verify with:

```
npx hardhat verify --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS
```

# Thank you!
