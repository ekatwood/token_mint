# `auth_provider.dart`

This file defines the `AuthProvider` class, which manages the application's authentication state using the `ChangeNotifier` pattern.

## Classes

### `AuthProvider`

A `ChangeNotifier` that holds and provides the current authentication status and connected wallet information to its listeners.

#### Properties

* **`_isLoggedIn` (Private)**: A boolean indicating whether a user is currently logged in (a wallet is connected).
* **`_walletAddress` (Private)**: A string storing the connected wallet address.
* **`_blockchainNetwork` (Private)**: A string storing the name of the blockchain network (e.g., "Solana", "Arbitrum").

#### Getters

* **`isLoggedIn`**: Returns the current value of `_isLoggedIn`.
* **`walletAddress`**: Returns the current value of `_walletAddress`.
* **`blockchainNetwork`**: Returns the current value of `_blockchainNetwork`.

#### Methods

* **`login(String walletAddress, String blockchainNetwork)`**:
    * Sets `_isLoggedIn` to `true`.
    * Assigns the provided `walletAddress` to `_walletAddress`.
    * Assigns the provided `blockchainNetwork` to `_blockchainNetwork`.
    * Calls `notifyListeners()` to inform all widgets listening to this provider that the state has changed.

* **`logout()`**:
    * Sets `_isLoggedIn` to `false`.
    * Clears `_walletAddress` and `_blockchainNetwork`.
    * Calls `notifyListeners()` to inform all widgets listening to this provider that the state has changed.