import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Airdrop extends StatefulWidget {
  final String mintAddress;

  const Airdrop({super.key, required this.mintAddress});

  @override
  _AirdropState createState() => _AirdropState();
}

class _AirdropState extends State<Airdrop> {
  double airdropAmount = 0.0; // Amount of tokens to airdrop
  bool isOwner = false; // Whether the current user is the token owner
  bool isAirdropActive = false; // Whether the airdrop is active
  List<String> walletAddresses = []; // List of wallet addresses for the airdrop
  String selectedWallet = ''; // Selected wallet for non-owner users

  // Sample data (replace with real owner and wallet address checks)
  final String currentUserAddress = 'user_wallet_address'; // Current user address

  // Fetch token data (owner info, airdrop status, etc.)
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

  // Fetch wallet addresses associated with the airdrop
  Future<List<String>> _fetchAirdropAddresses() async {
    final doc = await FirebaseFirestore.instance
        .collection('public_wallet_addresses')
        .doc(widget.mintAddress)
        .collection('airdrop_addresses')
        .get();

    if (doc.docs.isNotEmpty) {
      return doc.docs.map((e) => e.id).toList();
    } else {
      return [];
    }
  }

  // Check if current user is the owner of the minted token
  Future<void> _checkOwnerStatus() async {
    final tokenData = await _fetchTokenData();
    if (tokenData != null) {
      setState(() {
        isOwner = tokenData['owner_address'] == currentUserAddress;
        isAirdropActive = tokenData['airdrop_active'] ?? false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkOwnerStatus();
    if (!isOwner) {
      _fetchAirdropAddresses().then((addresses) {
        setState(() {
          walletAddresses = addresses;
        });
      });
    }
  }

  // Function to toggle airdrop activation/deactivation for the owner
  Future<void> _toggleAirdrop(bool active) async {
    await FirebaseFirestore.instance
        .collection('public_wallet_addresses')
        .doc(widget.mintAddress)
        .update({'airdrop_active': active});
    setState(() {
      isAirdropActive = active;
    });
  }

  // Function to handle airdrop distribution for the owner
  Future<void> _sendAirdrop() async {
    if (airdropAmount > 0) {
      // Send airdrop logic to distribute tokens to the wallet addresses
      // Logic to interact with Solana wallet and distribute tokens

      // After successful airdrop, update the database if necessary
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Airdrop sent successfully!')));
    }
  }

  // Function to add/remove wallet address for non-owner users
  Future<void> _submitRemoveWalletAddress() async {
    if (walletAddresses.contains(selectedWallet)) {
      await FirebaseFirestore.instance
          .collection('public_wallet_addresses')
          .doc(widget.mintAddress)
          .collection('airdrop_addresses')
          .doc(selectedWallet)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet address removed!')));
    } else {
      await FirebaseFirestore.instance
          .collection('public_wallet_addresses')
          .doc(widget.mintAddress)
          .collection('airdrop_addresses')
          .doc(selectedWallet)
          .set({});

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet address added!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwner) ...[
            // Token Owner's Airdrop Configuration Section
            Text('Configure Airdrop', style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _toggleAirdrop(!isAirdropActive);
              },
              child: Text(isAirdropActive ? 'Deactivate Airdrop' : 'Activate Airdrop'),
            ),
            const SizedBox(height: 20),
            if (isAirdropActive) ...[
              Text('Amount of Tokens to Airdrop:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    airdropAmount = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter amount to airdrop',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendAirdrop,
                child: const Text('Send Airdrop'),
              ),
            ],
          ] else ...[
            // Non-Owner: Adding/Removing Wallet Address for Airdrop
            Text('Select your Solana wallet address:'),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedWallet.isEmpty ? null : selectedWallet,
              hint: const Text('Select a wallet address'),
              items: walletAddresses
                  .map((address) => DropdownMenuItem<String>(
                value: address,
                child: Text(address),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWallet = value ?? '';
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRemoveWalletAddress,
              child: Text(walletAddresses.contains(selectedWallet)
                  ? 'Remove Wallet Address'
                  : 'Submit Wallet Address'),
            ),
          ],
        ],
      ),
    );
  }
}
