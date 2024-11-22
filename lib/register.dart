import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Password Feedback Message and Style
  String _passwordFeedbackMessage = '';
  Color _passwordFeedbackColor = Colors.red;

  // Dropdown-related variables
  final List<String> currencies = ['USD', 'EUR', 'INR', 'JPY', 'GBP'];
  String? selectedCurrency;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Sign-Up Logic
  Future signUp() async {
    if (_passwordConfirmed()) {
      try {
        // Firebase Auth User Creation
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add User Details to Firestore
        await addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
          selectedCurrency ?? 'Not Selected',
        );

        // Navigate to Login or Next Page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),

        );



      } on FirebaseAuthException catch (e) {
        // Display appropriate error messages
        String message = 'An error occurred';
        if (e.code == 'email-already-in-use') {
          message = 'Email already in use. Please use a different email.';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format.';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future addUserDetails(
      String firstName,
      String lastName,
      String email,
      String currency,
      ) async {
    await FirebaseFirestore.instance.collection('users').add({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'currency': currency,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  bool _passwordConfirmed() {
    return _passwordController.text.trim() == _confirmpasswordController.text.trim();
  }

  void checkPasswordStrength(String password) {
    setState(() {
      if (password.length < 6) {
        _passwordFeedbackMessage = 'Password must be at least 6 characters long.';
        _passwordFeedbackColor = Colors.red;
      } else if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).+$')
          .hasMatch(password)) {
        _passwordFeedbackMessage =
        'Password must include uppercase, lowercase, a number, and a special character.';
        _passwordFeedbackColor = Colors.red;
      } else if (password.contains(_emailController.text.trim()) ||
          password.contains(_firstNameController.text.trim()) ||
          password.contains(_lastNameController.text.trim())) {
        _passwordFeedbackMessage = 'Password should not contain personal details.';
        _passwordFeedbackColor = Colors.red;
      } else {
        _passwordFeedbackMessage = 'Password looks good!';
        _passwordFeedbackColor = Colors.green;
      }
    });
  }

  // Custom TextField Builder
  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool obscureText = false,
        void Function(String)? onChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Logo
                const Icon(
                  Icons.android,
                  size: 100,
                ),
                const SizedBox(height: 25),
                // Title
                const Text(
                  'Hello There!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Register below with your details!',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 25),
                // First Name Field
                _buildTextField(_firstNameController, 'First Name'),
                const SizedBox(height: 15),
                // Last Name Field
                _buildTextField(_lastNameController, 'Last Name'),
                const SizedBox(height: 15),
                // Email Field
                _buildTextField(_emailController, 'Email'),
                const SizedBox(height: 15),
                // Currency Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    hint: const Text('Select Currency'),
                    items: currencies
                        .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Password Field with Feedback
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      _passwordController,
                      'Password (min 6 chars)',
                      obscureText: true,
                      onChanged: checkPasswordStrength,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text(
                        _passwordFeedbackMessage,
                        style: TextStyle(
                          color: _passwordFeedbackColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Confirm Password Field
                _buildTextField(
                  _confirmpasswordController,
                  'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                // Sign-Up Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Redirect to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'I am a member!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text(
                        ' Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
