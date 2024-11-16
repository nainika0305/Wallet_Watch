import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HiPage extends StatefulWidget {
  const HiPage({super.key});

  @override
  _HiPageState createState() => _HiPageState();
}

class _HiPageState extends State<HiPage> {
  // cONTROLLER
  final _currencyController = TextEditingController();

  // List of currencies for the dropdown
  final List<String> currencies = ['USD', 'EUR', 'INR', 'JPY', 'GBP'];
  // Variable to store the selected currency
  String? selectedCurrency;

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save selected currency to Firestore
  Future<void> saveCurrencyToFirestore(String currency) async {
    try {
      // Replace with the collection and document structure you want
      await _firestore.collection('users').doc('currency').set({
        'currency': currency,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Currency saved to Firestore: $currency");
    } catch (e) {
      print("Error saving currency: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the quotation
            const Text(
              'Your wallet deserves the best — track it right',
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
                height: 40), // Add some space between the text and dropdown
            // Dropdown for currency selection
            DropdownButton<String>(
              hint: const Text('Select Currency'),
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
            const SizedBox(height: 20), // Add some space below the dropdown
            // Display selected currency
            if (selectedCurrency != null)
              Text(
                'Selected Currency: $selectedCurrency',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (selectedCurrency != null) {
                  // Save the selected currency to Firestore before navigating
                  saveCurrencyToFirestore(selectedCurrency!);

                  // Navigate to the terms page
                  Navigator.pushNamed(context, '/terms');
                } else {
                  // Show an error message if no currency is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a currency')),
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
