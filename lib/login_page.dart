import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/forgot_password.dart';
import 'package:wallet_watch/register.dart';



class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  //controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Optionally navigate to another page after successful login
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else {
        errorMessage = 'Please fill all required fields';
      }

      // Show the error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFBCB6DE), // Very light lavender background
        body: SafeArea(
         child: Container(
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


            child: Center(

                child: Column(children: [
          const SizedBox(height: 150),
          //logo
          const Icon(
            Icons.account_balance_wallet,
            size: 100,
            color: Color(0xFFFDA4BA),
          ),
          const SizedBox(height: 25),

          // Hello again!
          const Text('Welcome back!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF003366),
              )),
          const SizedBox(height: 20),
          // email Textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDA4BA).withOpacity(0.35),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ), // BoxDecoration
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: _emailController, //get input that user inputs
                  decoration: InputDecoration(

                    border: InputBorder.none,
                    hintText: 'Email',

                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // password textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDA4BA).withOpacity(0.35),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ), // BoxDecoration
              child: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                  ),
                ),
              ),
            ),
          ),

                  const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ForgotPasswordPage();
                    },
                    ),
                    );
                    },
                  child: Text('Forgot Password?',
                    style: TextStyle(

                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,

                    ),),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //sign in button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: GestureDetector(
              onTap: signIn,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF73A5C6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Log In',
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
          // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ),
                  ],
                ),
        ])))));
  }
}
