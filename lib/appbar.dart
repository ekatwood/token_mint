import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Import for routing
import 'auth_provider.dart'; // Import the AuthProvider

// Placeholder for the solflare SDK and wallet connection logic.
// In a real application, this would be in a separate file.
// For this example, we'll just define a placeholder function.
// We've modified it to return a wallet address.
Future<String?> connectWallet() async {
  // Simulate connecting to a wallet.  Replace this with your actual Solflare SDK call.
  print("Connecting to Solflare wallet...");
  // Simulate a successful connection after a short delay.
  await Future.delayed(const Duration(seconds: 1));
  print("Wallet connected!");
  // Simulate a wallet address being returned.
  const simulatedWalletAddress = '0x1234567890abcdef'; //  REPLACE THIS
  return simulatedWalletAddress; // Return the simulated address.
}

// AppBar widget with dynamic content.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Constructor for the CustomAppBar.
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Set the preferred height.

  @override
  Widget build(BuildContext context) {
    // Access the AuthProvider using Provider.of.
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return AppBar(
      backgroundColor: Colors.blue, // Set the background color of the AppBar.
      leading: Padding(
        padding: const EdgeInsets.all(8.0), // Add some padding around the logo.
        child: GestureDetector(
          onTap: () {
            // Use go_router to navigate to the home route.
            context.go('/'); // Navigate to the root route
          },
          child: Image.asset(
            'assets/logo.png', // Path to your logo image.
            width: 40, // Set the width of the logo.
            height: 40, // Set the height of the logo.
          ),
        ),
      ),
      leadingWidth: 60, // Set the width of the leading widget.
      title: const Text('MOONROCKET'), // Title of the AppBar.
      centerTitle: true, // Center the title.
      actions: [
        // Use a ternary operator to display different widgets based on the login state.
        if (isLoggedIn)
          _buildLoggedInActions(context, authProvider) // Pass authProvider
        else
          _buildLoggedOutAction(context, authProvider), // Pass authProvider
      ],
    );
  }

  // Widget for when the user is logged in.
  Widget _buildLoggedInActions(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      // Use a builder to get the context for the PopupMenuButton.
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'mint_token',
            child: Text('Mint Token'),
          ),
          const PopupMenuItem<String>(
            value: 'my_projects',
            child: Text('My Projects'),
          ),
          PopupMenuItem<String>(
            value: 'disconnect_wallet',
            child: Text('Disconnect Wallet'),
          ),
        ];
      },
      onSelected: (String value) {
        // Handle the selected menu item.
        switch (value) {
          case 'mint_token':
          // Navigate to mint token page.
          //  Use go_router to navigate.
            context.go('/mint_token'); // Example route
            break;
          case 'my_projects':
          // Navigate to my projects page.
            context.go('/my_projects');
            break;
          case 'disconnect_wallet':
          // Call the logout method from the AuthProvider.
            authProvider.logout();
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row( // Display Wallet Address
          children: [
            const Icon(Icons.arrow_drop_down), // Dropdown menu icon.
            const SizedBox(width: 8),
            Text(
              _truncateWalletAddress(authProvider.walletAddress), // Show Address
              style: const TextStyle(fontSize: 12), // Adjust size as needed
            ),
          ],
        ),
      ),
    );
  }

  // Widget for when the user is not logged in.
  Widget _buildLoggedOutAction(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final walletAddress =
          await connectWallet(); //  Call your connectWallet function
          // Simulate a successful connection.
          if (walletAddress != null) {
            authProvider.login(
                walletAddress); // Update the state using the provider.
          } else {
            // Handle the error.  Show a message to the user.
            print('Failed to connect wallet'); //  Important
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to connect wallet.'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        },
        child: SvgPicture.asset(
          'assets/solflare_logo.svg',
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  // Helper function to truncate wallet address
  String _truncateWalletAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}

