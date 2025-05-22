# `safesearch_api.dart`

This file contains a utility function for checking the safety of an image using the Google Cloud Vision Safe Search API via a Cloud Function.

## Functions

### `checkImageSafety(Uint8List imageBytes)`

Asynchronously sends image data to a Google Cloud Function for Safe Search analysis.

#### Parameters

* `imageBytes` (Uint8List): The raw bytes of the image to be analyzed.

#### Returns

* `Future<bool>`: A `Future` that resolves to `true` if the image is considered safe (no `LIKELY`, `VERY_LIKELY`, `POSSIBLE`, or `UNKNOWN` likelihood in adult, violence, medical, or racy categories), and `false` otherwise.

#### Functionality

* Converts the `imageBytes` to a Base64 encoded string.
* Makes an HTTP POST request to the Google Cloud Function endpoint (`https://us-central1-token-mint-8f0e3.cloudfunctions.net/analyzeImage`) with the Base64 image in the request body.
* Parses the JSON response from the Cloud Function.
* Extracts the `safeSearchAnnotation` from the response.
* Iterates through predefined `unsafeCategories` ("adult", "violence", "medical", "racy").
* For each category, if the `likelihood` is `LIKELY`, `VERY_LIKELY`, `POSSIBLE`, or `UNKNOWN`, the function returns `false` (image is inappropriate).
* If no unsafe categories are detected with a concerning likelihood, it returns `true` (image is safe).
* Logs errors to Firestore using `errorLogger` if the HTTP request fails or the response status code is not 200.
* Prints console messages for debugging and error reporting.