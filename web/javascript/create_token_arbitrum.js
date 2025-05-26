// create_token.js

// Ensure ethers is globally available from the CDN script in index.html
const ethers = window.ethers;

// Arbitrum One Chain ID (in hexadecimal)
const ARBITRUM_CHAIN_ID = '0xa4b1'; // 42161 in decimal

// Arbitrum Treasury Address (Placeholder - replace with your actual Arbitrum treasury address)
// This should be an Ethereum-style address (0x...).
const ARBITRUM_TREASURY_ADDRESS = "0xYourArbitrumTreasuryAddressHere"; // REPLACE THIS!

// --- PLACEHOLDER ERC-20 CONTRACT ABI AND BYTECODE ---
// YOU MUST REPLACE THESE WITH THE ACTUAL ABI AND BYTECODE OF YOUR COMPILED SOLIDITY CONTRACT.
// Your contract's constructor MUST accept parameters for name, symbol, decimals,
// initialSupplyUser, initialSupplyTreasury, userAddress, treasuryAddress, and tokenUri.
const ERC20_ABI = [
  // Minimal ABI for a constructor that takes name, symbol, decimals, initialSupplyUser, initialSupplyTreasury, userAddress, treasuryAddress, tokenUri
  "constructor(string name_, string symbol_, uint8 decimals_, uint256 initialSupplyUser, uint256 initialSupplyTreasury, address userAddress, address treasuryAddress, string _tokenUri)",
  // Add other functions if your token has them (e.g., name(), symbol(), decimals(), totalSupply(), balanceOf(address), transfer(address,uint256))
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
  "function totalSupply() view returns (uint256)",
  "function balanceOf(address account) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)",
  "function tokenUri() view returns (string)", // If your contract has a public tokenUri variable
];

// This is a placeholder. You MUST replace this with the actual bytecode of your compiled contract.
// Example: "0x6080604052..." (this is just a dummy string)
const ERC20_BYTECODE = "0x6080604052..."; // REPLACE THIS WITH YOUR ACTUAL BYTECODE!


/**
 * Helper function to upload a Blob to Arweave via Turbo SDK and handle ETH payment on Arbitrum.
 * This will trigger a MetaMask wallet confirmation for the ETH payment.
 * @param {Blob} blob - The Blob to upload.
 * @param {string} userPublicWalletAddress - The user's Ethereum public wallet address (needed for signer).
 * @returns {Promise<string>} The Arweave URI of the uploaded blob.
 * @throws {Error} If wallet is not connected, payment fails, or upload fails.
 */
async function uploadBlobToArweave(blob, userPublicWalletAddress) {
    // Ensure turbo-sdk is imported within the function scope or globally if not already.
    const turbo = await import('https://cdn.jsdelivr.net/npm/@ardrive/turbo-sdk@latest');

    // Initialize Turbo SDK
    const turboClient = new turbo.TurboClient();

    // Estimate gas fee
    const byteSize = blob.size;
    // Fetch price for ETH payments
    const estimatedFeeResponse = await fetch(`https://payment.ardrive.io/v1/price/bytes/${byteSize}?currency=eth`)
        .then(res => res.json());

    // The estimatedFeeResponse will contain the price in 'winc' (Winston Credits)
    // For ETH, the `winc` value represents the amount of ETH in its smallest unit (wei).
    const estimatedEthWei = estimatedFeeResponse.winc; // This should be in wei

    // Ensure MetaMask is available and connected
    if (typeof window.ethereum === 'undefined' || !window.ethereum.selectedAddress) {
      throw new Error("MetaMask wallet is not connected.");
    }

    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const turboPaymentAddress = turboClient.getPaymentAddress(); // This is the ArDrive payment address

    // THIS IS A SEPARATE ETHEREUM TRANSACTION FOR ARWEAVE PAYMENT
    console.log("Prompting user for Arweave payment transaction (ETH)...");
    let transactionResponse;
    try {
        // Create a transaction object for ethers.js
        const tx = {
            to: turboPaymentAddress,
            value: estimatedEthWei, // Amount in wei
        };

        // Send the transaction using ethers.js signer
        transactionResponse = await signer.sendTransaction(tx);
        console.log("Arweave ETH payment transaction sent. Hash:", transactionResponse.hash);
    } catch (paymentError) {
        console.error("Arweave ETH payment transaction failed:", paymentError);
        // Handle user rejection (error code 4001) specifically
        if (paymentError.code === 4001) {
            throw new Error("MetaMask: User rejected Arweave payment transaction.");
        }
        throw new Error(`Arweave payment failed: ${paymentError.message || paymentError}`);
    }

    // Wait for confirmation of the payment transaction on the Ethereum chain
    console.log("Waiting for Arweave ETH payment confirmation...");
    await provider.waitForTransaction(transactionResponse.hash);
    console.log("Arweave ETH payment confirmed.");

    // Upload file to Arweave
    console.log("Uploading blob to Arweave...");
    let uploadResult = await turboClient.uploadBlob(blob, {
        tags: [{ name: "Content-Type", value: blob.type }]
    });
    console.log("Blob uploaded to Arweave. ID:", uploadResult.id);

    return `https://arweave.net/${uploadResult.id}`;
}


