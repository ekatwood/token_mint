# `main.dart`

This file serves as the entry point for the Flutter web application, setting up routing, state management, and the overall application theme.

## Global Variables

* **`_router`**:
    * A `GoRouter` instance that defines the navigation routes for the application.
    * **Routes Defined**:
        * `/`: Maps to the `TokenMint` widget (home screen).
        * `/mint_token`: Maps to the `TokenFactory` widget (token creation form).
        * `/settings`: Maps to the `SettingsPage` widget.

## Functions

### `main()`

The main function where the Flutter application execution begins.

#### Functionality

* Calls `runApp()`.
* Wraps the `TokenMintApp` with a `ChangeNotifierProvider` for `AuthProvider`. This makes the authentication state (`AuthProvider`) available to all widgets throughout the application.

## Classes

### `TokenMintApp`

The root `StatelessWidget` of the application.

#### Methods

* **`build(BuildContext context)`**:
    * Returns a `MaterialApp.router` widget.
    * Sets the `routerConfig` to `_router` for navigation.
    * Sets the `title` of the application to 'MOONROCKET'.
    * Defines the application's `ThemeData`:
        * `primarySwatch`: `Colors.teal`.
        * `fontFamily`: 'SourceCodePro'.
        * `textTheme`: Sets a default `bodyMedium` font size.

### `TokenMint`

The main screen of the application, defined as a `StatefulWidget`.

#### State (`_TokenMintState`)

The private state class for `TokenMint`.

#### Methods

* **`build(BuildContext context)`**:
    * Returns a `Scaffold` widget.
    * Sets the `appBar` to `CustomAppBar()`.
    * The `body` is currently a `Center` widget containing an empty `Column`, suggesting that content for the home screen is intended to be added here.