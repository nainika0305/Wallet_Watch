import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallet_watch/AddInsurance.dart';
import 'package:wallet_watch/AddLoans.dart';
import 'package:wallet_watch/AddSubscriptions.dart';
import 'package:wallet_watch/ChangeCurrency.dart';
import 'package:wallet_watch/CurrencyConversion.dart';
import 'package:wallet_watch/ExportReport.dart';
import 'package:wallet_watch/FAQs.dart';
import 'package:wallet_watch/Feedback.dart';
import 'package:wallet_watch/Loans.dart';
import 'package:wallet_watch/PageNotFound.dart';
import 'package:wallet_watch/Settings.dart';
import 'package:wallet_watch/Subscriptions.dart';
import 'package:wallet_watch/TaxEstimationTool.dart';
import 'package:wallet_watch/Tips.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/auth_page.dart';
import 'package:wallet_watch/goals.dart';
import 'package:wallet_watch/homepage.dart';
import 'package:wallet_watch/insurance.dart';
import 'package:wallet_watch/login_page.dart';
import 'package:wallet_watch/hi.dart';
import 'package:wallet_watch/privacypolicy.dart';
import 'package:wallet_watch/wrapper.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:wallet_watch/darkmode.dart';  // Import DarkModeProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final Map<String, WidgetBuilder> appRoutes = {
  '/terms': (context) => TermsAndConditions(),
  '/login': (context) => LoginPage(showRegisterPage: () {}),
  '/home': (context) => Homepage(),
  '/auth': (context) => AuthPage(),
  '/wrapper': (context) => MainPage(),
  '/tips': (context) => Tips(),
  '/goal': (context) => GoalsPage(),
  '/transactions': (context) => Transactions(),
  '/settings': (context) => Settings(),
  '/feedback': (context) => review(),
  '/changeCurrency': (context) => changeCurrency(),
  '/report': (context) => ExportReport(),
  '/tax': (context) => TaxEstimationTool(),
  '/faqs': (context) => FAQs(),
  '/conversion': (context) => CurrencyConversion(),
  '/Subscriptions': (context) => Subscriptions(),
  '/Loans': (context) => Loans(),
  '/insurance': (context) => Insurance(),
  '/addSubscription': (context) => Addsubscriptions(),
  '/addLoan': (context) => AddLoansPage(),
  '/addInsurance': (context) => AddInsurancePage(),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DarkModeProvider(),
      child: Builder(
        builder: (context) {
          // Get the current dark mode status
          final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

          return MaterialApp(
            title: 'Flutter Hi Page',
            theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HiPage(),
            routes: appRoutes,
            onUnknownRoute: (RouteSettings settings) {
              return MaterialPageRoute(builder: (context) => NotFound());
            },
          );
        },
      ),
    );
  }
}
