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

void solflareWalletConnected(String wallet_address) {

  //add the public wallet address to the database, if it's not already there
  FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(wallet_address) // Use wallet address as document ID
      .set({})
      .then((_) => print("Wallet address added successfully"))
      .catchError((error) => errorLogger("Failed to add wallet address: $error",'solflareWalletConnected(String wallet_address)'));
}

bool addMintedToken({
  required String walletAddress,
  required String tokenMintAddress,
  required String name,
  required String symbol,
  required String image,
  required String type,
  required int numTokens,
  required String description,
  required int numDecimals,
  required bool isMetadataMutable,
  required String externalURL
}) {
  if (name.length > 500) {
    print("Error: Token name exceeds the maximum character limit of 500.");
    return false;
  }
  if (symbol.length > 100) {
    print("Error: Token symbol exceeds the maximum character limit of 100.");
    return false;
  }
  if (numDecimals < 0 || numDecimals > 9) {
    print("Error: Number of decimals must be between 0 and 9.");
    return false;
  }

  FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(walletAddress)
      .collection('tokens')
      .doc(tokenMintAddress)
      .set({
    "name": name,
    "symbol": symbol,
    "image": image,
    "supply": numTokens,
    "description": description,
    "decimals": numDecimals,
    "is_mutable": isMetadataMutable,
    "external_url": externalURL,
    "like_count": 0,
    "dislike_count": 0,
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
      .catchError((error) => errorLogger("Error saving token metadata to database: $error", 'addMintedToken(String wallet_address, String token_mint_address, String name, String symbol, String image, String type, int numTokens, String description, int numDecimals, bool isMetadataMutable)'));

  return true;
}

Future<DocumentSnapshot?> getTokenDetails(String mintAddress) async {
  try {
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('tokens')
        .doc(mintAddress)
        .get();
    return documentSnapshot;
  } catch (error) {
    print("Error fetching token details for mint address: $mintAddress - $error");
    errorLogger("Error fetching token details for mint address: $mintAddress - $error",'getTokenDetails(String mintAddress)');
    return null;
  }
}

Future<Map<String, dynamic>?> getTokens(String walletAddress) async {
  try {
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('public_wallet_addresses')
        .doc(walletAddress)
        .get();

    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      return documentSnapshot.data() as Map<String, dynamic>?;
    } else {
      print("No data found for wallet address: $walletAddress");
      return null;
    }
  } catch (error) {
    print("Error fetching tokens for wallet address: $walletAddress - $error");
    errorLogger("Error fetching tokens for wallet address: $walletAddress - $error",'getTokens(String walletAddress)');
    return null;
  }
}

Future<void> incrementLikeCounter(
    String walletAddress,
    String mintAddress,
    List<String> likedProjects,
    List<String> dislikedProjects,
    bool like,
    bool dislike
    ) async {
  final DocumentReference tokenRef = FirebaseFirestore.instance
      .collection('public_wallet_addresses')
      .doc(walletAddress)
      .collection('tokens')
      .doc(mintAddress);

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(tokenRef);

      if (!snapshot.exists) {
        throw Exception("Token not found for wallet: $walletAddress and mint: $mintAddress");
      }

      int currentLikes = (snapshot.data() as Map<String, dynamic>?)?['likes'] ?? 0;
      int currentDislikes = (snapshot.data() as Map<String, dynamic>?)?['dislikes'] ?? 0;

      bool isCurrentlyLiked = likedProjects.contains(mintAddress);
      bool isCurrentlyDisliked = dislikedProjects.contains(mintAddress);

      Map<String, dynamic> updateData = {};

      // Determine the action based on the current state and the new like/dislike
      if (like && isCurrentlyLiked) {
        // User is unliking
        updateData['likes'] = currentLikes > 0 ? currentLikes - 1 : 0;
        print("Unliked token: $mintAddress in wallet: $walletAddress");
      } else if(like && !isCurrentlyLiked){
        // User is liking
        updateData['likes'] = currentLikes + 1;
        print("Liked token: $mintAddress in wallet: $walletAddress");
      }
      else if (dislike && isCurrentlyDisliked) {
        // User is undoing dislike
        updateData['dislikes'] = currentDislikes > 0 ? currentDislikes - 1 : 0;
        print("Undoing dislike for token: $mintAddress in wallet: $walletAddress");
      } else {
        // User is disliking
        updateData['dislikes'] = currentDislikes + 1;
        print("Disliked token: $mintAddress in wallet: $walletAddress");
      }

      transaction.update(tokenRef, updateData);
    });
  } catch (error) {
    print("Error updating like/dislike for token: $mintAddress in wallet: $walletAddress - $error");
    errorLogger("Error updating like/dislike for token: $mintAddress in wallet: $walletAddress - $error",'incrementLikeCounter(String walletAddress, String mintAddress, List<String> likedProjects, List<String> dislikedProjects, bool like, bool dislike)');
  }
}