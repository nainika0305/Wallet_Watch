import 'package:flutter/material.dart';

class Budgets extends StatefulWidget {
  const Budgets({super.key});

  @override
  State<Budgets> createState() => _BudgetsState();
}

class _BudgetsState extends State<Budgets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('budgets'), automaticallyImplyLeading: false),
      body: const Padding(
          padding: EdgeInsets.all(16), child: Text('Budgets page')),
    );
  }
}