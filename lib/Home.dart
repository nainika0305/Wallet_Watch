import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/Tips.dart';
import 'package:wallet_watch/AddTransaction.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet_watch/goals.dart';

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
        } else {
          print("Document does not exist");
        }
      });
    } catch (e) {
      print("Error fetching total money: $e");
    }
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
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 20, 15),
        height: 300,
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                ),
                ElevatedButton(
                  onPressed: _pickDateRange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  child:  Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[200],
                    ),
                  ),
                ),

              ],
            ),
            SizedBox(height: 19),
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
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    if (selectedGraphType == 'Combined' || selectedGraphType == 'Income')
                      LineChartBarData(
                        spots: incomeSpots,
                        isCurved: false,
                        barWidth: 3,
                        color: Colors.green,
                      ),
                    if (selectedGraphType == 'Combined' || selectedGraphType == 'Expenses')
                      LineChartBarData(
                        spots: expenseSpots,
                        isCurved: false,
                        barWidth: 3,
                        color: Colors.red,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: Text(
          'Home',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF281E5D),
          ),
        ),
        backgroundColor: Color(0xFFD1A7D1),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFDBE9),
              Color(0xFFE6D8FF),
              Color(0xFFBDE0FE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
 const SizedBox(height: 20),
              SizedBox(
                width: 500,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFFECEDD),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Money:  ₹ ${totalMoney.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF281E5D).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              _buildGraph(),
              Row(
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 125,
                    height: 40,
                      child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGraphType = 'Combined';
                          _fetchGraphData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                       // padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                        backgroundColor: selectedGraphType == 'Combined'? Colors.white70 : Colors.white24,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                        elevation: 2,
                      ),
                      child: Text(
                        "Combined",
                        style: TextStyle(fontSize: 14, color: Colors.pink[200], fontWeight: FontWeight.bold),
                      ),
                    ),
                    ),


                  const SizedBox(height: 35),
                  SizedBox(
                    width: 125,
                    height: 40,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFF48FB1),
                              width: 2.0,  // Adjust the width as needed
                            ),
                          ),
                        ),
                        child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGraphType = 'Income';
                          _fetchGraphData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        //padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                        backgroundColor: selectedGraphType == 'Income' ? Colors.white70 : Colors.white24,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                        elevation: 2,
                      ),
                      child:  Text(
                        "Income",
                        style: TextStyle(fontSize: 14, color: Colors.pink[200], fontWeight: FontWeight.bold),
                      ),
                    ),
                    ),
                  ),
                  //const SizedBox(width: 12),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 125,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Color(0xFFF48FB1),
                          width: 2.0,  // Adjust the width as needed
                        ),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedGraphType = 'Expenses';
                          _fetchGraphData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        //padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                        backgroundColor: selectedGraphType == 'Expenses' ? Colors.white70: Colors.white24,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                        elevation: 2,
                      ),
                      child:  Text(
                        "Expenses",
                        style: TextStyle(fontSize: 14, color: Colors.pink[200], fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Text(motivationalQuote,
              style: TextStyle(
                fontSize: 23,
                letterSpacing: 1.1,
                color: Color(0xFF281E5D),
                  fontStyle: FontStyle.italic,
              ),),

              const SizedBox(height: 30),
              Column(
                children: [
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/transactions'
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                        backgroundColor: Color(0xFF73A5C6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "View Transactions",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 195,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Tips()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                            backgroundColor: Color(0xFF73A5C6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 12,
                          ),
                          child: const Text(
                            "Financial Tips",
                            style: TextStyle(
                                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 195,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GoalsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                            backgroundColor: Color(0xFF73A5C6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 12,
                          ),
                          child: const Text(
                            "Set Goals",
                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    ],
                  ),
                 const SizedBox(height: 30),

                  SizedBox(
                    width: 260,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                          MaterialPageRoute(builder: (context) => AddTransactionPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                       // padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                        backgroundColor: Color(0xFFFECEDD).withOpacity(0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),

                      icon: Icon(Icons.add,
                      color: Color(0xFF281E5D),),
                      label: const Text(
                        "Add Transactions",
                        style: TextStyle(
                          fontSize: 19,
                          color: Color(0xFF281E5D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),


                ],

              ),
            ],

          ),
        ),
      ),
    );
  }
}
