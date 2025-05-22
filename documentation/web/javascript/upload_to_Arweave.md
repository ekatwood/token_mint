# `upload_to_Arweave.js`

This JavaScript file handles the process of uploading token logos and their associated metadata to Arweave, including estimating and paying for Arweave fees using Phantom Wallet.

## Functions

### `uploadToArweaveJS(logoBytes, tokenName, tokenSymbol, fileExtension, walletAddress)`

Orchestrates the entire process of preparing and uploading both the token logo and its metadata JSON to Arweave.

#### Parameters

* `logoBytes` (Uint8Array): The raw byte data of the token logo.
* `tokenName` (string): The name of the token.
* `tokenSymbol` (string): The symbol of the token.
* `fileExtension` (string): The file extension of the logo (e.g., "png", "jpg").
* `walletAddress` (string): The public address of the user's wallet, likely used for payment.

#### Returns

* `Promise<string>`: A Promise that resolves to the Arweave URI of the uploaded metadata JSON.

#### Functionality

1.  **Convert Logo Bytes to Blob**: Converts the `logoBytes` into a `Blob` object with the appropriate image MIME type.
2.  **Upload Logo to Arweave**: Calls the internal `uploadToArweave` function with the logo `Blob` to get its Arweave URI.
3.  **Prepare Metadata JSON**: Creates a JSON object containing the `tokenName`, `tokenSymbol`, and the `image` URI (Arweave URL of the logo).
4.  **Convert Metadata to Blob**: Converts the metadata JSON into a `Blob` object with `application/json` MIME type.
5.  **Upload Metadata to Arweave**: Calls the internal `uploadToArweave` function with the metadata `Blob` to get its Arweave URI.
6.  **Return Metadata URI**: Returns the Arweave URI of the uploaded metadata.

### `uploadToArweave(blob)`

Handles the low-level process of uploading a given `Blob` to Arweave, including gas fee estimation and payment.

#### Parameters

* `blob` (Blob): The `Blob` object (either image or JSON metadata) to be uploaded to Arweave.

#### Returns

* `Promise<string>`: A Promise that resolves to the Arweave URI of the uploaded data.

#### Functionality

1.  **Import Turbo SDK**: Dynamically imports the `@ardrive/turbo-sdk` from a CDN.
2.  **Initialize Turbo Client**: Creates a new instance of `TurboClient`.
3.  **Estimate Gas Fee**: Fetches the estimated Arweave upload fee (in Winc) from the ArDrive payment API based on the `blob` size.
4.  **Phantom Wallet Payment**:
    * Constructs a Solana transaction using `window.solana.signAndSendTransaction`.
    * The transaction is sent to the `turboClient.getPaymentAddress()` with the `estimatedFee.winc` as the amount, effectively prompting the user to pay for the Arweave upload via their Phantom Wallet.
5.  **Wait for Confirmation**: Waits for the Solana transaction to be confirmed using `turboClient.waitForConfirmation`.
6.  **Upload Blob**: Uploads the `blob` to Arweave using `turboClient.uploadBlob`, including a `Content-Type` tag.
7.  **Return Arweave ID**: Returns the Arweave ID (transaction ID) of the uploaded data.

#### Dependencies

* `@ardrive/turbo-sdk`: For interacting with Arweave.
* `window.solana`: Assumes the Phantom Wallet (or a compatible Solana wallet) is injected into the browser's `window` object.