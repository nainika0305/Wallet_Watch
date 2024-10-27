import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallet_watch/login_page.dart';
import 'package:wallet_watch/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //connect firebase and flutter
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hi Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: HiPage(),

    );
  }
}
