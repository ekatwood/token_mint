// create_token.js

import {
  Connection,
  Keypair,
  clusterApiUrl,
  PublicKey,
  Transaction,
  sendAndConfirmTransaction, // Still useful for getOrCreateAssociatedTokenAccount if it does its own internal transactions
} from "@solana/web3.js";
import {
  createMint,
  getOrCreateAssociatedTokenAccount,
  mintTo,
  TOKEN_PROGRAM_ID,
} from "@solana/spl-token";
import {
  createCreateMetadataAccountV3Instruction,
  PROGRAM_ID as TOKEN_METADATA_PROGRAM_ID,
} from "@metaplex-foundation/mpl-token-metadata";

// Helper to fetch treasury address (remains the same)
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

/**
 * Helper function to upload a Blob to Arweave via Turbo SDK and handle SOL payment.
 * This will trigger a wallet confirmation for the SOL payment.
 * @param {Blob} blob - The Blob to upload.
 * @returns {Promise<string>} The Arweave URI of the uploaded blob.
 * @throws {Error} If wallet is not connected, payment fails, or upload fails.
 */
async function uploadBlobToArweave(blob) {
    // Ensure turbo-sdk is imported within the function scope or globally if not already.
    // Using dynamic import here for robustness, assuming it's loaded via CDN in index.html
    const turbo = await import('https://cdn.jsdelivr.net/npm/@ardrive/turbo-sdk@latest');

    // Initialize Turbo SDK
    const turboClient = new turbo.TurboClient();

    // Estimate gas fee
    const byteSize = blob.size;
    const estimatedFee = await fetch(`https://payment.ardrive.io/v1/price/bytes/${byteSize}`)
        .then(res => res.json());

    // Ask user to pay with SOL via connected wallet (window.solana)
    // THIS IS A SEPARATE SOLANA TRANSACTION FOR ARWEAVE PAYMENT
    console.log("Prompting user for Arweave payment transaction...");
    let transactionSignature;
    try {
        const paymentTransaction = {
            to: turboClient.getPaymentAddress(),
            amount: estimatedFee.winc // amount in lamports (winc is usually lamports)
        };
        transactionSignature = await window.solana.signAndSendTransaction(paymentTransaction);
        console.log("Arweave payment transaction sent. Signature:", transactionSignature.signature);
    } catch (paymentError) {
        console.error("Arweave payment transaction failed:", paymentError);
        throw new Error(`Arweave payment failed: ${paymentError.message || paymentError}`);
    }


    // Wait for confirmation of the payment transaction
    console.log("Waiting for Arweave payment confirmation...");
    await turboClient.waitForConfirmation(transactionSignature.signature);
    console.log("Arweave payment confirmed.");

    // Upload file to Arweave
    console.log("Uploading blob to Arweave...");
    let uploadResult = await turboClient.uploadBlob(blob, {
        tags: [{ name: "Content-Type", value: blob.type }]
    });
    console.log("Blob uploaded to Arweave. ID:", uploadResult.id);

    return `https://arweave.net/${uploadResult.id}`;
}


/**
 * Mints an SPL token on Solana, sets its metadata, and distributes tokens to user and treasury.
 * This function also handles uploading the logo and metadata JSON to Arweave.
 *
 * @param {Uint8Array} logoBytes - The bytes of the token logo image.
 * @param {string} fileExtension - The file extension of the logo (e.g., "png", "jpg").
 * @param {string} nameOfToken - The full name of the token (e.g., "My Awesome Token").
 * @param {string} symbol - The token symbol (e.g., "MAT").
 * @param {string | undefined} description - Optional: A description for the token.
 * @param {string[] | undefined} websites - Optional: An array of website URLs for the token.
 * @param {number} totalNumTokens - The total number of tokens to mint (e.g., 1000000000 for 1B).
 * @param {string} userPublicWalletAddress - The public key of the user's connected wallet (payer and mint authority).
 * @returns {Promise<string>} The signature of the successful Solana transaction.
 * @throws {Error} If any step (wallet connection, Arweave upload, Solana transaction) fails.
 */
