import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final TextEditingController _tickerController = TextEditingController();
  File? _logoFile;

  final ImagePicker _picker = ImagePicker();

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name of token',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the token name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tickerController,
                decoration: const InputDecoration(
                  labelText: 'Ticker',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ticker';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Upload Logo'),
                  ),
                  const SizedBox(width: 16),
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
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add functionality to create token
                    if (_formKey.currentState!.validate() && _logoFile != null) {
                      // Print form data for now
                      print('Name: ${_nameController.text}');
                      print('Ticker: ${_tickerController.text}');
                      print('Logo: ${_logoFile!.path}');
                    } else if (_logoFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please upload a logo.')),
                      );
                    }
                  },
                  child: const Text('Create Token'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  @override
  void dispose() {
    _nameController.dispose();
    _tickerController.dispose();
    super.dispose();
  }
}