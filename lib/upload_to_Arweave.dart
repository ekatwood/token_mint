import 'dart:convert';
import 'dart:typed_data';
import 'firestore_functions.dart';
import 'package:js/js.dart';
import 'package:web/web.dart';

@JS('uploadToArweaveJS') // JS function binding
external Future<String> uploadToArweaveJS(
    Uint8List logoBytes, String tokenName, String tokenSymbol, String fileExtension, String walletAddress);

Future<String> uploadToArweave(
    Uint8List logoBytes, String tokenName, String tokenSymbol, String fileExtension, String walletAddress) async {
  try {
    // Call JavaScript function (wrapped in a Dart Future)
    String arweaveUrl = await uploadToArweaveJS(logoBytes, tokenName, tokenSymbol, fileExtension, walletAddress);
    return arweaveUrl;
  } catch (e) {
    errorLogger(e.toString(), 'uploadToArweave() in upload_to_Arweave.dart');
    return 'error';
  }
}
