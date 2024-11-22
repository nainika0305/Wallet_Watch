import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HiPage extends StatefulWidget {
  const HiPage({super.key});

  @override
  _HiPageState createState() => _HiPageState();
}

class _HiPageState extends State<HiPage> {

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

            ElevatedButton(onPressed: () {
                  Navigator.pushNamed(context, '/wrapper');
                },
                child: Text("Next"),
            )


          ],
        ),
      ),
    );
  }
}