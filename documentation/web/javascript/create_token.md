# `create_token.js`

This JavaScript file contains the core logic for minting new Solana tokens, including interaction with the Solana blockchain, fetching treasury wallet addresses, and creating token metadata.

## Functions

### `WorkspaceTreasuryPublicWalletAddress()`

Asynchronously fetches the public wallet address designated as the treasury from a Google Cloud Function.

#### Returns

* `Promise<string>`: A Promise that resolves to the treasury wallet address as a string.

#### Throws

* Logs an error and throws a new Error if the fetch operation fails or if the treasury address is not found in the response.

### `mintToken(nameOfToken, symbol, metadataUri, totalNumTokens, userPublicWalletAddress)`

Asynchronously performs the steps required to mint a new Solana token.

#### Parameters

* `nameOfToken` (string): The desired name for the new token.
* `symbol` (string): The desired symbol for the new token.
* `metadataUri` (string): The Arweave URI where the token's metadata (including its logo) is stored.
* `totalNumTokens` (number): The total supply of the tokens to be minted.
* `userPublicWalletAddress` (string): The public address of the user's wallet initiating the mint.

#### Functionality

1.  **Connect to Solana Devnet**: Establishes a connection to the Solana devnet cluster.
2.  **Load Creator Keypair**: Reads the secret key from a local file "asdf" (note: this path suggests a development setup and should be secured for production).
3.  **Fetch Treasury Wallet**: Calls `WorkspaceTreasuryPublicWalletAddress()` to get the Solana treasury wallet address.
4.  **Create Mint Account**: Creates a new SPL Token mint account on the Solana blockchain.
5.  **Get/Create Associated Token Account**: Retrieves or creates an associated token account for the treasury wallet.
6.  **Mint Tokens**: Mints the specified `totalNumTokens` to the treasury's associated token account.
7.  **Create Metadata Account**: Uses `@metaplex-foundation/mpl-token-metadata` to create a metadata account for the token on the Solana blockchain.
8.  **Add Metadata**: Adds the token's `name`, `symbol`, and `metadataUri` to the metadata account.
9.  **Summary Logging**: Logs a summary of the token creation, including user wallet, treasury wallet, and the new token's mint address.

#### Throws

* Logs and re-throws any errors encountered during the minting process, such as network issues, invalid keys, or transaction failures.

#### Dependencies

* `@solana/web3.js`: For Solana blockchain interactions.
* `@solana/spl-token`: For SPL Token program interactions.
* `@metaplex-foundation/mpl-token-metadata`: For creating and managing token metadata.
* `fs/promises`: For reading local files (used to load `creatorKeypair`).
* `Buffer` (implicit from `Buffer.from`): For handling buffer operations.