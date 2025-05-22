# `create_token_form.dart`

This file defines the `TokenFactory` widget, which provides a form for users to create new tokens. It handles user input, image selection, validation, and initiates the token minting process.

## Classes

### `TokenFactory`

A `StatefulWidget` that manages the state and UI for creating a new token.

#### State (`_TokenFactoryState`)

The private state class for `TokenFactory`.

#### Properties

* `_formKey`: A `GlobalKey` for the `Form` widget, used for form validation.
* `_nameController`: `TextEditingController` for the token name input.
* `_symbolController`: `TextEditingController` for the token symbol input.
* `_tokenQuantityController`: `TextEditingController` for the token quantity input.
* `_logoFileBytes`: `Uint8List?` to store the bytes of the selected logo image.
* `_picker`: An `ImagePicker` instance for picking images.
* `_walletConnected`: A boolean indicating if a wallet is connected (from `AuthProvider`).
* `_walletAddress`: `String?` storing the connected wallet address.
* `_fileExtension`: `String?` storing the file extension of the uploaded logo.
* `_tokenQuantity`: `int?` storing the parsed token quantity.
* `_fontFamily`: `String` defining the font family for text styles.

#### Methods

* **`initState()`**:
    * Initializes the state when the widget is inserted into the widget tree.
    * Adds listeners to `_tokenQuantityController` to parse the integer value.
    * Adds a listener to `AuthProvider` to update `_walletConnected` and `_walletAddress` when the authentication state changes.

* **`dispose()`**:
    * Cleans up controllers and listeners when the widget is removed from the tree to prevent memory leaks.

* **`isValidTokenName(String name)`**:
    * **Parameters**: `name` (String) - The token name to validate.
    * **Returns**: `bool` - `true` if the name length is between 3 and 32 characters, `false` otherwise.

* **`isValidTokenSymbol(String symbol)`**:
    * **Parameters**: `symbol` (String) - The token symbol to validate.
    * **Returns**: `bool` - `true` if the symbol length is between 2 and 10 characters, `false` otherwise.

* **`_pickImage()` (Private Method)**:
    * Asynchronously opens an image picker to allow the user to select an image from their device.
    * If an image is selected, it reads the image bytes and updates `_logoFileBytes` and `_fileExtension`.
    * Displays a `SnackBar` if no image is selected.

* **`build(BuildContext context)`**:
    * Builds the UI for the token creation form.
    * Includes `CustomAppBar`.
    * Uses a `Form` with `_formKey` for validation.
    * Provides `TextFormField` widgets for token name, symbol, and quantity, with validation logic.
    * Includes an `ElevatedButton` for "Upload Logo" that calls `_pickImage()`.
    * Displays a placeholder or the selected logo image.
    * Features a "Mint Token" `ElevatedButton`:
        * When pressed, it validates form inputs.
        * If inputs are valid and a logo is uploaded, it performs:
            * Image safety check via `checkImageSafety`.
            * If safe, uploads the logo and metadata to Arweave via `uploadToArweave`.
            * Initiates token minting via `mintToken` (Dart-JS interop).
            * Displays `SnackBar` messages for success, failure, or unsafe image.
        * Requires a wallet to be connected to proceed with minting.