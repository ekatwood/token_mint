import 'dart:convert';
import 'dart:typed_data';
import 'firestore_functions.dart';
import 'package:http/http.dart' as http;

Future<bool> checkImageSafety(Uint8List imageBytes) async {

  // Convert image bytes to a base64 string
  String base64Image = base64Encode(imageBytes);

  // Send to Cloud Function
  final response = await http.post(
    Uri.parse('https://us-central1-token-mint-8f0e3.cloudfunctions.net/analyzeImage'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'image': base64Image}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final safeSearch = data["safeSearchAnnotation"];

    if (safeSearch == null) {
      print("No safe search annotation found");
      return false; // Unable to verify safety
    }

    List<String> unsafeCategories = ["adult", "violence", "medical", "racy"];

    for (var category in unsafeCategories) {
      String likelihood = safeSearch[category];
      //print(category + ": " + likelihood);
      if (["LIKELY", "VERY_LIKELY", "POSSIBLE", "UNKNOWN"].contains(likelihood)) {
        return false; // Image is inappropriate
      }
    }
    return true; // Image is safe
  } else {
    errorLogger(response.statusCode.toString() + '\n' + response.body, 'checkImageSafety(Uint8List imageBytes)');
    return false; // Assume unsafe if there's an error
  }
}
