import 'package:js/js.dart';

@JS('connectPhantom')
external String? connectPhantom();

@JS('signTransaction')
external Future<String?> signTransaction(String fromPubkey, String toPubkey, int lamports);
