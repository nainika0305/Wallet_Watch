import 'package:flutter/material.dart';

class HiPage extends StatefulWidget {
  @override
  _HiPageState createState() => _HiPageState();
}

class _HiPageState extends State<HiPage>
{
  // List of currencies for the dropdown
  final List<String> currencies = ['USD', 'EUR', 'INR', 'JPY', 'GBP'];
  // Variable to store the selected currency
  String? selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the quotation
            Text(
              'Your wallet deserves the best — track it right',
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40), // Add some space between the text and dropdown
            // Dropdown for currency selection
            DropdownButton<String>(
              hint: Text('Select Currency'),
              value: selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCurrency = newValue;
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20), // Add some space below the dropdown
            // Display selected currency
            if (selectedCurrency != null)
              Text(
                'Selected Currency: $selectedCurrency',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
              Navigator.pushNamed(context, '/terms'); // Navigate to terms page
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
