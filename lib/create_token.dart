import 'dart:js_util' as js_util;
import 'firestore_functions.dart';
import 'dart:html' as html;

Future<String> mintToken(String name, String symbol, String logoUrl, int supply, String wallet) async {
  try{
    final result = await js_util.promiseToFuture<String>(
      js_util.callMethod(html.window, 'mintToken', [name, symbol, logoUrl, supply, wallet]),
    );
    return result;
  }
  catch(e){
    errorLogger(e.toString(), 'mintToken() in create_token.dart');
    return 'error';
  }
}