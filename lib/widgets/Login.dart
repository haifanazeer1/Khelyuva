import 'package:flutter/material.dart';
import 'package:khel_yuva/widgets/custom_text_input.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'KhelYuva',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 94, 138),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Welcome to KhelYuva!",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 30,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Play',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: const Color.fromARGB(255, 13, 43, 68),
              ),
            ),
            const SizedBox(height: 20),

            /// Google Button
            /*Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: 250,
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/google.png',
                        width: 24,
                        height: 15,
                      ),
                      const SizedBox(width: 8),
                      const Text('Sign in with Google'),
                    ],
                  ),
                ),
              ),
            ),*/

            /// Email
            CustomTextInput(
              controller: _email,
              icon: const Icon(Icons.email),
              hint: 'Enter your email',
              isObscure: false,
            ),

            /// Password
            CustomTextInput(
              controller: _password,
              icon: const Icon(Icons.password),
              hint: 'Enter your password',
              isObscure: true,
            ),

            const SizedBox(height: 20),

            /// Sign In Button (No Backend)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 13, 43, 68),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text('Sign in'),
                ),
              ),
            ),

            const Text('Don’t have an account?'),

            const SizedBox(height: 10),

            /// Register Button (No Backend)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 43, 68),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: const Text('Register here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
