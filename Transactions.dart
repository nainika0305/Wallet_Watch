import 'package:flutter/material.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('transaction'), automaticallyImplyLeading: false),
      body: const Padding(
          padding: EdgeInsets.all(16), child: Text('transaction page')),
    );
  }
}
