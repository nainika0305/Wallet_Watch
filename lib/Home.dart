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
            barRods: [BarChartRodData(toY: value, color: Colors.blue)],
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
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
                  child: Text(type),
                ))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _pickDateRange,
                child: Text(
                  'Select Date Range',
                  style: const TextStyle(fontSize: 14),
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
                            style: const TextStyle(fontSize: 12),
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
        title: const Text('Wallet Watch'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              motivationalQuote,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Money",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹ ${totalMoney.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildGraph(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Transactions()),
                );
              },
              child: const Text("View All Transactions"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tips()),
                );
              },
              child: const Text("Financial Tips"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTransactionPage()),
                );
              },
              child: const Text("Add Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
