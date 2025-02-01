async function connectPhantom() {
    //console.log("connectPhantom()");

    if (!window.solana) {
        console.error("Phantom Wallet not installed.");
        return null;
    }

    try {
        // Connect to Phantom
        const resp = await window.solana.connect();
        const publicKey = resp.publicKey.toString();
        console.log("Connected to Phantom:", publicKey);

        // Request user to sign a message for authentication
        const message = "Sign this message to complete login to Phantom Wallet.";
        const encodedMessage = new TextEncoder().encode(message);

        const signedMessage = await window.solana.signMessage(encodedMessage, "utf8");
        console.log("User signed the message:", signedMessage);

        return { publicKey, signedMessage };
    } catch (err) {
        console.error("Connection or signing failed:", err);
        return "Connection or signing failed. Please try again.";
    }
}
