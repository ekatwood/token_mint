// TODO: unit test this function on devnet

import {
  Connection,
  Keypair,
  clusterApiUrl,
  PublicKey,
  Transaction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import {
  createMint,
  getOrCreateAssociatedTokenAccount,
  mintTo,
} from "@solana/spl-token";
import { createCreateMetadataAccountV3Instruction } from "@metaplex-foundation/mpl-token-metadata";
import fs from "fs/promises"; // Use promises for async reading

async function fetchTreasuryPublicWalletAddress() {
  try {
    const response = await fetch("https://us-central1-token-mint-8f0e3.cloudfunctions.net/fetchTreasuryPublicWalletAddress");
    const data = await response.json();
    return data.treasuryWalletAddress;
  } catch (error) {
    console.error("Error fetching treasury wallet address:", error);
    throw new Error("Failed to fetch treasury wallet address");
  }
}

async function mintToken(nameOfToken, symbol, metadataUri, totalNumTokens, userPublicWalletAddress) {
  try {
    const connection = new Connection(clusterApiUrl("devnet"), "confirmed");
    console.log("Connected to Devnet");

    const secretKey = await fs.readFile("asdf", "utf8");
    const creatorKeypair = Keypair.fromSecretKey(Uint8Array.from(JSON.parse(secretKey)));

    const treasuryWalletAddress = await fetchTreasuryPublicWalletAddress();
    const treasuryPublicKey = new PublicKey(treasuryWalletAddress);
    const userPublicKey = new PublicKey(userPublicWalletAddress);

    const decimals = 7;
    const tokenMint = await createMint(connection, creatorKeypair, creatorKeypair.publicKey, null, decimals);
    console.log("Token Mint Address:", tokenMint.toBase58());

    const userTokenAccount = await getOrCreateAssociatedTokenAccount(connection, creatorKeypair, tokenMint, userPublicKey);
    const treasuryTokenAccount = await getOrCreateAssociatedTokenAccount(connection, creatorKeypair, tokenMint, treasuryPublicKey);

    const treasuryShare = Math.floor(totalNumTokens * 0.02 * 10 ** decimals);
    const userShare = Math.floor(totalNumTokens * 0.98 * 10 ** decimals);

    await mintTo(connection, creatorKeypair, tokenMint, treasuryTokenAccount.address, creatorKeypair, treasuryShare);
    console.log("Minted 2% of tokens to the treasury wallet");

    await mintTo(connection, creatorKeypair, tokenMint, userTokenAccount.address, creatorKeypair, userShare);
    console.log("Minted 98% of tokens to the user's wallet");

    const TOKEN_METADATA_PROGRAM_ID = new PublicKey("metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s");
    const [metadataPDA] = PublicKey.findProgramAddressSync(
      [Buffer.from("metadata"), TOKEN_METADATA_PROGRAM_ID.toBuffer(), tokenMint.toBuffer()],
      TOKEN_METADATA_PROGRAM_ID
    );

    const metadataData = {
      name: nameOfToken,
      symbol: symbol,
      uri: metadataUri,
      sellerFeeBasisPoints: 0,
      creators: null,
      collection: null,
      uses: null,
    };

    const transaction = new Transaction();
    const createMetadataAccountInstruction = createCreateMetadataAccountV3Instruction(
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
    await sendAndConfirmTransaction(connection, transaction, [creatorKeypair]);

    console.log("Metadata added");

    console.log("\nToken Creation Summary:");
    console.log("User Wallet Address:", userPublicWalletAddress);
    console.log("Treasury Wallet Address:", treasuryWalletAddress);
    console.log("Token Mint Address:", tokenMint.toBase58());
  } catch (error) {
    console.error("Error:", error);
  }
}
