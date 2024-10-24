import 'package:flutter/material.dart';
import 'package:wallet_watch/auth/authenticate.dart';
//import 'package:wallet_watch/hi.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //either return login or dashboard
    return const Auth();
  }
}
