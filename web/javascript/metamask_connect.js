async function connectMetaMask() {
  try {
    if (typeof window.ethereum === 'undefined') {
      //console.error("MetaMask not available.");
      return "MetaMask unavailable";
    }

    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const address = accounts[0];
    //console.log("MetaMask connected, address:", address);
    return address;
  } catch (error) {
    //console.error("Error connecting to MetaMask:", error);
    return "MetaMask unavailable";
  }
}