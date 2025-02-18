import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'phantom_wallet.dart';
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
  Uint8List? _logoFileBytes;
  final ImagePicker _picker = ImagePicker();
  String? _walletAddress;
  String? _fileExtension;

  String _fontFamily = 'SourceCodePro';

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
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 208,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _logoFileBytes != null) {
                        bool safeImage = await checkImageSafety(_logoFileBytes!);
                        if(!safeImage){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please use an appropriate image.')),
                          );
                        }
                        else{
                          //TODO: send transactions to mint token
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
                    child: const Text('Mint 500M Tokens'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Center(
                  child: Text(
                    "Disclaimer: By clicking 'Mint 500M Tokens', you will be sending 0.5% of tokens to this website. Any tokens sent to this website that are in violation of intellectual property rights will be burned.",
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
