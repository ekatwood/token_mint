import 'dart:convert';
import 'dart:typed_data';
import 'firestore_functions.dart';
import 'package:http/http.dart' as http;

Future<bool> checkImageSafety(Uint8List imageBytes) async {
  const String apiKey = "TODO: load with Cloud function"; // Replace with your actual API key
  const String endpoint = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";

  // Convert image bytes to a base64 string
  String base64Image = base64Encode(imageBytes);

  final Map<String, dynamic> requestPayload = {
    "requests": [
      {
        "image": {"content": base64Image}, // Send image as bytes
        "features": [{"type": "SAFE_SEARCH_DETECTION"}]
      }
    ]
  };

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(requestPayload),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final safeSearch = data["responses"][0]["safeSearchAnnotation"];

    List<String> unsafeCategories = ["adult", "violence", "medical", "racy"];

    for (var category in unsafeCategories) {
      String likelihood = safeSearch[category];
      print(category + ": " + likelihood);
      if (["LIKELY", "VERY_LIKELY", "POSSIBLE", "UNKNOWN"].contains(likelihood)) {
        return false; // Image is inappropriate
      }
    }
    return true; // Image is safe
  } else {
    errorLogger(response.body, 'checkImageSafety(Uint8List imageBytes)');
    print("SafeSearch API error: ${response.body}");
    return false; // Assume unsafe if there's an error
  }
}
