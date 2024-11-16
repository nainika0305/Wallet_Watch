import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallet_watch/PageNotFound.dart';
import 'package:wallet_watch/Tips.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/homepage.dart';
import 'package:wallet_watch/login_page.dart';
import 'package:wallet_watch/hi.dart';
import 'package:wallet_watch/privacypolicy.dart';
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

final Map<String, WidgetBuilder> appRoutes = {
  '/start': (context) => HiPage(),
  '/terms': (context) => TermsAndConditions(),
  '/login': (context) => LoginPage(),
  '/home': (context) => Homepage(),
  '/wrapper': (context) => MainPage(),
  '/tips': (context) => Tips(),
  '/transactions' : (context) => Transactions(),
};


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
      routes: appRoutes,
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (context) => NotFound());
      },
    );
  }
}
