# `metamask_connect.js`

This JavaScript file provides functionality to connect to MetaMask, request accounts, and ensure the wallet is on the correct blockchain network (Arbitrum One in this case).

## Functions

### `connectMetaMask()`

Asynchronously connects to the MetaMask wallet, requests accounts, and attempts to switch to or add the Arbitrum One network if necessary.

#### Returns

* `Promise<string>`: A Promise that resolves to the connected Ethereum wallet address (string) if successful, or an error message (string) if connection fails or MetaMask is unavailable.

#### Functionality

1.  **MetaMask Availability Check**:
    * Checks if `window.ethereum` (the MetaMask provider) is available in the browser. If not, returns "MetaMask unavailable".
2.  **Request Accounts**:
    * Calls `window.ethereum.request({ method: 'eth_requestAccounts' })` to prompt the user to connect their MetaMask wallet and grant access to their accounts.
    * Retrieves the first connected account address.
3.  **Arbitrum Network Configuration**:
    * Defines `ARBITRUM_CHAIN_ID` (`0xA4B1`) and `ARBITRUM_NETWORK_DETAILS` (chain name, RPC URLs, native currency, block explorer) for Arbitrum One.
4.  **Chain ID Check and Switch/Add**:
    * Fetches the `currentChainId` from MetaMask.
    * If `currentChainId` is not `ARBITRUM_CHAIN_ID`:
        * Attempts to switch to Arbitrum One using `wallet_switchEthereumChain`.
        * If switching fails (e.g., network not added), it attempts to add the Arbitrum One network using `wallet_addEthereumChain`.
        * Handles user rejections during network switch or add operations (error code 4001).
        * Re-checks the chain ID after the attempt to ensure the wallet is on Arbitrum One.
5.  **Error Handling**:
    * Catches various errors during the connection process.
    * Specifically handles user rejection (error code 4001) by returning "MetaMask: User rejected connection." or "MetaMask: User rejected network switch/adding Arbitrum network."
    * Provides generic error messages for other connection failures.