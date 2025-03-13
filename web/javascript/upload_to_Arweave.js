async function uploadToArweaveJS(logoBytes, tokenName, tokenSymbol, fileExtension, walletAddress) {
    // Convert Uint8List to a Blob for Arweave upload
    let logoBlob = new Blob([logoBytes], { type: "image/" + fileExtension });

    // Upload logo to Arweave and get URI
    let logoUri = await uploadToArweave(logoBlob);

    // Prepare JSON metadata
    let metadata = {
        name: tokenName,
        symbol: tokenSymbol,
        image: logoUri
    };

    let metadataBlob = new Blob([JSON.stringify(metadata)], { type: "application/json" });

    // Upload metadata JSON to Arweave
    let metadataUri = await uploadToArweave(metadataBlob);

    return metadataUri;
}

async function uploadToArweave(blob) {
    const turbo = await import('https://cdn.jsdelivr.net/npm/@ardrive/turbo-sdk@latest');

    // Initialize Turbo SDK
    const turboClient = new turbo.TurboClient();

    // Estimate gas fee
    const byteSize = blob.size;
    const estimatedFee = await fetch(`https://payment.ardrive.io/v1/price/bytes/${byteSize}`)
        .then(res => res.json());

    // Ask user to pay with SOL via Phantom Wallet
    let transaction = await window.solana.signAndSendTransaction({
        to: turboClient.getPaymentAddress(),
        amount: estimatedFee.winc
    });

    // Wait for confirmation
    await turboClient.waitForConfirmation(transaction.signature);

    // Upload file to Arweave
    let uploadResult = await turboClient.uploadBlob(blob, {
        tags: [{ name: "Content-Type", value: blob.type }]
    });

    return `https://arweave.net/${uploadResult.id}`;
}
