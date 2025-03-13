import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:token_mint/upload_to_Arweave.dart';
import 'phantom_wallet.dart';
import 'create_token.dart';
import 'firestore_functions.dart';
import 'firebase_options.dart';
import 'safesearch_api.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

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
      home: const TokenFactory(),
    );
  }
}

class TokenFactory extends StatefulWidget {
  const TokenFactory({Key? key}) : super(key: key);

  @override
  State<TokenFactory> createState() => _TokenFactoryState();
}

class _TokenFactoryState extends State<TokenFactory> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _tokenQuantityController = TextEditingController();
  Uint8List? _logoFileBytes;
  final ImagePicker _picker = ImagePicker();
  String? _walletAddress;
  String? _fileExtension;
  int? _tokenQuantity;

  String _fontFamily = 'SourceCodePro';

  // Helper function to parse token quantities with M/B notation
  int? parseTokenQuantity(String input) {
    // Remove any commas and spaces
    input = input.replaceAll(',', '').replaceAll(' ', '').trim().toLowerCase();

    // Handle million notation
    if (input.endsWith('m')) {
      final value = double.tryParse(input.substring(0, input.length - 1));
      if (value != null) {
        return (value * 1000000).toInt();
      }
    }
    // Handle billion notation
    else if (input.endsWith('b')) {
      final value = double.tryParse(input.substring(0, input.length - 1));
      if (value != null) {
        return (value * 1000000000).toInt();
      }
    }
    // Handle direct integer input
    else {
      final value = int.tryParse(input);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String fileName = pickedFile.name; // Get file name for web
        String extension = path.extension(fileName).toLowerCase(); // Get file extension

        if (extension == '.png' || extension == '.jpg' || extension == '.jpeg' || extension == '.webp') {
          _fileExtension = extension.substring(1);

          // Read bytes for web (since we can't use File() in web)
          _logoFileBytes = await pickedFile.readAsBytes();

          // After the async task completes, update the state
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only png, jpg, jpeg, or webp files are allowed.')),
          );
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      errorLogger(e.toString(), '_pickImage()');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        elevation: 3,
        shadowColor: Colors.teal,
        toolbarHeight: 106,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: GestureDetector(
                onTap: () async {
                  _walletAddress = await connectPhantom();
                  if(_walletAddress == "Please make sure Phantom Wallet browser extension is installed."){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_walletAddress.toString())),
                    );
                  }
                  else if(_walletAddress == 'error'){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error connecting to Phantom Wallet.')),
                    );
                  }
                  else{
                    //add public wallet address to database if not already there
                    phantomWalletConnected(_walletAddress!);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/phantom-logo.png',
                    height: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name of token',
                    labelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the token name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: TextFormField(
                  controller: _symbolController,
                  decoration: InputDecoration(
                    labelText: 'Symbol ex DOGE',
                    labelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the symbol';
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextFormField(
                  controller: _tokenQuantityController,
                  decoration: InputDecoration(
                    labelText: 'Number Of Tokens (between 10M and 2B)',
                    labelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold),
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
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 208,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _logoFileBytes != null) {
                        final tokenQuantity = parseTokenQuantity(_tokenQuantityController.text);
                        if (tokenQuantity != null) {
                          bool safeImage = await checkImageSafety(_logoFileBytes!);
                          if(!safeImage){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please use an appropriate image.')),
                            );
                          }
                          else{
                            // Upload logo to Arweave
                            String logoUri = await uploadToArweave(
                              _logoFileBytes!,  // Uint8List? logo file bytes
                              _nameController.value.toString(),        // Name of the token
                              _symbolController.value.toString(),      // Symbol of the token
                              _fileExtension!,    // File extension (e.g., "png", "jpg")
                              _walletAddress!, // User's Phantom Wallet address
                            );
                            mintToken(_nameController.value.toString(), _symbolController.value.toString(), logoUri, _tokenQuantity!, _walletAddress!);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid token quantity')),
                          );
                        }
                      } else if (_logoFileBytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please upload a logo.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontStyle: FontStyle.italic,
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
                  child: Text(
                    "Disclaimer: By clicking 'Mint Tokens', you will be sending 0.5% of tokens to this website. Any tokens sent to this website that are in violation of intellectual property rights will be burned.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}