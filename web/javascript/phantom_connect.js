function isPhantomInstalled() {
  var m = window.solana && window.solana.isPhantom;
  console.log("isPhantomInstalled: " + m);
  return window.solana && window.solana.isPhantom;
}

async function connectPhantom() {
    try {
      const resp = await window.solana.connect();
      return resp.publicKey.toString(); // Returns the wallet's public key
    } catch (err) {
      //console.error("Connection failed:", err);
      return "Install Phantom browser extension.";
    }
  }
}
