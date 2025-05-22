# `create_token.dart`

This file provides a Dart function `mintToken` that acts as a bridge to a JavaScript function of the same name, facilitating the token minting process.

## Functions

### `mintToken(String name, String symbol, String logoUrl, int supply, String wallet)`

Asynchronously calls a JavaScript function named `mintToken` with the provided token details.

#### Parameters

* `name` (String): The desired name for the new token.
* `symbol` (String): The desired symbol for the new token.
* `logoUrl` (String): The Arweave URL where the token logo is stored.
* `supply` (int): The total supply of the new token.
* `wallet` (String): The public address of the user's wallet initiating the mint.

#### Returns

* `Future<String>`: A `Future` that resolves to a `String` result from the JavaScript `mintToken` function, or `'error'` if an exception occurs.

#### Throws

* Catches any exceptions during the JavaScript interop call and logs them using `errorLogger` from `firestore_functions.dart`. Returns 'error' in case of an exception.