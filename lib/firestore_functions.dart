import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html';

void errorLogger(String errorMessage, String context) {
  //get browser type
  String userAgent = window.navigator.userAgent.toLowerCase();
  String browser;

  if (userAgent.contains('chrome') && !userAgent.contains('edg')) {
    browser = 'Chrome';
  } else if (userAgent.contains('safari') && !userAgent.contains('chrome')) {
    browser = 'Safari';
  } else if (userAgent.contains('firefox')) {
    browser = 'Firefox';
  } else if (userAgent.contains('edg')) {
    browser = 'Edge';
  } else if (userAgent.contains('opera') || userAgent.contains('opr')) {
    browser = 'Opera';
  } else {
    browser = 'Unknown Browser';
  }

  userAgent = window.navigator.userAgent.toLowerCase();
  String device;

  if (userAgent.contains('mobi')) {
    device = 'Mobile';
  } else if (userAgent.contains('tablet')) {
    device = 'Tablet';
  } else {
    device = 'Desktop';
  }

  // log the error
  FirebaseFirestore.instance.collection('error_log').add({
    'context': context,
    'errorMessage': errorMessage,
    'browser': browser,
    'device': device,
    'timestamp': FieldValue.serverTimestamp(),
  }).catchError((error) => print("Failed to log error: $error"));
}

void phantomWalletConnected(String wallet_address) {

  //add the public wallet address to the database, if it's not already there
  FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(wallet_address) // Use wallet address as document ID
      .set({})
      .then((_) => print("Wallet address added successfully"))
      .catchError((error) => errorLogger("Failed to add wallet address: $error",'phantomWalletConnected(String wallet_address)'));
}

void addMintedToken(String wallet_address, String token_mint_address, String name, String symbol, String image, String type, int numTokens) {
  FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(wallet_address)
      .collection('tokens')
      .doc(token_mint_address)
      .set({
    "name": name,
    "symbol": symbol,
    "image": image,
    "numTokens": numTokens,
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
      .catchError((error) => errorLogger("Error saving token metadata to database: $error", 'addMintedToken(String wallet_address, String token_mint_address, String name, String symbol, String image, String type, int numTokens)'));
}