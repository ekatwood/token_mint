import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

void main() {
  runApp(// Provide the AuthProvider to the entire application.
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const TokenMintApp(),
    ),);
}

// The main application class.  This is the root widget of your app.
class TokenMintApp extends StatelessWidget {
  const TokenMintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Mint App', // The title of the app.
      // Theme settings for the app.  This controls the visual appearance.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color for the app.
        fontFamily: 'Roboto', // Default font family.
        //  You can customize the textTheme further, if needed.
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0), // Default body text style.
        ),
      ),
      // The home screen of the app.
      home: const TokenMint(),
    );
  }
}

// The main screen of the application.  This is a stateful widget.
// because it will likely need to manage some state.
class TokenMint extends StatefulWidget {
  const TokenMint({super.key});

  @override
  _TokenMintState createState() => _TokenMintState();
}

// The state class for the TokenMint widget.
class _TokenMintState extends State<TokenMint> {
  int _counter = 0; // A counter variable to demonstrate state management.

  // This method is called when the '+' button is pressed.
  void _incrementCounter() {
    setState(() {
      // This tells Flutter to rebuild the widget with the new value of _counter.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Mint'), // Title of the app bar.
        centerTitle: true, // Center the title.
      ),
      // The main content of the screen.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically.
          children: <Widget>[
            const Text(
              'Click the button to increment the counter:', // Instructions text.
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 10), // Add some space between the text and the counter.
            Text(
              '$_counter', // Display the current value of the counter.
              style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      // Floating action button to increment the counter.
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, // Call the _incrementCounter method when pressed.
        tooltip: 'Increment', // Tooltip for the button.
        child: const Icon(Icons.add), // Icon for the button.
      ),
    );
  }
}
