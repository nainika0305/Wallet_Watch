import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Sorry page not routed properly .. go back to hi",
                textAlign: TextAlign.center),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/start');
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
