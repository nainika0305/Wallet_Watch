import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/Tips.dart';
import 'package:wallet_watch/AddTransaction.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final userId = FirebaseAuth.instance.currentUser!.email; // user id

  String motivationalQuote = "Believe in yourself and your goals!";
  double totalMoney = 0.0;
  String selectedGraphType = "Combined";
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  List<FlSpot> incomeSpots = [];
  List<FlSpot> expenseSpots = [];
  List<String> xAxisLabels = [];

  @override
  void initState() {
    super.initState();
    _fetchTotalMoney();
    _fetchGraphData();
  }

  Future<void> _fetchTotalMoney() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((docSnapshot) {
        if (docSnapshot.exists) {
          setState(() {
            totalMoney = (docSnapshot.data()?['totalMoney'] ?? 0).toDouble();
          });
        }
      });
    } catch (e) {
      print("Error fetching total money: $e");
    }
  }

  Future<void> _fetchGraphData() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: fromDate)
          .where('date', isLessThanOrEqualTo: toDate)
          .get();

      List<Map<String, dynamic>> transactions =
      query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      Map<String, double> incomeData = {};
      Map<String, double> expenseData = {};

      for (var transaction in transactions) {
        DateTime transactionDate;
        if (transaction['date'] is String) {
          transactionDate = DateTime.parse(transaction['date']);
        } else {
          transactionDate = (transaction['date'] as Timestamp).toDate();
        }

        String dateKey = DateFormat('yyyy-MM-dd').format(transactionDate);
        double amount = transaction['amount'];

        if (transaction['type'] == 'Income') {
          incomeData[dateKey] = (incomeData[dateKey] ?? 0) + amount;
        } else if (transaction['type'] == 'Expense') {
          expenseData[dateKey] = (expenseData[dateKey] ?? 0) + amount;
        }
      }

      List<DateTime> allDates = [];
      for (var i = 0; i <= toDate.difference(fromDate).inDays; i++) {
        allDates.add(fromDate.add(Duration(days: i)));
      }

      xAxisLabels = allDates.map((date) {
        int day = date.day;
        String suffix = getDaySuffix(day);
        String formattedDate = DateFormat('d MMM').format(date);
        return formattedDate.replaceFirst(day.toString(), '$day$suffix');
      }).toList();

      incomeSpots = _generateSpots(allDates, incomeData);
      expenseSpots = _generateSpots(allDates, expenseData);

      setState(() {});
    } catch (e) {
      print("Error fetching graph data: $e");
    }
  }

  List<FlSpot> _generateSpots(List<DateTime> allDates, Map<String, double> data) {
    return allDates.map((date) {
      String dateKey = DateFormat('yyyy-MM-dd').format(date);
      double amount = data[dateKey] ?? 0.0;
      return FlSpot(date.day.toDouble(), amount);
    }).toList();
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
        _fetchGraphData();
      });
    }
  }

  Widget _buildGraph() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFCDB4DB), const Color(0xFFBDE0FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 7,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedGraphType,
                onChanged: (value) {
                  setState(() {
                    selectedGraphType = value!;
                    _fetchGraphData();
                  });
                },
                items: ['Income', 'Expenses', 'Combined']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _pickDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA2D2FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Select Date Range',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  if (selectedGraphType == 'Combined' ||
                      selectedGraphType == 'Income')
                    LineChartBarData(
                      spots: incomeSpots,
                      color: Colors.green,
                    ),
                  if (selectedGraphType == 'Combined' ||
                      selectedGraphType == 'Expenses')
                    LineChartBarData(
                      spots: expenseSpots,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Widget page) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC8DD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              motivationalQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildGraph(),
            const SizedBox(height: 30),
            _buildButton("View Transactions", Transactions()),
            _buildButton("Financial Tips", Tips()),
            _buildButton("Add Transaction", AddTransactionPage()),
          ],
        ),
      ),
    );
  }
}