/**
 * Mints an ERC-20 token on Arbitrum One by deploying a Solidity contract,
 * sets its metadata, and distributes tokens to user and treasury.
 * This function handles uploading the logo and metadata JSON to Arweave,
 * and then deploys the ERC-20 contract.
 *
 * @param {Uint8Array} logoBytes - The bytes of the token logo image.
 * @param {string} fileExtension - The file extension of the logo (e.g., "png", "jpg").
 * @param {string} nameOfToken - The full name of the token (e.g., "My Awesome Token").
 * @param {string} symbol - The token symbol (e.g., "MAT").
 * @param {string | undefined} description - Optional: A description for the token.
 * @param {string[] | undefined} websites - Optional: An array of website URLs for the token.
 * @param {number} totalNumTokens - The total number of tokens to mint (e.g., 1000000000 for 1B).
 * @param {string} userPublicWalletAddress - The public key of the user's connected MetaMask wallet (payer and contract deployer).
 * @returns {Promise<string>} The address of the deployed ERC-20 token contract.
 * @throws {Error} If any step (wallet connection, Arweave upload, contract deployment) fails.
 */
async function mintTokenArbitrum(
  logoBytes,
  fileExtension,
  nameOfToken,
  symbol,
  description,
  websites,
  totalNumTokens,
  userPublicWalletAddress // This will be the Ethereum address
) {
  try {
    // Ensure MetaMask is connected and on Arbitrum (handled by connectMetaMask before this call)
    if (typeof window.ethereum === 'undefined' || !window.ethereum.selectedAddress) {
      throw new Error("MetaMask wallet is not connected or not on Arbitrum.");
    }

    // Check if the current network is Arbitrum One
    const currentChainId = await window.ethereum.request({ method: 'eth_chainId' });
    if (currentChainId !== ARBITRUM_CHAIN_ID) {
      throw new Error("MetaMask is not on the Arbitrum One network. Please switch or add it.");
    }

    // Get the provider and signer from MetaMask
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    console.log("Ethers.js signer obtained:", signer.address);

    // --- Arweave Uploads (paid with ETH on Arbitrum) ---
    console.log("Starting Arweave uploads (paid with ETH on Arbitrum)...");

    // 1. Upload Logo to Arweave
    const logoBlob = new Blob([logoBytes], { type: `image/${fileExtension}` });
    const logoUri = await uploadBlobToArweave(logoBlob, userPublicWalletAddress); // This triggers an ETH payment prompt
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
    const metadataUri = await uploadBlobToArweave(metadataBlob, userPublicWalletAddress); // This triggers another ETH payment prompt
    console.log("Metadata JSON uploaded to Arweave:", metadataUri);

    // --- ERC-20 Contract Deployment ---
    console.log("Starting ERC-20 contract deployment on Arbitrum...");

    const decimals = 18; // Standard for most ERC-20 tokens, ensure your Solidity contract matches

    // Calculate initial supplies for user and treasury based on decimals
    const initialSupplyUser = ethers.parseUnits(String(Math.floor(totalNumTokens * 0.98)), decimals);
    const initialSupplyTreasury = ethers.parseUnits(String(Math.floor(totalNumTokens * 0.02)), decimals);

    // Create a ContractFactory using the ABI and Bytecode
    const factory = new ethers.ContractFactory(ERC20_ABI, ERC20_BYTECODE, signer);
    console.log("ContractFactory created.");

    // Deploy the contract
    // The constructor arguments must match your Solidity contract's constructor signature exactly.
    console.log("Deploying ERC-20 contract. This will prompt MetaMask for confirmation...");
    const contract = await factory.deploy(
      nameOfToken,
      symbol,
      decimals,
      initialSupplyUser,
      initialSupplyTreasury,
      userPublicWalletAddress, // User's address
      ARBITRUM_TREASURY_ADDRESS, // Treasury address
      metadataUri // Arweave metadata URI
    );
    console.log("Contract deployment transaction sent. Hash:", contract.deploymentTransaction().hash);

    // Wait for the contract to be deployed and confirmed
    await contract.waitForDeployment();
    const contractAddress = await contract.getAddress();
    console.log("ERC-20 Contract deployed to address:", contractAddress);

    console.log("\nToken Creation Summary (Arbitrum):");
    console.log("User Wallet Address:", userPublicWalletAddress);
    console.log("Treasury Wallet Address:", ARBITRUM_TREASURY_ADDRESS);
    console.log("ERC-20 Token Contract Address:", contractAddress);
    console.log("Deployment Transaction Hash:", contract.deploymentTransaction().hash);

    return contractAddress; // Return the deployed contract address
  } catch (error) {
    console.error("Error in mintTokenArbitrum:", error);
    // Handle user rejection (error code 4001) specifically for MetaMask
    if (error.code === 4001) {
      throw new Error("MetaMask: User rejected transaction.");
    }
    throw error; // Re-throw other errors
  }
}

// Make the function globally accessible
window.mintTokenArbitrum = mintTokenArbitrum;
