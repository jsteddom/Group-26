# Group-26
 Blockchain-Enabled Pharmaceutical Supply Chain Provenance


Group Members:                 | Teachers & TAs
Gautham Jayakrishnan           | Swathi Punathumkandi
Ridham Ka Patel                | Sandipan De
Tushmi Sharma                  | Chaitanya Ashok Patel
Jonathan Steddom               | Meet Vyas
Maz Bilgrami                   |


# PharmaSupplyChain

## 📌 Project Overview
This project implements a blockchain-based supply chain management system to track pharmaceutical products and raw materials throughout their lifecycle.  

The system ensures **transparency, authenticity, and traceability** in the pharmaceutical ecosystem using Ethereum smart contracts written in Solidity.  

Key features include:
- Immutable record keeping for raw materials and products  
- Role-based access control using OpenZeppelin’s `AccessControl`  
- Event logging for complete traceability  
- Product provenance verification  
- Security protections via OpenZeppelin’s `ReentrancyGuard`  

---

## 🛠️ Tech Stack
- **Solidity (v0.8.x)** – Smart contract language  
- **Remix IDE** – Online IDE for writing, compiling, and deploying contracts  
- **MetaMask** – Wallet for deploying and interacting with contracts on Ethereum networks  
- **Ethereum** – Blockchain platform (testnets like Polygon Amoy/Sepolia recommended)  
- **OpenZeppelin Contracts** – Standard libraries for access control and security  

---


## ⚙️ Environment Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/pharma-supply-chain.git
   cd pharma-supply-chain

2. Install Dependencies
    ```bash
    forge install OpenZeppelin/openzeppelin-contracts@v4.9.3
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
3. Initialize a Foundry Project.
   ```bash
   mkdir myproject
   cd myproject
   forge init .
4. Remappings May Be Required. Edit the foundry.toml to include the following:
   ```bash
   [profile.default]
   remappings = [
    "@openzeppelin/=lib/openzeppelin-contracts/",
    "forge-std/=lib/forge-std/src/"
   ]
    
5. Compile Contract and Start Blockchain Locally with Anvil. This will print private keys/addresses for testing.
   ```bash
   forge build
   anvil

6. Leave Terminal Open from previous step. Open new terminal in project root.
   ```bash
   forge create src/SupplyChain.sol:SupplyChain \
     --rpc-url http://127.0.0.1:8545 \
     --private-key <PRIVATE_KEY> //This will be generate from anvil when starting contract

 7. Assign Roles to addresses. From running anvil, you can assign roles to the generated addresses.
    ```bash
    // Get role hash
    cast keccak "REGULATOR_ROLE"
    // Admin can assign role to other addressess
    cast send <USER_ADDRESS> "grantRole(bytes32,address)" \
      0x7d4d... 0xABC123... \    // Role... Address to assign
      --private-key <PRIVATE_KEY>
    // Verify role was assigned
    cast call <USER_ADDRESS> "hasRole(bytes32,address)" 0x7d4d... 0xABC123...

 8. Ready to test. The following are call formats 
    ```bash
    // Read only functions
    cast call <USER_ADDRESS> "myGetter() returns (uint256)"
    // Write functions
    cast send <USER_ADDRESS> "myFunction(uint256)" 42 \
      --private-key <PRIVATE_KEY>


