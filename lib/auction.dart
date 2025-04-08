import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auction extends StatefulWidget {
  final String mintAddress;

  const Auction({super.key, required this.mintAddress});

  @override
  _AuctionState createState() => _AuctionState();
}

class _AuctionState extends State<Auction> {
  double tokenPercentage = 100; // Percentage of tokens to offer in the auction
  String denomination = 'SOL'; // Denomination for auction (SOL, USDC, or RAY)
  double totalPrice = 0.0; // Total price set by the owner
  double pricePerToken = 0.0; // Price per token
  bool isOwner = false; // Whether the current user is the token owner
  bool isAuctionActive = false; // Whether the auction is active

  // Sample data (replace with real token owner check and auction data)
  final String currentUserAddress = 'user_wallet_address'; // Current user address
  double totalTokensAvailable = 1000; // Available tokens for auction (replace with actual data)

  // Fetch token data (owner info, auction status, etc.)
  Future<Map<String, dynamic>?> _fetchTokenData() async {
    final doc = await FirebaseFirestore.instance
        .collection('public_wallet_addresses')
        .doc(widget.mintAddress)
        .get();

    if (doc.exists) {
      return doc.data();
    } else {
      return null;
    }
  }

  // Check if current user is the owner of the minted token
  Future<void> _checkOwnerStatus() async {
    final tokenData = await _fetchTokenData();
    if (tokenData != null) {
      setState(() {
        isOwner = tokenData['owner_address'] == currentUserAddress;
        isAuctionActive = tokenData['auction_active'] ?? false;
        totalPrice = tokenData['total_price'] ?? 0.0;
        denomination = tokenData['denomination'] ?? 'SOL';
        pricePerToken = totalPrice / totalTokensAvailable;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkOwnerStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchTokenData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Unable to load auction details'));
        }

        final tokenData = snapshot.data!;
        final isOwner = tokenData['owner_address'] == currentUserAddress;
        final auctionActive = tokenData['auction_active'] ?? false;
        final totalPrice = tokenData['total_price'] ?? 0.0;
        final pricePerToken = totalPrice / totalTokensAvailable;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auction status and options based on ownership
              if (isOwner) ...[
                // Configuration Section for Auction Owner
                Text('Configure Auction', style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 10),
                Text('Denomination:'),
                DropdownButton<String>(
                  value: denomination,
                  items: ['SOL', 'USDC', 'RAY']
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      denomination = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text('Amount of Tokens to Offer (%): $tokenPercentage%'),
                Slider(
                  min: 1,
                  max: 100,
                  divisions: 100,
                  value: tokenPercentage,
                  onChanged: (value) {
                    setState(() {
                      tokenPercentage = value;
                      pricePerToken = (totalPrice * (tokenPercentage / 100)) / totalTokensAvailable;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text('Total Price of Auction:'),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      totalPrice = double.tryParse(value) ?? 0.0;
                      pricePerToken = totalPrice / (totalTokensAvailable * (tokenPercentage / 100));
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter total price for the auction',
                  ),
                ),
                const SizedBox(height: 10),
                Text('Price per Token: \$${pricePerToken.toStringAsFixed(2)}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAuctionActive = !isAuctionActive; // Toggle auction status
                    });
                  },
                  child: Text(auctionActive ? 'Edit Auction' : 'Activate Auction'),
                ),
                if (auctionActive) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAuctionActive = false; // Pause the auction
                      });
                    },
                    child: const Text('Pause Auction'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAuctionActive = false; // Cancel the auction
                      });
                    },
                    child: const Text('Cancel Auction'),
                  ),
                ]
              ] else ...[
                // Non-owner Section: Purchasing Tokens
                Text('Auction in: $denomination'),
                const SizedBox(height: 10),
                Text('Amount to Purchase:'),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      final purchaseAmount = double.tryParse(value) ?? 0.0;
                      // Calculate how many tokens the user would get
                      final tokensReceived = purchaseAmount / pricePerToken;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter amount to purchase',
                  ),
                ),
                const SizedBox(height: 10),
                Text('You will get X tokens for this amount', // Replace X with calculated tokens
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Trigger purchase functionality here
                  },
                  child: const Text('Purchase Tokens'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
