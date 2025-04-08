import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appbar.dart'; // Import your custom AppBar
import 'auction.dart'; // Import the Auction widget
import 'airdrop.dart'; // Import the Airdrop widget

class ProjectPage extends StatelessWidget {
  final String mintAddress;

  const ProjectPage({super.key, required this.mintAddress});

  Future<Map<String, dynamic>?> _fetchTokenData() async {
    final doc = await FirebaseFirestore.instance
        .collection('public_wallet_addresses')
        .doc(mintAddress)
        .get();

    if (doc.exists) {
      return doc.data();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Use your custom AppBar
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchTokenData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Unable to load project details'));
          }

          final data = snapshot.data!;
          final logoUrl = data['logo_url'] ?? '';
          final name = data['name'] ?? 'Unknown';
          final symbol = data['symbol'] ?? '';
          final description = data['description'] ?? '';
          final totalSupply = data['total_supply'] ?? 'Not available';
          final isAuctionEnabled = data['auction_enabled'] ?? false;
          final isAirdropEnabled = data['airdrop_enabled'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                if (logoUrl.isNotEmpty)
                  ClipOval(
                    child: Image.network(
                      logoUrl,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 120,
                    width: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                const SizedBox(height: 16),

                // Name & Symbol
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  symbol,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Description
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),

                // Total Supply
                Text(
                  'Total Supply: $totalSupply',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Conditional Widgets (Auction & Airdrop)
                if (isAuctionEnabled) const Auction(),
                if (isAirdropEnabled) const Airdrop(),
              ],
            ),
          );
        },
      ),
    );
  }
}
