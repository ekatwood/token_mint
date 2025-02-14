import 'package:cloud_firestore/cloud_firestore.dart';

void phantomWalletConnected(String wallet_address) {

  //add the public wallet address to the database, if it's not already there
  FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(wallet_address) // Use wallet address as document ID
      .set({})
      .then((_) => print("Wallet address added successfully"))
      .catchError((error) => print("Failed to add wallet address: $error"));
}

void addMintedToken(String wallet_address, String token_mint_address, String name, String symbol, String image, String type) {
  FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(wallet_address)
      .collection('tokens')
      .doc(token_mint_address)
      .set({
        "name": name,
        "symbol": symbol,
        "image": image,
        "properties": {
          "files": [
            {
              "uri": image,
              "type": type
            }
          ]
        }
      })
      .then((_) => print("Token metadata saved to database"))
      .catchError((error) => print("Error saving token metadata to database: $error"));
}