import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Subscriptions extends StatelessWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.email; // User ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Subscriptions',
          style: TextStyle(
            fontWeight: FontWeight.w600, // Make title bold
            color: Colors.black, // Lighter pink color
          ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor:  Color(0xFFD1A7D1).withOpacity(0.9),
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

        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Divider(),
          Expanded(

            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('Subscriptions')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading subscriptions.'),
                  );
                }
                final subscriptions = snapshot.data?.docs ?? [];
                if (subscriptions.isEmpty) {
                  return const Center(
                    child: Text('No subscriptions added yet.'),
                  );
                }

                return ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final subscription = subscriptions[index];
                    final data = subscription.data() as Map<String, dynamic>;
                    final startDate = DateTime.parse(data['startDate']);
                    final currentDate = DateTime.now();

                    // Calculate the current billing cycle's start date
                    final currentCycleStart = DateTime(
                      currentDate.year,
                      currentDate.month,
                      startDate.day,
                    ).isBefore(currentDate)
                        ? DateTime(currentDate.year, currentDate.month, startDate.day)
                        : DateTime(currentDate.year, currentDate.month - 1, startDate.day);

                    // Calculate the next payment date for the current cycle
                    final nextPaymentDate =
                    currentCycleStart.add(const Duration(days: 30));

                    // Calculate days remaining and progress
                    final daysRemaining =
                        nextPaymentDate.difference(currentDate).inDays;
                    final progress = (currentDate
                        .difference(currentCycleStart)
                        .inDays /
                        30)
                        .clamp(0.0, 1.0);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(data['platform'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF281E5D), // Dark blue for contrast
                            )),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount: \₹${data['amount']}'),
                            Text(
                                'Next Payment: ${DateFormat('yyyy-MM-dd').format(nextPaymentDate)}'),
                            Text(
                                'Days Remaining: ${daysRemaining > 0 ? daysRemaining : 0}'),
                            LinearProgressIndicator(
                              value: progress,
                              color: progress < 1.0
                                  ? Colors.green
                                  : Colors.red, // Green for ongoing, red for overdue
                              backgroundColor: Colors.grey[300],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await subscription.reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Subscription deleted')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/addSubscription');
                },
                icon: Icon(Icons.add, color: Colors.white,),
                label: Text('Add Subscription',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 17,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF2832C2).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    ),
    );
  }
}

