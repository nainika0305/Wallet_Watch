import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Function to add a new goal for the current user
  Future<void> _addGoal() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('goals')
            .add({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal added successfully!')),
        );

        _titleController.clear();
        _descriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add goal')),
        );
      }
    }
  }

  // Function to delete a goal
  Future<void> _deleteGoal(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('goals')
          .doc(id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete goal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Goals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
        backgroundColor: const Color(0xFFCDB4DB),  // Updated color here
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

    child:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Section
            const Text(
              'Set your goals and track them!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),  // Updated color here
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Form to add a new goal
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      labelStyle: TextStyle(color: Color(0xFF003366)),
                      filled: true, // To fill the background with color
                      fillColor: Color(0xFFFDA4BA).withOpacity(0.15),
                      hintText: 'Enter your goal title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                      ),

                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a goal title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Goal Description',
                      labelStyle: TextStyle(color: Color(0xFF003366)),
                      filled: true, // To fill the background with color
                      fillColor: Color(0xFFFDA4BA).withOpacity(0.15),
                      hintText: 'Describe your goal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a goal description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _addGoal,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: const Color(0xFFBDE0FE),  // Text color to black
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),  // Bigger button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),  // Slightly rounded corners
                      ),
                      elevation: 5,  // Add elevation for shadow
                    ),
                    child: const Text(
                      'Add Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(
              thickness: 3,
              color: Colors.black,
            ),

            // Display Goals Section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_currentUserId)
                    .collection('goals')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No goals yet! Add your first goal.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  final goals = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            goal['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(goal['description']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGoal(goal.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
