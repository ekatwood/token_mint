# `upload_to_Arweave.dart`

This file provides Dart-JavaScript interop for uploading data, specifically token logos and metadata, to Arweave.

## Functions

### `uploadToArweaveJS(Uint8List logoBytes, String tokenName, String tokenSymbol, String fileExtension, String walletAddress)` (External)

This is an external Dart function declaration that binds to a JavaScript function named `uploadToArweaveJS` defined in `web/javascript/upload_to_Arweave.js`. It is responsible for initiating the Arweave upload from the Dart side.

#### Parameters

* `logoBytes` (Uint8List): The bytes of the token logo image.
* `tokenName` (String): The name of the token.
* `tokenSymbol` (String): The symbol of the token.
* `fileExtension` (String): The file extension of the logo (e.g., "png", "jpg").
* `walletAddress` (String): The public address of the user's wallet, likely used for payment or identification on the JS side.

#### Returns

* `Future<String>`: A `Future` that resolves to the Arweave URL of the uploaded metadata.

### `uploadToArweave(Uint8List logoBytes, String tokenName, String tokenSymbol, String fileExtension, String walletAddress)`

This is a Dart wrapper function that calls the external JavaScript function `uploadToArweaveJS`.

#### Parameters

* `logoBytes` (Uint8List): The bytes of the token logo image.
* `tokenName` (String): The name of the token.
* `tokenSymbol` (String): The symbol of the token.
* `fileExtension` (String): The file extension of the logo.
* `walletAddress` (String): The public address of the user's wallet.

#### Returns

* `Future<String>`: A `Future` that resolves to the Arweave URL of the uploaded metadata, or `'error'` if an exception occurs during the JavaScript interop call.

#### Throws

* Catches any exceptions that occur during the call to `uploadToArweaveJS` and logs them using `errorLogger` from `firestore_functions.dart`. It returns `'error'` in such cases.