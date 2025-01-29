import 'package:js/js.dart';

@JS('isPhantomInstalled')
external bool isPhantomInstalled();

@JS('connectPhantom')
external String? connectPhantom();

@JS('signTransaction')
external Future<String?> signTransaction(String fromPubkey, String toPubkey, int lamports);
