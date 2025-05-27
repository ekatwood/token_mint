import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as ap;
import 'package:token_mint/settings.dart';
// import 'package:token_mint/upload_to_Arweave.dart'; // No longer needed, integrated into create_token.dart
import 'appbar.dart';
// import 'create_token.dart'; // No longer needed, using JS interop directly
// import 'firestore_functions.dart'; // Only needed if errorLogger is from here
import 'safesearch_api.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'dart:js_util' as js_util; // For JS interop
import 'dart:html' as html; // For JS interop

// // Declare the JavaScript function for minting
// // Ensure this matches the function name in your create_token.js
// // It expects Uint8List for bytes, and Dart String/List<String> for others.
// @JS()
// external Future<String> mintTokenArbitrum(
//     Uint8List logoBytes,
//     String fileExtension,
//     String nameOfToken,
//     String symbol,
//     String? description, // Optional
//     List<String>? websites, // Optional
//     int totalNumTokens,
//     String userPublicWalletAddress,
//     );

// If you still have errorLogger from firestore_functions.dart, declare it here
// @JS()
// external void errorLogger(String error, String context);

class TokenFactory extends StatefulWidget {
  const TokenFactory({Key? key}) : super(key: key);

  @override
  State<TokenFactory> createState() => _TokenFactoryState();
}

