import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:token_mint/phantom_ghost_button.dart';
import 'package:token_mint/settings.dart';
import 'package:token_mint/upload_to_Arweave.dart';
import 'phantom_wallet.dart';
import 'create_token.dart';
import 'firestore_functions.dart';
import 'firebase_options.dart';
import 'safesearch_api.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TokenMint());
}

class TokenMint extends StatelessWidget {
  const TokenMint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'token-mint',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const TokenFeed(),
    );
  }
}
