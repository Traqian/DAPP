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
- [Node.js](https://nodejs.org/) (v14 or higher)
- [npm](https://www.npmjs.com/) (v6 or higher)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [VS Code](https://code.visualstudio.com/) (recommended)
- [MetaMask](https://metamask.io/) (for interacting with the blockchain)

### Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/comp5521-defi-swap.git
cd comp5521-defi-swap
```

#### 2. Install VS Code Extensions
Install the following extensions in VS Code to enhance your development experience:
- [Solidity](https://marketplace.visualstudio.com/items?itemName=juanblanco.solidity)
- [JavaScript](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-typescript-tslint-plugin)
- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

#### 3. Install Docker Desktop
Download and install Docker Desktop from [here](https://www.docker.com/products/docker-desktop/).

#### 4. Set Up Docker
1. Open a terminal and run the following command to check if Docker is installed correctly:
   ```bash
   docker version
   ```
2. Download the latest Ubuntu image:
   ```bash
   docker pull ubuntu
   ```
3. Verify the Docker image:
   ```bash
   docker images
   ```

## Project Structure
```
comp5521-defi-swap/
├── contracts/                  # Smart contract source files
├── scripts/                    # Deployment and interaction scripts
├── test/                       # Test files
├── frontend/                   # Frontend application
│   ├── public/                 # Static assets
│   └── src/                    # Source code
│       ├── components/         # React components
│       ├── utils/              # Utility functions
│       └── App.js              # Main application file
├── hardhat.config.js           # Hardhat configuration
└── package.json                # Project dependencies
```

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

## Further Readings
- [Hardhat Documentation](https://hardhat.org/)
- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [Web3.js Documentation](https://web3js.readthedocs.io/)
- [MetaMask Developer Documentation](https://docs.metamask.io/)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
