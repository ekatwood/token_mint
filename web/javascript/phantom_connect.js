async function connectPhantom () {
    //console.log("connectPhantom()");

    if (!window.solana) {
        console.error("Error connecting Phantom Wallet.");
        return null;
    }

    try {
        // Connect to Phantom
        const resp = await window.solana.connect();
        const publicKey = resp.publicKey.toString();
        console.log("Connected to Phantom:");
        console.log(publicKey);

        return publicKey;
    } catch (err) {
        console.error("Connection or signing failed:", err);
        return null;
    }
}