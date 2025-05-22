# `project_small_view.dart`

This file defines the `ProjectSmallView` widget, a reusable UI component for displaying a concise summary of a token or project, typically in a list or grid.

## Classes

### `ProjectSmallView`

A `StatelessWidget` designed to show essential information about a project or token fetched from Firestore.

#### Constructor

* `ProjectSmallView({super.key, required this.mintAddress})`
    * Requires a `mintAddress` to fetch the specific token data.

#### Properties

* `mintAddress` (String): The unique mint address of the token to be displayed.

#### Methods

* **`_fetchTokenData()` (Private Method)**:
    * **Returns**: `Future<Map<String, dynamic>?>` - A Future that resolves to a map containing the token's data, or `null` if the document does not exist.
    * Asynchronously fetches token data from the `public_wallet_addresses` collection in Firestore using the provided `mintAddress` as the document ID.

* **`build(BuildContext context)`**:
    * Builds the UI for the small project view.
    * Uses a `FutureBuilder` to asynchronously load `_fetchTokenData()`.
    * **Loading State**: Displays a `LinearProgressIndicator` while data is loading.
    * **Error/No Data State**: Displays a `ListTile` with "Unable to load project" if an error occurs or data is null.
    * **Data Loaded State**:
        * Displays a `Card` widget with `Padding`.
        * Arranges content in a `Row`:
            * **Logo**: Displays the token logo using `Image.network` if `logoUrl` is available; otherwise, shows a `FlutterLogo`.
            * **Text Details**: A `Column` containing the `name`, `symbol`, and a truncated `description` (max 2 lines).
            * **"View Details" Button**: An `TextButton` aligned to the bottom right. When pressed, it navigates to a `ProjectPage` (currently a placeholder) using `Navigator.push`, passing the `mintAddress`.

### `ProjectPage` (Placeholder)

A `StatelessWidget` serving as a placeholder for a detailed project view.

#### Constructor

* `ProjectPage({super.key, required this.mintAddress})`
    * Requires a `mintAddress`.

#### Properties

* `mintAddress` (String): The mint address for which details are to be displayed.

#### Methods

* **`build(BuildContext context)`**:
    * Returns a `Scaffold` with a simple `AppBar` titled "Project Details" and a `Center` body displaying "Details for [mintAddress]". This is a placeholder and should be expanded to show full project details.