async function connectMetaMask() {
  try {
    if (typeof window.ethereum === 'undefined') {
      console.error("MetaMask not available.");
      return "MetaMask unavailable";
    }

    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const address = accounts[0];
    console.log("MetaMask connected, address:", address);
    return address;
  } catch (error) {
    console.error("Error connecting to MetaMask:", error);
    return "MetaMask unavailable";
  }
}

async function disconnectMetaMask() {
  try {
    // MetaMask doesn't have a standard disconnect method.
    //  The user has to disconnect manually in the MetaMask UI.
    //  We can clear the session, but MetaMask may still show as connected.
    console.warn("MetaMask doesn't support programmatic disconnection.");
    return "wallet disconnected"; // Consistent return
  } catch (error) {
    console.error("Error disconnecting from MetaMask:", error);
    return "MetaMask unavailable";
  }
}
