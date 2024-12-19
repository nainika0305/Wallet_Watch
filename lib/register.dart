import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String _passwordFeedbackMessage = '';
  Color _passwordFeedbackColor = Colors.red;

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

  Future signUp() async {
    if (_passwordConfirmed()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
          selectedCurrency ?? 'Not Selected',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'Please fill all fields';
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
      } else {
        _passwordFeedbackMessage = 'Password looks good!';
        _passwordFeedbackColor = Colors.green;
      }
    });
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool obscureText = false,
        void Function(String)? onChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDA4BA).withOpacity(0.35),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCB6DE),
      body: SafeArea(
        child: Container(
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),
                  Transform.translate(
                    offset: Offset(0, -80),
                    child: Image.asset(
                      'assests/Untitled_design-removebg-preview.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -60),
                    child: const Text(
                      'Register Here!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF003366),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -30),
                    child: _buildTextField(_firstNameController, 'First Name'),
                  ),

                  Transform.translate(
                    offset: Offset(0, -15),
                    child:  _buildTextField(_lastNameController, 'Last Name'),
                  ),

                  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 15),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        _passwordController,
                        'Password',
                        obscureText: true,
                        onChanged: checkPasswordStrength,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          _passwordFeedbackMessage,
                          style: TextStyle(
                            color: _passwordFeedbackColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    _confirmpasswordController,
                    'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: signUp,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF73A5C6),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a member?  ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text(
                          'Login now',
                          style: TextStyle(
                            color: Colors.blueAccent,
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
      ),
    );
  }
}
