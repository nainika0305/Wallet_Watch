import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConversion extends StatefulWidget {
  const CurrencyConversion({super.key});

  @override
  State<CurrencyConversion> createState() => _CurrencyConversionState();
}

class _CurrencyConversionState extends State<CurrencyConversion> {
  final TextEditingController _amountController = TextEditingController();
  String? _fromCurrency = 'USD';
  String? _toCurrency = 'EUR';
  double? _convertedAmount;
  Map<String, dynamic> _exchangeRates = {};

  // Predefined list of 20 major currencies
  List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'INR', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK',
    'NZD', 'MXN', 'SGD', 'HKD', 'NOK', 'KRW', 'TRY', 'RUB', 'ZAR', 'BRL'
  ];

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates(); // Fetch rates initially
  }

  Future<void> _fetchExchangeRates() async {
    final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$_fromCurrency'));

    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        _exchangeRates = data['rates'];  // Store the exchange rates for future calculations
      });
    } else {
      // Handle error if the API request fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load currency data')),
      );
    }
  }

  void _convertCurrency() {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final fromRate = _exchangeRates[_fromCurrency];
    final toRate = _exchangeRates[_toCurrency];

    if (fromRate != null && toRate != null) {
      setState(() {
        _convertedAmount = (amount / fromRate) * toRate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: Colors.black, // Lighter pink color
          ),),
        backgroundColor: const Color(0xFFCDB4DB),  // Changed the color here
      ),
    body: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
      colors: [
      Color(0xFFFFDBE9),
      Color(0xFFE6D8FF), // Very light lavender
      Color(0xFFBDE0FE), // Very light blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      ),
      ),

    child:  Padding(
        padding:  EdgeInsets.all(25.0),
        child: ListView(
          children: [

            const SizedBox(height: 30),

            // Amount Input Field
            TextField(
              controller: _amountController,
              decoration:  InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Color(0xFF003366)),
                filled: true, // To fill the background with color
                fillColor: Color(0xFFFDA4BA).withOpacity(0.15),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _convertCurrency(),
            ),
            const SizedBox(height: 30),

            // From Currency Dropdown
            Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFDA4BA).withOpacity(0.15), // Set your desired background color
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 1, // Border thickness
                  ),
                ),
            child: DropdownButton<String>(
              value: _fromCurrency,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _fromCurrency = newValue;
                  _fetchExchangeRates();  // Fetch new rates when fromCurrency changes
                  _convertCurrency();
                });
              },
              items: _currencies
                  .map((currency) => DropdownMenuItem(
                value: currency,
                child: Text(currency),
              ))
                  .toList(),
            ),
            ),
            const SizedBox(height: 30),

            // To Currency Dropdown
            Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFDA4BA).withOpacity(0.15), // Set your desired background color
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 1, // Border thickness
                  ),
                ),
                child:DropdownButton<String>(
              value: _toCurrency,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _toCurrency = newValue;
                  _convertCurrency();
                });
              },
              items: _currencies
                  .map((currency) => DropdownMenuItem(
                value: currency,
                child: Text(currency),
              ))
                  .toList(),
            ),
            ),
            const SizedBox(height: 20),

            // Converted Amount
            if (_convertedAmount != null)
              Text(
                'Converted Amount: ${_convertedAmount!.toStringAsFixed(2)} $_toCurrency',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),  // Changed the color here
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),

            // Refresh Button
            ElevatedButton(
              onPressed: _fetchExchangeRates,
              child: const Text('Refresh Rates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFFBDE0FE),  // Changed the color here
                textStyle: const TextStyle(fontSize: 14),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(
              color: Colors.black,
              width: 1,
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
