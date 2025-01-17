const {
  Connection,
  Keypair,
  clusterApiUrl,
  PublicKey,
  Transaction,
  sendAndConfirmTransaction,
} = require("@solana/web3.js");
const {
  createMint,
  getOrCreateAssociatedTokenAccount,
  mintTo,
} = require("@solana/spl-token");
const {
  createCreateMetadataAccountV3Instruction,
} = require("@metaplex-foundation/mpl-token-metadata");
const fs = require("fs");

(async () => {
  try {
    //TODO: connect via a wallet from the front end
    // Connect to the Solana Devnet
    const connection = new Connection(clusterApiUrl("devnet"), "confirmed");
    console.log("Connected to Devnet");

    // Load the creator wallet from file
    const creatorKeypair = Keypair.fromSecretKey(
      Uint8Array.from(
        JSON.parse(fs.readFileSync("asdf", "utf8"))
      )
    );

    // Create a new token
    const decimals = 7;
    const tokenMint = await createMint(
      connection,
      creatorKeypair,
      creatorKeypair.publicKey,
      null,
      decimals
    );
    console.log("Token Mint Address:", tokenMint.toBase58());

    // Get or create the associated token account for the creator
    const creatorTokenAccount = await getOrCreateAssociatedTokenAccount(
      connection,
      creatorKeypair,
      tokenMint,
      creatorKeypair.publicKey
    );

    // Mint tokens to the creator's account
    const creatorShare = 500_000_000 * 10 ** decimals * 0.05; // 5%
    await mintTo(
      connection,
      creatorKeypair,
      tokenMint,
      creatorTokenAccount.address,
      creatorKeypair,
      creatorShare
    );
    console.log("Minted 5% of tokens to the creator's account");

    // Generate a new keypair for the storage wallet
    const storageKeypair = Keypair.generate();

    // Get or create the associated token account for the storage wallet
    const storageTokenAccount = await getOrCreateAssociatedTokenAccount(
      connection,
      creatorKeypair,
      tokenMint,
      storageKeypair.publicKey
    );

    // Mint tokens to the storage wallet's token account
    const storageShare = 500_000_000 * 10 ** decimals * 0.95; // 95%
    await mintTo(
      connection,
      creatorKeypair,
      tokenMint,
      storageTokenAccount.address,
      creatorKeypair,
      storageShare
    );
    console.log("Minted 95% of tokens to the storage wallet's account");

    // Add metadata to the created token
    const TOKEN_METADATA_PROGRAM_ID = new PublicKey(
      "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"
    );

    const metadataPDAAndBump = PublicKey.findProgramAddressSync(
      [
        Buffer.from("metadata"),
        TOKEN_METADATA_PROGRAM_ID.toBuffer(),
        tokenMint.toBuffer(),
      ],
      TOKEN_METADATA_PROGRAM_ID
    );

    const metadataPDA = metadataPDAAndBump[0];

    const metadataData = {
      name: "name_of_coin",
      symbol: "ticker",
      uri: "https://arweave.net/1234",
      sellerFeeBasisPoints: 0,
      creators: null,
      collection: null,
      uses: null,
    };

    const transaction = new Transaction();

    const createMetadataAccountInstruction =
      createCreateMetadataAccountV3Instruction(
        {
          metadata: metadataPDA,
          mint: tokenMint,
          mintAuthority: creatorKeypair.publicKey,
          payer: creatorKeypair.publicKey,
          updateAuthority: creatorKeypair.publicKey,
        },
        {
          createMetadataAccountArgsV3: {
            collectionDetails: null,
            data: metadataData,
            isMutable: true,
          },
        }
      );

    transaction.add(createMetadataAccountInstruction);

    const transactionSignature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [creatorKeypair]
    );

    console.log("Metadata added");

    console.log("\nToken Creation Summary:");
    console.log("Creator Wallet Address:", creatorKeypair.publicKey.toBase58());
    console.log("Storage Wallet Address:", storageKeypair.publicKey.toBase58());
    console.log("Token Mint Address:", tokenMint.toBase58());
  } catch (error) {
    console.error("Error:", error);
  }
})();
