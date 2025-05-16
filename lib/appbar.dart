import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import 'dart:js_util' as js_util;
import 'dart:html' as html;
//import 'package:solana_web3/solana_web3.dart'; // Import Solana types
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return AppBar(
      backgroundColor: Colors.tealAccent,
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'MOONROCKET',
              style: const TextStyle(
                fontFamily: 'SourceCodePro',
                fontSize: 20.0, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
        ),
      ),
      actions: [
        if (isLoggedIn)
          _buildLoggedInActions(context, authProvider)
        else
          _buildLoggedOutAction(context, authProvider),
      ],
    );
  }

  Widget _buildLoggedInActions(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'mint_token',
            child: Text('Mint Token'),
          ),
          const PopupMenuItem<String>(
            value: 'my_projects',
            child: Text('My Projects'),
          ),
          const PopupMenuItem<String>(
            value: 'settings',
            child: Text('Settings'),
          ),
          PopupMenuItem<String>(
            value: 'disconnect_wallet',
            child: Text('Disconnect Wallet'),
          ),
        ];
      },
      onSelected: (String value) {
        switch (value) {
          case 'mint_token':
            context.go('/mint_token');
            break;
          case 'my_projects':
            context.go('/my_projects');
            break;
          case 'settings':
            context.go('/settings');
            break;
          case 'disconnect_wallet':
            disconnectWallet(authProvider);
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 8),
            Text(
              _truncateWalletAddress(authProvider.walletAddress),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void disconnectWallet(AuthProvider authProvider) async {
    try {
      final result = await js_util.promiseToFuture(
        js_util.callMethod(html.window, 'disconnectSolflare', []),
      );
      if (result is Map && result.containsKey('error')) {
        // Handle error
        print("Disconnect error: ${result['error']}");
        // Show error message to the user if necessary
        return;
      }
      authProvider.logout();
    } catch (e) {
      print("Error disconnecting wallet: $e");
      //  firestoreLogger(e.toString(), 'disconnectWallet()'); // Removed firestore_functions
      // Show error message to the user
    }
  }

  Widget _buildLoggedOutAction(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          try {
            final result = await js_util.promiseToFuture(
              js_util.callMethod(html.window, 'connectSolflare', []),
            );

            if (result.toString() == 'Solflare unavailable') {
              // Handle error from JavaScript
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solflare wallet unavailable. Please make sure to install Solflare browser extension.'),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
            else {
              // Access the publicKey from the result.
              //TODO: write to db if necessary
              authProvider.login(result.toString());
            }

          } catch (e) {
            print("Error connecting to Solflare: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Solflare wallet unavailable. Please make sure to install Solflare browser extension.'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: ClipRRect( // Wrap the SvgPicture with ClipRRect
          borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
          child: Image.asset(
            'assets/Solflare_INSIGNIA_Obsidian_Noir.png',
            width: 48,
            height: 48,
          ),
        ),
      ),
    );
  }

  String _truncateWalletAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}

//  For sending Transaction
// Future<dynamic> sendSolanaTransaction(Transaction transaction) async {
//   try {
//     // Convert the Transaction object to a JavaScript object.
//     final jsTransaction = js_util.jsify(transaction.toJson());
//
//     // Call the JavaScript function and await the result.
//     final result = await js_util.promiseToFuture(
//       js_util.callMethod(html.window, 'signAndSendTransactionSolflare', [jsTransaction]),
//     );
//
//     if (result is Map && result.containsKey('error')) {
//       print("Error sending transaction: ${result['error']}");
//       throw Exception(result['error']); // Throw an exception to be caught in Dart
//     }
//     //  Access signature
//     final signature = result['signature'];
//     return signature;
//   } catch (e) {
//     print("Error in sendSolanaTransaction: $e");
//     throw e;
//   }
// }

// For signing transaction
// Future<Transaction?> signSolanaTransaction(Transaction transaction) async {
//   try {
//     // Convert the Transaction object to a JavaScript object.
//     final jsTransaction = js_util.jsify(transaction.toJson());
//
//     // Call the JavaScript function and await the result.
//     final result = await js_util.promiseToFuture<dynamic>(
//       js_util.callMethod(html.window, 'signTransactionSolflare', [jsTransaction]),
//     );
//
//     if (result is Map && result.containsKey('error')) {
//       print("Error signing transaction: ${result['error']}");
//       throw Exception(result['error']); // Throw for Dart
//     }
//
//     // Convert the result back to a Transaction object.  Adapt this based on the actual structure.
//     final signedTransaction = result['signedTransaction'];
//     if (signedTransaction == null) {
//       return null;
//     }
//     //  This part depends on the structure of the signedTransaction object
//     //  You'll need to adapt it based on the actual properties returned from JavaScript.
//     final signature = signedTransaction['signature'];
//
//     final transactionSignature =
//     TransactionSignature(signature: signature);
//
//     // Create a new Transaction object.  This is a placeholder.
//     final signedSolanaTransaction = Transaction(
//       signatures: [transactionSignature],
//       instructions: transaction.instructions,
//       feePayer: transaction.feePayer,
//     );
//
//     return signedSolanaTransaction;
//   } catch (e) {
//     print("Error signing transaction: $e");
//     throw e;
//   }
// }

//  For signing Message
// Future<Uint8List?> signSolanaMessage(Uint8List message) async {
//   try {
//     // Call the JavaScript function and await the result.
//     final result = await js_util.promiseToFuture(
//       js_util.callMethod(html.window, 'signMessageSolflare', [message]),
//     );
//
//     if (result is Map && result.containsKey('error')) {
//       print("Error signing message: ${result['error']}");
//       throw Exception(result['error']); // Throw for Dart
//     }
//     final signedMessageArray = result['signedMessage'];
//     if (signedMessageArray == null) {
//       return null;
//     }
//
//     // Convert the JavaScript array back to Uint8List.
//     final signedMessage = Uint8List.fromList(signedMessageArray.cast<int>());
//     return signedMessage;
//   } catch (e) {
//     print("Error signing message: $e");
//     throw e;
//   }
// }
//