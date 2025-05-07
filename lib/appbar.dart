import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import 'package:js/js.dart';
import 'dart:async';

@JS('solflare')
class Solflare {
  external static Future<dynamic> connect(ConnectOptions? options);
  external static dynamic isConnected();
  external static dynamic disconnect();
}

@JS()
class ConnectOptions {
  external factory ConnectOptions([String? network]); // Changed to optional positional
  external String network;
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return AppBar(
      backgroundColor: Colors.blue,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: Image.asset(
            'assets/logo.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
      leadingWidth: 60,
      title: const Text('Token Mint'),
      centerTitle: true,
      actions: [
        if (isLoggedIn)
          _buildLoggedInActions(context, authProvider)
        else
          _buildLoggedOutAction(context, authProvider),
      ],
    );
  }

  Widget _buildLoggedInActions(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
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
        switch (value) {
          case 'mint_token':
            context.go('/mint_token');
            break;
          case 'my_projects':
            context.go('/my_projects');
            break;
          case 'disconnect_wallet':
            authProvider.logout();
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 8),
            Text(
              _truncateWalletAddress(authProvider.walletAddress),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedOutAction(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          try {
            final response = await Solflare.connect(ConnectOptions('mainnet-beta')); // Changed

            final publicKey = response.publicKey.toString();
            print("Public Key: $publicKey");
            authProvider.login(publicKey);
          } catch (error) {
            print("Error connecting to Solflare: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to connect wallet: $error'),
                duration: const Duration(seconds: 5),
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

  String _truncateWalletAddress(String address) {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}

