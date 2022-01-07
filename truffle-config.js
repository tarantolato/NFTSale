const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
const providerBSCTestnet = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.BSCTESTNET_RPC_URL);
const providerBSCMainnet = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.BSCMAINNET_RPC_URL);
const providerKovan = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.KOVAN_RPC_URL);
const providerRinkeby = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.RINKEBY_RPC_URL);
const providerRopsten = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.ROPSTEN_RPC_URL);
const providerPolygonMumbai = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.POLYGONMUMBAI_RPC_URL);
const providerPolygonMainnet = new HDWalletProvider([process.env.PRIVATE_KEY], process.env.POLYGONMAINNET_RPC_URL);

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: 5777,
      gas:5500000,
      gasPrice: 20000000000
    },
    ganache: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      gas:5500000,
      gasPrice: 20000000000
    },
    bsc_testnet: {
      provider: () => providerBSCTestnet,
      network_id: 97,
      confirmations: 3,
      timeoutBlocks: 600,
      skipDryRun: true,
      gasLimit:5500000
    },
    bsc_mainnet: {
      provider: () => providerBSCMainnet,
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 600,
      skipDryRun: true,
      gasLimit:5500000
    },
    kovan: {
      provider: () => providerKovan,
      network_id: 42,
      confirmations: 3,
      timeoutBlocks: 600,
      skipDryRun: true,
      gasLimit:5500000
    },
    rinkeby: {
      provider: () => providerRinkeby,
      network_id: 4,
      confirmations: 3,
      timeoutBlocks: 600,
      skipDryRun: true,
      gasLimit:5500000
    },
    ropsten: {
      provider: () => providerRopsten,
      network_id: 3,
      confirmations: 3,
      timeoutBlocks: 200,
      skipDryRun: true,
      gasLimit:5500000
    },
    polygon_mumbai: {
      provider: () => providerPolygonMumbai,
      network_id: 80001,
      confirmations: 3,
      timeoutBlocks: 200,
      skipDryRun: true,
      gasLimit:10000000000
    },
    polygon_mainnet: {
      provider: () => providerPolygonMainnet,
      network_id: 137,
      confirmations: 3,
      timeoutBlocks: 200,
      skipDryRun: true,
      gasLimit:5500000
    },
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: '0.8.4',
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
      },
    },
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  //
  // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
  // those previously migrated contracts available in the .db directory, you will need to run the following:
  // $ truffle migrate --reset --compile-all

  db: {
    enabled: false,
  },
  api_keys: {
    //etherscan: process.env.ETHERSCAN_API_KEY
    //polygonscan: process.env.POLYGONSCAN_API_KEY
    bscscan: process.env.BSCSCAN_API_KEY
  },
  plugins: [
    'truffle-plugin-verify',
    'truffle-contract-size'
    ]
}
