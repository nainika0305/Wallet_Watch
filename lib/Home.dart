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
      // Listen to real-time updates for the user's totalMoney field
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((docSnapshot) {
        if (docSnapshot.exists) {
          setState(() {
            totalMoney = (docSnapshot.data()?['totalMoney'] ?? 0).toDouble();
          });
        } else {
          print("Document does not exist");
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

      List<Map<String, dynamic>> transactions = query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      Map<String, double> incomeData = {};
      Map<String, double> expenseData = {};
      for (var transaction in transactions) {
        String dateKey = DateFormat('yyyy-MM-dd').format(transaction['date'].toDate());
        double amount = transaction['amount'];

        if (transaction['type'] == 'Income') {
          incomeData[dateKey] = (incomeData[dateKey] ?? 0) + amount;
        } else if (transaction['type'] == 'Expense') {
          expenseData[dateKey] = (expenseData[dateKey] ?? 0) + amount;
        }
      }

      // Generate x-axis labels and map to FlSpot points
      List<DateTime> allDates = [];
      for (var i = 0; i <= toDate.difference(fromDate).inDays; i++) {
        allDates.add(fromDate.add(Duration(days: i)));
      }

      xAxisLabels = allDates.map((date) => DateFormat('MM-dd').format(date)).toList();
      incomeSpots = _generateSpots(allDates, incomeData);
      expenseSpots = _generateSpots(allDates, expenseData);

      setState(() {});
    } catch (e) {
      print("Error fetching graph data: $e");
    }
  }

  List<FlSpot> _generateSpots(List<DateTime> allDates, Map<String, double> data) {
    return allDates
        .asMap()
        .entries
        .map((entry) {
      int index = entry.key;
      DateTime date = entry.value;
      String dateKey = DateFormat('yyyy-MM-dd').format(date);
      return FlSpot(index.toDouble(), data[dateKey] ?? 0.0);
    })
        .toList();
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
          colors: [Colors.pink[50]!, Colors.pink[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
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
                    style: TextStyle(
                      color: Colors.pink[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _pickDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[200],
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < xAxisLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              xAxisLabels[index],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  if (selectedGraphType == 'Combined' || selectedGraphType == 'Income')
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                    ),
                  if (selectedGraphType == 'Combined' || selectedGraphType == 'Expenses')
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      barWidth: 3,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              motivationalQuote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink[600]),
            ),
            const SizedBox(height: 20),
            // Total Money Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink[300]!, Colors.pink[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Money",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹ ${totalMoney.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildGraph(),
            const SizedBox(height: 30),
            // Compact Buttons and Neatly Aligned
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Transactions()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                    backgroundColor: Colors.pink[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 12,
                  ),
                  child: const Text(
                    "View Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Tips()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                    backgroundColor: Colors.pink[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 12,
                  ),
                  child: const Text(
                    "Financial Tips",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTransactionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                    backgroundColor: Colors.pink[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 12,
                  ),
                  child: const Text(
                    "Add Transaction",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
