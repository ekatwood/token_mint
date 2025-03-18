async function connectPhantom() {
    //console.log("connectPhantom()");
    try{
        if (!window.solana) {
            //console.error("Error connecting Phantom Wallet.");
            return "error";
        }

        // Connect to Phantom
            const resp = await window.solana.connect();
            const publicKey = resp.publicKey.toString();

            return publicKey;
    }
    catch(err){
        console.log("error in connectPhantom phantom_connect.js: " + err.message);
        return 'error';
    }

async function openPhantomIfConnected() {
  if (!window.solana) {
    console.error("Phantom Wallet is not installed.");
    return "error";
  }

  try {
    // Attempt to connect to Phantom
    const resp = await window.solana.connect({ onlyIfTrusted: true });
    const publicKey = resp.publicKey.toString();
    // Open Phantom Wallet
    window.open('https://phantom.app/', '_blank');
    return publicKey;
  } catch (err) {
    console.error("User is not logged in or connection failed.");
    return "not_connected";
  }
}



}