async function mintTokenSolana(
  logoBytes,       // New parameter
  fileExtension,   // New parameter
  nameOfToken,
  symbol,
  description,
  websites,
  totalNumTokens,
  userPublicWalletAddress
) {
  try {
    // Ensure window.solana is available for signing
    if (!window.solana || !window.solana.isConnected) {
      throw new Error("Solana wallet (e.g., Phantom/Solflare/MetaMask with Snap) is not connected.");
    }

    const connection = new Connection(clusterApiUrl("devnet"), "confirmed"); // Use 'mainnet-beta' for production
    console.log("Connected to Devnet");

    const userPublicKey = new PublicKey(userPublicWalletAddress);
    const treasuryWalletAddress = await fetchTreasuryPublicWalletAddress();
    const treasuryPublicKey = new PublicKey(treasuryWalletAddress);

    // this ensures no more tokens can be minted after the initial mint, and no token accounts can be frozen
    const mintAuthority = null;
    const freezeAuthority = null;

    const decimals = 9;

    // --- Arweave Uploads ---
    console.log("Starting Arweave uploads...");

    // 1. Upload Logo to Arweave
    const logoBlob = new Blob([logoBytes], { type: `image/${fileExtension}` });
    const logoUri = await uploadBlobToArweave(logoBlob);
    console.log("Logo uploaded to Arweave:", logoUri);

    // 2. Prepare and Upload Metadata JSON to Arweave
    const metadataJson = {
      name: nameOfToken,
      symbol: symbol,
      image: logoUri, // Image URI from the logo upload
      description: description || undefined, // Optional description
      properties: {
        files: [{ uri: logoUri, type: `image/${fileExtension}` }],
        category: "token",
        websites: websites && websites.length > 0 ? websites : undefined, // Optional websites
      },
    };
    const metadataBlob = new Blob([JSON.stringify(metadataJson)], { type: "application/json" });
    const metadataUri = await uploadBlobToArweave(metadataBlob);
    console.log("Metadata JSON uploaded to Arweave:", metadataUri);

    // --- Solana Token Minting and Metadata Creation ---
    console.log("Starting Solana token minting and metadata creation...");

    const mintKeypair = Keypair.generate();

    // 1. Create Mint Account Instruction
    const createMintInstruction = await createMint(
      connection,
      userPublicKey,
      mintAuthority,
      freezeAuthority,
      decimals,
      mintKeypair
    );
    console.log("Prepared Create Mint Account Instruction.");

    // 2. Get or Create Associated Token Accounts (ATAs) for user and treasury
    // These functions might send their own transactions if the ATA doesn't exist.
    const userTokenAccount = await getOrCreateAssociatedTokenAccount(
      connection,
      userPublicKey,
      mintKeypair.publicKey,
      userPublicKey
    );
    console.log("Got or created user's Associated Token Account.");

    const treasuryTokenAccount = await getOrCreateAssociatedTokenAccount(
      connection,
      userPublicKey,
      mintKeypair.publicKey,
      treasuryPublicKey
    );
    console.log("Got or created treasury's Associated Token Account.");

    // 3. Mint Tokens Instructions
    const treasuryShare = Math.floor(totalNumTokens * 0.03 * (10 ** decimals));
    const userShare = Math.floor(totalNumTokens * 0.97 * (10 ** decimals));

    const mintToTreasuryInstruction = mintTo(
      connection,
      userPublicKey,
      mintKeypair.publicKey,
      treasuryTokenAccount.address,
      mintAuthority,
      treasuryShare,
      [userPublicKey]
    );
    console.log(`Prepared instruction to mint ${treasuryShare / (10**decimals)} tokens to treasury.`);

    const mintToUserInstruction = mintTo(
      connection,
      userPublicKey,
      mintKeypair.publicKey,
      userTokenAccount.address,
      mintAuthority,
      userShare,
      [userPublicKey]
    );
    console.log(`Prepared instruction to mint ${userShare / (10**decimals)} tokens to user.`);

    // 4. Create Metadata Instruction (Metaplex)
    const metadataData = {
      name: nameOfToken,
      symbol: symbol,
      uri: metadataUri, // Use the Arweave URI for the metadata JSON
      sellerFeeBasisPoints: 0,
      creators: [{
        address: userPublicKey.toBase58(),
        share: 100,
        verified: true,
      }],
      collection: null,
      uses: null,
      properties: {
        files: [{ uri: logoUri, type: `image/${fileExtension}` }], // Reference the logo URI
        category: "token",
        description: description || undefined,
        websites: websites && websites.length > 0 ? websites : undefined,
      },
    };

    const [metadataPDA] = PublicKey.findProgramAddressSync(
      [Buffer.from("metadata"), TOKEN_METADATA_PROGRAM_ID.toBuffer(), mintKeypair.publicKey.toBuffer()],
      TOKEN_METADATA_PROGRAM_ID
    );
    console.log("Metadata PDA:", metadataPDA.toBase58());

    const createMetadataAccountInstruction = createCreateMetadataAccountV3Instruction(
      {
        metadata: metadataPDA,
        mint: mintKeypair.publicKey,
        mintAuthority: mintAuthority,
        payer: userPublicKey,
        updateAuthority: mintAuthority,
      },
      {
        createMetadataAccountArgsV3: {
          collectionDetails: null,
          data: metadataData,
          isMutable: true,
        },
      }
    );
    console.log("Prepared Create Metadata Account Instruction.");

    // 5. Assemble all Solana instructions into a single transaction
    const transaction = new Transaction();
    transaction.add(
      createMintInstruction,
      mintToTreasuryInstruction,
      mintToUserInstruction,
      createMetadataAccountInstruction
    );
    console.log("All Solana instructions added to a single transaction.");

    transaction.feePayer = userPublicKey;
    const { blockhash } = await connection.getLatestBlockhash();
    transaction.recentBlockhash = blockhash;
    console.log("Solana transaction recent blockhash set.");

    // Sign the Solana transaction using the connected wallet (window.solana)
    // THIS IS THE THIRD (OR MORE) WALLET PROMPT FOR THE USER
    console.log("Prompting user to sign Solana token minting transaction...");
    const signedTransaction = await window.solana.signTransaction(transaction);
    console.log("Solana transaction signed by user's wallet.");

    // Send the signed Solana transaction to the network
    const signature = await connection.sendRawTransaction(signedTransaction.serialize());
    console.log("Solana transaction sent. Signature:", signature);

    // Confirm the Solana transaction
    await connection.confirmTransaction(signature, 'confirmed');
    console.log("Solana transaction confirmed.");

    console.log("\nToken Creation Summary:");
    console.log("User Wallet Address:", userPublicWalletAddress);
    console.log("Treasury Wallet Address:", treasuryWalletAddress);
    console.log("Token Mint Address:", mintKeypair.publicKey.toBase58());
    console.log("Transaction Signature:", signature);

    return signature;
  } catch (error) {
    console.error("Error in mintTokenSolana:", error);
    throw error;
  }
}

// Make the function globally accessible
window.mintTokenSolana = mintTokenSolana;
