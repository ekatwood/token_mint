import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:token_mint/phantom_ghost_button.dart';
import 'package:token_mint/settings.dart';
import 'package:token_mint/upload_to_Arweave.dart';
import 'phantom_wallet.dart';
import 'create_token.dart';
import 'firestore_functions.dart';
import 'firebase_options.dart';
import 'safesearch_api.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'appbar.dart';
// Import ProjectSmallView once implemented
// import 'project_small_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TokenMint());
}

class TokenMint extends StatelessWidget {
  const TokenMint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'token-mint',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const TokenFeed(),
    );
  }
}

class TokenFeed extends StatefulWidget {
  const TokenFeed({Key? key}) : super(key: key);

  @override
  _TokenFeedState createState() => _TokenFeedState();
}

class _TokenFeedState extends State<TokenFeed> {
  final List<String> timeframes = ['Day', 'Week', 'Month', '6 Months', 'All Time'];
  String selectedTimeframe = 'Day';
  int currentPage = 0;
  final int projectsPerPage = 15;

  // Placeholder for project data; replace with actual data retrieval logic
  final List<String> allProjects = List.generate(100, (index) => 'MintAddress$index');

  List<String> get paginatedProjects {
    final start = currentPage * projectsPerPage;
    final end = (start + projectsPerPage).clamp(0, allProjects.length);
    return allProjects.sublist(start, end);
  }

  void loadMoreProjects() {
    if ((currentPage + 1) * projectsPerPage < allProjects.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void onTimeframeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedTimeframe = newValue;
        currentPage = 0;
        // Implement data fetching based on the selected timeframe
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mint a Solana token for just the price of the transaction fees!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to the mint token page
              },
              child: const Text('Mint Token'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Most Liked Projects',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: selectedTimeframe,
                  onChanged: onTimeframeChanged,
                  items: timeframes.map((String timeframe) {
                    return DropdownMenuItem<String>(
                      value: timeframe,
                      child: Text(timeframe),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: paginatedProjects.length + 1,
                itemBuilder: (context, index) {
                  if (index < paginatedProjects.length) {
                    final mintAddress = paginatedProjects[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Placeholder(
                        fallbackHeight: 80,
                        color: Colors.blueAccent,
                        strokeWidth: 2,
                      ),
                      // Replace Placeholder with:
                      // ProjectSmallView(mintAddress: mintAddress),
                    );
                  } else {
                    return Center(
                      child: ElevatedButton(
                        onPressed: loadMoreProjects,
                        child: const Text('Load More'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
