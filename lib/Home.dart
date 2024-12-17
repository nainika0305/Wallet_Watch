import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/Tips.dart';
import 'package:wallet_watch/AddTransaction.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String motivationalQuote = "Believe in yourself and your goals!";
  double totalMoney = 0.0;
  String selectedGraphType = "Combined";
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  List<BarChartGroupData> graphData = [];

  @override
  void initState() {
    super.initState();
    _fetchTotalMoney();
    _fetchGraphData();
  }

  Future<void> _fetchTotalMoney() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('userId') // Replace with dynamic user ID
          .get();

      setState(() {
        totalMoney = doc.data()?['totalMoney'] ?? 0.0;
      });
    } catch (e) {
      print("Error fetching total money: $e");
    }
  }

  Future<void> _fetchGraphData() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: 'userId') // Replace with dynamic user ID
          .where('date', isGreaterThanOrEqualTo: fromDate)
          .where('date', isLessThanOrEqualTo: toDate)
          .get();

      List<Map<String, dynamic>> transactions = query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      Map<String, double> groupedData = {};
      for (var transaction in transactions) {
        String dateKey = DateFormat('yyyy-MM-dd').format(transaction['date'].toDate());
        double amount = transaction['amount'];

        if (selectedGraphType == 'Income' && transaction['type'] == 'Income') {
          groupedData[dateKey] = (groupedData[dateKey] ?? 0) + amount;
        } else if (selectedGraphType == 'Expenses' && transaction['type'] == 'Expense') {
          groupedData[dateKey] = (groupedData[dateKey] ?? 0) + amount;
        } else if (selectedGraphType == 'Combined') {
          groupedData[dateKey] = (groupedData[dateKey] ?? 0) + amount;
        }
      }

      List<BarChartGroupData> barData = [];
      int x = 0;
      groupedData.forEach((key, value) {
        barData.add(
          BarChartGroupData(
            x: x,
            barRods: [BarChartRodData(toY: value, color: Colors.pink[400]!)],
          ),
        );
        x++;
      });

      setState(() {
        graphData = barData;
      });
    } catch (e) {
      print("Error fetching graph data: $e");
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
                child: Text(
                  'Select Date Range',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: graphData,
                borderData: FlBorderData(show: true),
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
        title: const Text('Wallet Watch', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.pink[400],
        elevation: 12,
        shadowColor: Colors.pink[100],
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
