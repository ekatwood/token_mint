import 'dart:js_util' as js_util;
import 'dart:html' as html;

Future<String> connectPhantom() async {
  final result = await js_util.promiseToFuture<String>(
    js_util.callMethod(html.window, 'connectPhantom', []),
  );
  return result;
}