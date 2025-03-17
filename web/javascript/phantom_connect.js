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



}