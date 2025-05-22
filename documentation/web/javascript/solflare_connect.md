# `solflare_connect.js`

This JavaScript file provides functions for connecting to, disconnecting from, and checking the connection status of the Solflare wallet.

## Functions

### `connectSolflare()`

Asynchronously attempts to connect to the Solflare wallet.

#### Returns

* `Promise<string>`: A Promise that resolves to the connected Solflare public key (wallet address) as a string if successful, or "Solflare unavailable" if the wallet is not found or connection fails.

#### Functionality

* Checks if `window.solflare` (the Solflare provider) is available. If not, returns "Solflare unavailable".
* Calls `window.solflare.connect()` to initiate the connection.
* If the connection is successful, it returns the string representation of the connected `publicKey`.
* Catches and returns "Solflare unavailable" for any errors during connection.

### `isSolflareConnected()`

Asynchronously checks the current connection status of the Solflare wallet.

#### Returns

* `Promise<Object>`: A Promise that resolves to an object with a `connected` boolean property and an optional `error` string.

#### Functionality

* Checks if `window.solflare` is available.
    * If available, returns `{ connected: window.solflare.isConnected }`.
    * If not available, returns `{ connected: false, error: "Solflare not available" }`.
* Catches any errors during the check and returns `{ connected: false, error: errorMessage }`.

### `disconnectSolflare()` (Currently Inactive/Placeholder)

This function is declared but appears to be commented out in the provided snippet. If activated, it would likely allow disconnecting the Solflare wallet.

*Note: The commented-out sections for `signTransactionSolflare`, `signAndSendTransactionSolflare`, and `signMessageSolflare` indicate potential future functionality for signing transactions and messages using Solflare.*

## Global Exposure

The following functions are exposed globally on the `window` object for easy access from Dart:

* `window.connectSolflare`
* `window.disconnectSolflare`
* `window.isSolflareConnected`