
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

  // for printing
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

  // display transactiosn
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
        // Ensure the date is properly parsed if it's a string
        DateTime transactionDate;
        if (transaction['date'] is String) {
          transactionDate = DateTime.parse(transaction['date']);
        } else {
          // If it's already a Timestamp, convert it to DateTime
          transactionDate = (transaction['date'] as Timestamp).toDate();
        }

        String dateKey = DateFormat('yyyy-MM-dd').format(transactionDate); // Format the date as key
        double amount = transaction['amount'];

        if (transaction['type'] == 'Income') {
          incomeData[dateKey] = (incomeData[dateKey] ?? 0) + amount;
        } else if (transaction['type'] == 'Expense') {
          expenseData[dateKey] = (expenseData[dateKey] ?? 0) + amount;
        }
      }

      print("income data, $incomeData");
      print("expense data, $expenseData");

      // Generate x-axis labels and map to FlSpot points
      List<DateTime> allDates = [];
      for (var i = 0; i <= toDate.difference(fromDate).inDays; i++) {
        allDates.add(fromDate.add(Duration(days: i)));
      }

      xAxisLabels = allDates.map((date) {
        int day = date.day;
        String suffix = getDaySuffix(day);  // Ensure this function is correct
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

// Helper function to generate spots
  List<FlSpot> _generateSpots(List<DateTime> allDates, Map<String, double> data) {
    return allDates.map((date) {
      String dateKey = DateFormat('yyyy-MM-dd').format(date);
      double amount = data[dateKey] ?? 0.0;
      return FlSpot(date.day.toDouble(), amount);  // Use day as x-axis value
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

  // grpah
  Widget _buildGraph() {
    return
      SizedBox(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10,10,20, 15)
          ,
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
              // combined etc
              SizedBox(

              child: Container(
              child: DropdownButton<String>(
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
                    .toList(),
              ),
              ),
              ),

              // slect range
              ElevatedButton(
                onPressed: _pickDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[200],
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Select Date Range',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                                style: const TextStyle(fontSize: 10,
                                  // fontWeight: FontWeight.bold
                                  ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide left axis titles (y-axis)
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide top axis titles
                    ),
                  ),
                  gridData: FlGridData(show: false), // Hide grid lines
                  borderData: FlBorderData(show: true), // Optionally show the border
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
                )
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
        centerTitle: true,
        title:Text(
          motivationalQuote,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF281E5D)
           ),
        ),
        backgroundColor:  Color(0xFF2832C2).withOpacity(0.5),
      ),

      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFDBE9),
                Color(0xFFE6D8FF), // Very light lavender
                Color(0xFFBDE0FE), // Very light blue
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

            // Total Money Section
            SizedBox(
              width: 300,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    //Color(0xFFBDE0FE),
                    Color(0xFFE0B0FF).withOpacity(0.6),
                    Color(0xFF2832C2).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                   Text(
                    "Total Money",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF281E5D).withOpacity(0.7),
                    ),
                  ),
                  const Divider(
                    thickness: 4,
                    color: Colors.black54,
                  ),
                  Text(
                    "₹ ${totalMoney.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 32,
                     // fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ),


            // graph
            const SizedBox(height: 35),
            _buildGraph(),


            //buttons
            const SizedBox(height: 35),
            // Compact Buttons and Neatly Aligned
            Column(

              children: [
                SizedBox(
                  width: 275, // Set the desired width
                  child:
                  ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Transactions()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                    backgroundColor:  Color(0xFFE0B0FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 12,
                  ),
                  child: const Text(
                    "View Transactions",
                    style: TextStyle(
                        fontSize: 19,
                        color: Color(0xFF281E5D),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                    width: 275,
                  child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Tips()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                    backgroundColor: Color(0xFF0492C2).withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 12,
                  ),
                  child: const Text(
                    "Financial Tips",
                    style: TextStyle(fontSize: 19,
                        color: Color(0xFF281E5D),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ),


                const SizedBox(height: 20),
                SizedBox(
                  width: 275,
                  child: ElevatedButton(
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
                    style: TextStyle(fontSize: 19,
                        color: Color(0xFF281E5D),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ),


              ],
            ),
            SizedBox(height: 40),
          ],
        ),
        ),
      ),
    );
  }
}
