import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:token_mint/settings.dart';
import 'appbar.dart';
import 'auth_provider.dart';
import 'create_token_form.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TokenMint(),
    ),
    GoRoute(
      path: '/mint_token',
      builder: (context, state) => const TokenFactory(), // Create this page
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(), // and this page
    ),
  ],
);

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
    return MaterialApp.router(
      routerConfig: _router,
      title: 'MOONROCKET', // The title of the app.
      // Theme settings for the app.  This controls the visual appearance.
      theme: ThemeData(
        primarySwatch: Colors.teal, // Primary color for the app.
        fontFamily: 'SourceCodePro', // Default font family.
        //  You can customize the textTheme further, if needed.
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0), // Default body text style.
        ),
      ),
      // The home screen of the app.
      //home: const TokenMint(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      // The main content of the screen.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically.

        ),
      ),
      // Floating action button to increment the counter.

    );
  }
}
