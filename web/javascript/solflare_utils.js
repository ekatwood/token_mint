import Solflare from '../node_modules/@solflare-wallet/sdk';

const wallet = new Solflare();

window.solflareConnect = async () => {
    try {
        await wallet.connect();
        return wallet.publicKey.toString();
    } catch (error) {
        console.error("Solflare Connect Error:", error);
        throw error;
    }
};

window.solflareDisconnect = async () => {
    try {
        await wallet.disconnect();
    } catch (error) {
        console.error("Solflare Disconnect Error:", error);
        throw error;
    }
};

window.solflareIsConnected = async () => {
    try {
        return wallet.isConnected();
    } catch (error) {
        console.error("Solflare isConnected Error:", error);
        throw error;
    }
};