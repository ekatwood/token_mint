import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool receiveAirdrops = false;
  String email = '';
  String selectedFrequency = 'Once a day';
  final List<String> frequencyOptions = ['Once a day', 'Once a week', 'Once a month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Receive Random Airdrops'),
              value: receiveAirdrops,
              onChanged: (bool value) {
                setState(() {
                  receiveAirdrops = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Frequency of email broadcasts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Opt-in to receive news about upcoming and trending token auctions.',
                style: TextStyle(color: Colors.grey)),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedFrequency,
              items: frequencyOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFrequency = newValue ?? 'Once a day';
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle email submission logic
              },
              child: Text('Submit Email'),
            ),
          ],
        ),
      ),
    );
  }
}
