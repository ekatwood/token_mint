import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectSmallView extends StatelessWidget {
  final String mintAddress;

  const ProjectSmallView({super.key, required this.mintAddress});

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
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchTokenData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: LinearProgressIndicator(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return const ListTile(
            title: Text('Unable to load project'),
          );
        }

        final data = snapshot.data!;
        final logoUrl = data['logo_url'] ?? '';
        final name = data['name'] ?? 'Unknown';
        final symbol = data['symbol'] ?? '';
        final description = data['description'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      logoUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 60,
                    width: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        symbol,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectPage(mintAddress: mintAddress),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Placeholder for project.dart — to be implemented
class ProjectPage extends StatelessWidget {
  final String mintAddress;

  const ProjectPage({super.key, required this.mintAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: Center(child: Text('Details for $mintAddress')),
    );
  }
}
