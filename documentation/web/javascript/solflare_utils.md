# `solflare_utils.js`

This JavaScript file provides utility functions for interacting with the Solflare wallet SDK, making it easier to connect, disconnect, and check the connection status of the Solflare wallet.

## Global Variables

* **`wallet`**: An instance of the `Solflare` class imported from `@solflare-wallet/sdk`. This instance manages the connection to the Solflare wallet.

## Functions

### `solflareConnect()`

Asynchronously connects to the Solflare wallet using the `wallet` instance.

#### Returns

* `Promise<string>`: A Promise that resolves to the connected Solflare public key (wallet address) as a string if successful.

#### Throws

* Logs an error and re-throws any exceptions encountered during the connection process.

### `solflareDisconnect()`

Asynchronously disconnects from the Solflare wallet using the `wallet` instance.

#### Returns

* `Promise<void>`: A Promise that resolves when the disconnection is complete.

#### Throws

* Logs an error and re-throws any exceptions encountered during the disconnection process.

### `solflareIsConnected()`

Asynchronously checks the current connection status of the Solflare wallet using the `wallet` instance.

#### Returns

* `Promise<boolean>`: A Promise that resolves to `true` if the wallet is connected, `false` otherwise.

#### Throws

* Logs an error and re-throws any exceptions encountered during the connection status check.

## Global Exposure

The following functions are exposed globally on the `window` object, making them accessible from Dart code:

* `window.solflareConnect`
* `window.solflareDisconnect`
* `window.solflareIsConnected`