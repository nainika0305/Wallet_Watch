import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< Updated upstream
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/homepage.dart';
import 'package:wallet_watch/login_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
=======
import 'package:wallet_watch/auth/auth_page.dart';
import 'package:wallet_watch/homepage.dart';
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Homepage();
              }
              else {
                return LoginPage();
              }
            }
        )
    );
=======
      body: StreamBuilder<User?>(
          stream: FirebaseAuth. instance.authStateChanges(),
          builder: (context, snapshot) {
    if (snapshot.hasData) {
    return Homepage();
    } else {
    return AuthPage();
    }
    },
    ), // StreamBuilder
    ); // Scaffold
>>>>>>> Stashed changes
  }
}
