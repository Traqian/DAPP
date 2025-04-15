# COMP5521 DeFi Swap Platform

Welcome to the COMP5521 DeFi Swap Platform! This project is a decentralized finance (DeFi) platform that allows users to swap tokens and provide liquidity to a liquidity pool.

## Table of Contents
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Project Structure](#project-structure)
- [Smart Contract Deployment](#smart-contract-deployment)
- [Frontend Application](#frontend-application)
- [Interacting with the Blockchain](#interacting-with-the-blockchain)
- [Testing](#testing)
- [Further Readings](#further-readings)

## Getting Started

### Prerequisites
Before you begin, ensure you have the following installed on your machine:
- [Node.js](https://nodejs.org/) (v22 or higher)
- [npm](https://www.npmjs.com/) (v10 or higher)
- [VS Code](https://code.visualstudio.com/) (recommended)
- [MetaMask](https://metamask.io/) (for interacting with the blockchain)

### Installation

#### 1. Download ZIP of the Code
## Project Structure
```
DAPP-master/
        ├── usr/                                       
          ├── app/           
        │   ├── workspace/                                   
        │       ├── frontend/
        │       ├── contracts/       
        │       ├── scripts/           
        │       └── test/
        │       └── hardhat.config.js
        │       └── package
        │       └── package-lock               
```
#### 2.Install dependencies
.\DAPP-master\usr\app\workspace\frontend>npm install

#### 3.Connect to Hardhat Network
    1. npx hardhat node
    2. Select the network you are currently connected to in the upper left corner.
    3. Select “Add a custom network”.
    4. Enter `http://127.0.0.1:8545/` or `http://localhost:8545`  as the default RPC URL.
    5. Enter `31337` as the chain ID.
    6. Enter an arbitrary network name and an arbitrary currency symbol（such as DF）.
    7. Click “Save”.

#### 4.Interacting with Blockchain 

npx hardhat run scripts/transferDF.js --network localhost

npx hardhat run --network localhost scripts/deploy.js

npx hardhat test

npx hardhat console --network localhost

const NewToken = await hre.ethers.getContractFactory("NewToken");

const Alpha = NewToken.attach('0x5F3476370470E1d7A83b3982D9BD3e972Ea5dB57')

await Alpha.transfer('0xF62Dab013fdFcE34Da4bd2dE80e293247973504D', 100000000000000000000000n)

const Beta = NewToken.attach('0x010C413A9FfD17Fe1D85384BeC96D0f099da478D')

await Beta.transfer('0xF62Dab013fdFcE34Da4bd2dE80e293247973504D', 100000000000000000000000n)

npx hardhat run scripts/transferALPHA.js --network localhost

npx hardhat run scripts/transferBETA.js --network localhost


const Pool = await hre.ethers.getContractFactory("Pool");

const pool = Pool.attach('0xa5a43731500A75BF9a7c522d919F7FD370718bEb')

const NewToken = await hre.ethers.getContractFactory("NewToken");

const Alpha = NewToken.attach('0x5F3476370470E1d7A83b3982D9BD3e972Ea5dB57')

await Alpha.approve('0xa5a43731500A75BF9a7c522d919F7FD370718bEb', ethers.parseEther("1000000"))

const Beta = NewToken.attach('0x010C413A9FfD17Fe1D85384BeC96D0f099da478D')

await Beta.approve('0xa5a43731500A75BF9a7c522d919F7FD370718bEb', ethers.parseEther("1000000"))

await pool.addLiquidity(ethers.parseEther("1000"))
## Smart Contract Deployment

### 1. Install Hardhat and Dependencies
```bash
npm install --save-dev hardhat
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts
```

### 2. Configure Hardhat
Update `hardhat.config.js` with the following content:
```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 31337
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    }
  }
};
```

### 3. Compile Contracts
```bash
npx hardhat compile
```

### 4. Deploy Contracts
Run the deployment script:
```bash
npx hardhat run scripts/deploy.js --network localhost
```

## Frontend Application

### 1. Create React App
```bash
cd frontend
npx create-react-app .
```

### 2. Install Dependencies
```bash
npm install web3 ethers react-bootstrap bootstrap
```

### 3. Start the Frontend
```bash
npm start
```

## Interacting with the Blockchain

### 1. Connect MetaMask to Hardhat Network
1. Open MetaMask and select "Add a custom network".
2. Enter the following details:
   - **Network Name**: Hardhat Network
   - **RPC URL**: `http://127.0.0.1:8545`
   - **Chain ID**: `31337`
   - **Currency Symbol**: ETH

### 2. Transfer Tokens
Use the provided scripts to transfer tokens to your MetaMask account:
```bash
npx hardhat run scripts/transferALPHA.js --network localhost
npx hardhat run scripts/transferBETA.js --network localhost
```

## Testing

### 1. Run Tests
```bash
npx hardhat test
```

### 2. Test Swap Functionality
1. Start the Hardhat network:
   ```bash
   npx hardhat node
   ```
2. Run the swap test script:
   ```bash
   npx hardhat run scripts/swapTest.js --network localhost
   ```
### Result 
![960da16caad38e628cf556419373604](https://github.com/user-attachments/assets/29499df5-2dd2-4461-8400-0ad7416d0f20)
![cde21d36ef8452a811d3b8f364e3067](https://github.com/user-attachments/assets/ebcf5ed0-a2bb-41cc-9ddf-61f1f58280f7)
![9e65bffe4e0ae03f0d749ec539a4607](https://github.com/user-attachments/assets/66c4933e-6c6d-44fb-872a-8440a64fd3ac)
![405bb295f1834045a0dedd58e4006b8](https://github.com/user-attachments/assets/af7a3cfd-c304-40a2-870a-d9b2dd99ede9)
![08a2e593e7236557ccddff3d5b2d424](https://github.com/user-attachments/assets/668ed129-bede-4118-bc4b-40c99661c786)
![6c4e2bc3808e7291102b38fc384b1eb](https://github.com/user-attachments/assets/21228082-75ab-45ba-8bb9-f775c84f8da1)
![3336ff33b76e654e529cd256ab52a71](https://github.com/user-attachments/assets/cc0211a2-87cc-4c5f-a6b9-f1b172780b3a)
![2cc7771d355f3af61c21e817ffe8a3c](https://github.com/user-attachments/assets/02c413db-d3cf-483b-9f34-de7355aec52d)
![053556d66870ac44dcca57c3507385a](https://github.com/user-attachments/assets/1074ae62-01da-47f0-9d2f-79b72887af74)
![8ad7770169b05990464dcf0c7821ad1](https://github.com/user-attachments/assets/a19da82a-7896-44da-baf6-1d4bfc2d28ee)
![5123be93c3555394b42e536dbdcbc61](https://github.com/user-attachments/assets/922822b3-b832-4a20-92d2-e378afa86680)
![22523320e9f4ee5065db3ff33fb1218](https://github.com/user-attachments/assets/6aad292c-1e83-4987-b2ec-338077d22577)

## Further Readings
- [Hardhat Documentation](https://hardhat.org/)
- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [Web3.js Documentation](https://web3js.readthedocs.io/)
- [MetaMask Developer Documentation](https://docs.metamask.io/)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
