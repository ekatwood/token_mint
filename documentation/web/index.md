# `index.html`

This is the main HTML file that serves as the entry point for the Flutter web application. It sets up the basic document structure, meta information, and loads necessary JavaScript SDKs and local scripts for the application to function.

## Document Structure

* **HTML5 Doctype**: `<!DOCTYPE html>`
* **Language**: `<html>` tag without a `lang` attribute.

## Head Section (`<head>`)

* **Base HREF**: Contains a `<base href="$FLUTTER_BASE_HREF">` tag, which is a placeholder meant to be replaced by the `flutter build` command to define the base path for relative URLs.
* **Character Set**: `<meta charset="UTF-8">`
* **Compatibility**: `<meta content="IE=Edge" http-equiv="X-UA-Compatible">` for Internet Explorer compatibility.
* **Description**: `<meta name="description" content="A Solana token factory with no fees, just the transaction fees">`
* **iOS Meta Tags**: Includes meta tags for iOS web app capability (`apple-mobile-web-app-capable`, `apple-mobile-web-app-status-bar-style`, `apple-mobile-web-app-title`) and an `apple-touch-icon`.
* **Favicon**: `<link rel="icon" type="image/png" href="moonrocket_favicon.png"/>` points to the application's favicon.
* **Title**: `<title>MOONROCKET</title>` sets the browser tab title.
* **Web App Manifest**: `<link rel="manifest" href="manifest.json">` for Progressive Web App (PWA) features.

## JavaScript Imports

The file includes several `<script>` tags to load external libraries and local JavaScript files:

* `https://unpkg.com/@solflare-wallet/sdk@latest/dist/index.umd.js`: Imports the Solflare Wallet SDK from a CDN.
* `javascript/solflare_connect.js`: Loads the local script for Solflare wallet connection logic.
* `javascript/metamask_connect.js`: Loads the local script for MetaMask wallet connection logic.
* `javascript/create_token.js`: Loads the local script containing the token minting logic.
* `javascript/upload_to_Arweave.js`: Loads the local script for Arweave upload functionality.
* `javascript/firebase.js`: Loads the local script for Firebase client-side initialization.

## Body Section (`<body>`)

* **Flutter Loader**: Contains a `<script>` tag that loads the Flutter web initialization script (`flutter.js`), which is responsible for bootstrapping the Flutter application.