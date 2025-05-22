# `index.js` (Google Cloud Functions)

This file defines Google Cloud Functions that serve as backend API endpoints for the Flutter web application. It includes functions for image analysis using Google Cloud Vision and for fetching a treasury wallet address from Firebase Remote Config.

## Imports and Initialization

* `firebase-functions/v2/https`: Imports HTTP triggers for Cloud Functions.
* `firebase-functions/logger`: Imports the logger for Cloud Functions.
* `@google-cloud/vision`: Imports the Google Cloud Vision API client.
* `firebase-functions`: Imports the main Firebase Functions library.
* `firebase-admin`: Imports the Firebase Admin SDK.
* **`admin.initializeApp()`**: Initializes the Firebase Admin SDK, allowing interaction with other Firebase services.
* **`client = new vision.ImageAnnotatorClient()`**: Creates an instance of the Google Cloud Vision API client.

## Functions

### `analyzeImage`

An HTTPS Callable Cloud Function designed to perform Google Cloud Vision Safe Search detection on an image.

#### Trigger

* HTTPS request with CORS enabled (`onRequest({cors: true})`).

#### Request Body

* `image` (string): A Base64 encoded string of the image data.

#### Functionality

1.  **Input Validation**: Checks if the `image` data is provided in the request body. Returns a 400 error if missing.
2.  **Base64 Processing**: Removes the data URL prefix (e.g., `data:image/jpeg;base64,`) if present, to get the pure Base64 image content.
3.  **Vision API Call**: Calls `client.annotateImage` with the Base64 image and requests `SAFE_SEARCH_DETECTION` as a feature.
4.  **Response**: Returns the `safeSearchAnnotation` results (likelihoods for adult, violence, racy, medical, spoof content) as a JSON response with a 200 status code.
5.  **Error Handling**: Catches any errors during image processing or API calls, logs them using `logger.error`, and sends a 500 status code with an error message.

### `WorkspaceTreasuryPublicWalletAddress`

An HTTPS Callable Cloud Function that retrieves a predefined treasury public wallet address from Firebase Remote Config.

#### Trigger

* HTTPS request (`functions.https.onRequest`).

#### Functionality

1.  **Remote Config Access**: Retrieves the current Remote Config template using `admin.remoteConfig().getTemplate()`.
2.  **Parameter Extraction**: Accesses the `treasuryPublicWalletAddress` parameter from the Remote Config template's `defaultValue.value`.
3.  **Validation**: Throws an error if the `treasuryPublicWalletAddress` is not found in Remote Config.
4.  **Response**: Returns the `treasuryWalletAddress` as a JSON object with a 200 status code.
5.  **Error Handling**: Catches any errors during fetching or validation, logs them using `logger.error`, and sends a 500 status code with an error message.