class _TokenFactoryState extends State<TokenFactory> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _tokenQuantityController =
  TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // New
  final List<TextEditingController> _websiteControllers = []; // New
  final List<String> _websites = []; // New: To store actual website URLs

  Uint8List? _logoFileBytes;
  final ImagePicker _picker = ImagePicker();
  // bool _walletConnected = false; // This state should now be managed by AuthProvider
  // String? _walletAddress; // This should come from AuthProvider
  String? _fileExtension;
  int? _tokenQuantity;

  String _fontFamily = 'SourceCodePro';

  // --- Validation functions ---
  bool isValidTokenName(String name) {
    return utf8.encode(name).length <= 500;
  }

  bool isValidTokenSymbol(String symbol) {
    return utf8.encode(symbol).length <= 100;
  }

  bool isValidDescription(String description) {
    return utf8.encode(description).length <= 5000;
  }

  bool isValidWebsite(String website) {
    return utf8.encode(website).length <= 500;
  }

  // Helper function to parse token quantities with M/B notation
  int? parseTokenQuantity(String input) {
    input = input.replaceAll(',', '').replaceAll(' ', '').trim().toLowerCase();

    if (input.endsWith('m')) {
      final value = double.tryParse(input.substring(0, input.length - 1));
      if (value != null) {
        return (value * 1000000).toInt();
      }
    } else if (input.endsWith('b')) {
      final value = double.tryParse(input.substring(0, input.length - 1));
      if (value != null) {
        return (value * 1000000000).toInt();
      }
    } else {
      final value = int.tryParse(input);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  // --- Image picking ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String fileName = pickedFile.name;
        String extension = path.extension(fileName).toLowerCase();

        if (extension == '.png' ||
            extension == '.jpg' ||
            extension == '.jpeg' ||
            extension == '.webp') {
          _fileExtension = extension.substring(1);
          _logoFileBytes = await pickedFile.readAsBytes();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text('Only png, jpg, jpeg, or webp files are allowed.')),
          );
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      // errorLogger(e.toString(), '_pickImage()'); // Uncomment if errorLogger is available
    }
  }

  // --- Website field management ---
  void _addWebsiteField() {
    if (_websiteControllers.length < 5) {
      setState(() {
        _websiteControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add a maximum of 5 websites.')),
      );
    }
  }

  void _removeWebsiteField(int index) {
    setState(() {
      _websiteControllers[index].dispose();
      _websiteControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _tokenQuantityController.dispose();
    _descriptionController.dispose();
    for (var controller in _websiteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<ap.AuthProvider>(context);
    // Use authProvider.walletAddress directly
    final String? userWalletAddress = authProvider.walletAddress;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name of token',
                      labelStyle: TextStyle(
                          fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                        fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the token name';
                      }
                      if (!isValidTokenName(value)) {
                        return 'Name exceeds maximum length of 500 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextFormField(
                    controller: _symbolController,
                    decoration: InputDecoration(
                      labelText: 'Symbol',
                      labelStyle: TextStyle(
                          fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                        fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the symbol';
                      }
                      if (!isValidTokenSymbol(value)) {
                        return 'Symbol exceeds maximum length of 100 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 190,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: _fontFamily,
                        ),
                      ),
                      child: const Text('Upload Logo'),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Recommended dimensions: 500x500 px',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                if (_logoFileBytes != null)
                  ClipOval(
                    child: Image.memory(
                      _logoFileBytes!,
                      width: 125,
                      height: 125,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                // --- Description Field ---
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: TextStyle(
                          fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true, // Aligns label to top for multiline
                    ),
                    style: TextStyle(
                        fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                    maxLines: 5, // Allow multiple lines
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value != null && !isValidDescription(value)) {
                        return 'Description exceeds maximum length of 5000 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // --- Websites Fields ---
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Websites (Optional, max 5)',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._websiteControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        TextEditingController controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Website ${idx + 1}',
                                    labelStyle: TextStyle(
                                        fontFamily: _fontFamily,
                                        fontWeight: FontWeight.bold),
                                    border: const OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontWeight: FontWeight.bold),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && !isValidWebsite(value)) {
                                      return 'Website exceeds maximum length of 500 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeWebsiteField(idx),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (_websiteControllers.length < 5)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _addWebsiteField,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Website'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontFamily: _fontFamily),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _tokenQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Number of tokens',
                          labelStyle: TextStyle(
                              fontFamily: _fontFamily,
                              fontWeight: FontWeight.bold),
                          border: const OutlineInputBorder(),
                        ),
                        style: TextStyle(
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.bold),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the token quantity';
                          }
                          _tokenQuantity = parseTokenQuantity(value);
                          if (_tokenQuantity == null) {
                            return 'Please enter a valid number';
                          }
                          if (_tokenQuantity! < 10000000) {
                            return 'Minimum quantity is 10M tokens';
                          }
                          if (_tokenQuantity! > 2000000000) {
                            return 'Maximum quantity is 2B tokens';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Enter a value between 10M and 2B tokens.",
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoggedIn
                          ? () async {
                        if (_formKey.currentState!.validate() &&
                            _logoFileBytes != null) {
                          final tokenQuantity = parseTokenQuantity(
                              _tokenQuantityController.text);
                          if (tokenQuantity != null) {
                            bool safeImage =
                            await checkImageSafety(_logoFileBytes!);
                            if (!safeImage) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please use an appropriate image.')),
                              );
                            } else {
                              // Collect optional fields
                              final String? description = _descriptionController.text.isEmpty
                                  ? null
                                  : _descriptionController.text;

                              _websites.clear(); // Clear previous list
                              for (var controller in _websiteControllers) {
                                if (controller.text.isNotEmpty && isValidWebsite(controller.text)) {
                                  _websites.add(controller.text);
                                }
                              }
                              final List<String>? websites = _websites.isEmpty ? null : _websites;

                              // Call the JavaScript minting function
                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Initiating token minting. Please check your MetaMask wallet for prompts.')),
                                );
                                // final contractAddress = await mintTokenArbitrum(
                                //   _logoFileBytes!,
                                //   _fileExtension!,
                                //   _nameController.text,
                                //   _symbolController.text,
                                //   description,
                                //   websites,
                                //   tokenQuantity,
                                //   userWalletAddress!, // userWalletAddress is guaranteed non-null if isLoggedIn
                                // );
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //       content: Text('Token minted successfully! Contract Address: $contractAddress')),
                                // );
                                // Optionally navigate or clear form
                                _formKey.currentState?.reset();
                                _logoFileBytes = null;
                                _descriptionController.clear();
                                for (var controller in _websiteControllers) {
                                  controller.dispose(); // Dispose old controllers
                                }
                                _websiteControllers.clear(); // Clear list
                                _websites.clear();
                                setState(() {}); // Rebuild to clear image and website fields
                              } catch (e) {
                                print("Minting Error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Token minting failed: ${e.toString()}')),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Invalid token quantity')),
                            );
                          }
                        } else if (_logoFileBytes == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please upload a logo.')),
                          );
                        }
                      }
                          : null, // Disable button if not logged in
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: _fontFamily,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Mint Token'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                            "Disclaimer: 3% of tokens minted go to the MOONROCKET treasury wallet and are locked into staking for 6 months. Good luck, we hope you mint a winner! ",
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: "🔥📈💸",
                            style: TextStyle(
                              fontFamily: 'NotoColorEmoji',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
