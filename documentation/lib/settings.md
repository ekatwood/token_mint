# `settings.dart`

This file defines the `SettingsPage` widget, which provides a user interface for managing application settings, such as receiving airdrops and email subscriptions.

## Classes

### `SettingsPage`

A `StatefulWidget` that displays and allows users to modify application settings.

#### State (`_SettingsPageState`)

The private state class for `SettingsPage`.

#### Properties

* `receiveAirdrops`: A boolean to toggle whether the user wants to receive random airdrops.
* `email`: A string to store the user's email address for subscriptions.
* `selectedFrequency`: A string holding the currently selected email broadcast frequency (e.g., 'Once a day').
* `frequencyOptions`: A list of strings defining the available email frequency options.

#### Methods

* **`build(BuildContext context)`**:
    * Builds the UI for the settings page.
    * Includes an `AppBar` with the title 'Settings'.
    * The `body` consists of a `Padding` widget containing a `Column` of settings options:
        * **`SwitchListTile`**: For toggling `receiveAirdrops`. Updates the `receiveAirdrops` state when toggled.
        * **Email Subscription Section**:
            * Displays informative `Text` widgets about email broadcasts.
            * `TextField` for entering an email address.
            * `DropdownButtonFormField` for selecting the `selectedFrequency` from `frequencyOptions`.
            * `ElevatedButton` labeled "Submit Email". (The logic for handling email submission is currently unimplemented in the provided code).