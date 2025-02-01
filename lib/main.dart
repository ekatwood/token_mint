import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'phantom_wallet.dart';

void main() {
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
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();
  String? _walletAddress;

  String _fontFamily = 'SourceCodePro';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
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
                onTap: () {
                  _walletAddress = connectPhantom();
                  print(_walletAddress);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/wallet.png',
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
              if (_logoFile != null)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_logoFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 162,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _logoFile != null) {
                        print('Name: ${_nameController.text}');
                        print('Symbol: ${_symbolController.text}');
                        print('Logo: ${_logoFile!.path}');
                      } else if (_logoFile == null) {
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
                    child: const Text('Create Token'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Center(
                  child: Text(
                    "By clicking 'Create Token', you attest that no copyrighted or trademarked materials or intellectual property is being used in your minted Solana token.",
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
