# `appbar.dart`

This file defines the `CustomAppBar` widget, which serves as the application's top navigation bar.

## Classes

### `CustomAppBar`

A `StatelessWidget` that implements `PreferredSizeWidget` to provide a custom application bar.

#### Properties

* **`preferredSize`**: Overrides the getter to define the preferred height of the app bar, typically `kToolbarHeight`.

#### Methods

* **`build(BuildContext context)`**:
    * Builds the `AppBar` widget.
    * Sets `backgroundColor` to `Colors.tealAccent`.
    * Includes a `GestureDetector` as the `leading` widget displaying "MOONROCKET", which navigates to the home route (`/`) when tapped.
    * Dynamically renders actions (`_buildLoggedInActions` or `_buildLoggedOutAction`) based on the `isLoggedIn` status from `AuthProvider`.

* **`_buildLoggedInActions(BuildContext context, AuthProvider authProvider)` (Private Method)**:
    * Returns a `Row` of widgets displayed when a user is logged in.
    * Includes a `Text` widget showing the `walletAddress` from `authProvider`.
    * Provides a `TextButton` to navigate to the token minting page (`/mint_token`).
    * Provides a `TextButton` to navigate to the settings page (`/settings`).
    * Includes an `ElevatedButton` for the "Logout" action, which calls `authProvider.logout()`.

* **`_buildLoggedOutAction(BuildContext context)` (Private Method)**:
    * Returns an `ElevatedButton` for the "Connect Wallet" action, displayed when no user is logged in.
    * Triggers a dialog (`_showWalletConnectDialog`) to allow the user to select a wallet to connect.

* **`_showWalletConnectDialog(BuildContext context, AuthProvider authProvider)` (Private Method)**:
    * Displays an `AlertDialog` for wallet connection.
    * Presents options to connect via "Solflare Wallet" or "MetaMask".
    * Calls `_connectSolflare` or `_connectMetaMask` based on user selection.

* **`_connectSolflare(BuildContext context, AuthProvider authProvider)` (Private Method)**:
    * Attempts to connect to the Solflare wallet by calling the JavaScript function `connectSolflare`.
    * If successful, logs the user in via `authProvider.login()` with the connected wallet address and "Solana" as the network.
    * Logs the connected Solflare wallet to Firestore via `solflareWalletConnected`.
    * Displays `SnackBar` messages for success or failure.

* **`_connectMetaMask(BuildContext context, AuthProvider authProvider)` (Private Method)**:
    * Attempts to connect to the MetaMask wallet by calling the JavaScript function `connectMetaMask`.
    * If successful, logs the user in via `authProvider.login()` with the connected wallet address and "Arbitrum" as the network.
    * Displays `SnackBar` messages for success or failure.