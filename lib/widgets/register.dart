import 'package:flutter/material.dart';
import 'package:khel_yuva/widgets/custom_text_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController branch = TextEditingController();
  final TextEditingController rollno = TextEditingController();

  void _registerUser() {
    final String emailText = email.text.trim();
    final String passwordText = password.text.trim();
    final String confirmPasswordText = confirmPassword.text.trim();

    if (emailText.isEmpty ||
        passwordText.isEmpty ||
        confirmPasswordText.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    if (passwordText != confirmPasswordText) {
      _showMessage('Passwords do not match.');
      return;
    }

    _showMessage('Registration successful!');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    branch.dispose();
    rollno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'KHELYUVA',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 13, 39, 68),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Center(
                child: Text(
                  "Create An Account",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 30,
                    color: const Color.fromARGB(255, 13, 43, 68),
                  ),
                ),
              ),
            ),
            CustomTextInput(
              controller: name,
              icon: const Icon(Icons.person),
              hint: 'Enter your full name',
              isObscure: false,
            ),
            CustomTextInput(
              controller: email,
              icon: const Icon(Icons.email),
              hint: 'Enter your email',
              isObscure: false,
            ),
            CustomTextInput(
              controller: password,
              icon: const Icon(Icons.password),
              hint: 'Enter your password',
              isObscure: true,
            ),
            CustomTextInput(
              controller: confirmPassword,
              icon: const Icon(Icons.password),
              hint: 'Confirm your password',
              isObscure: true,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 13, 43, 68),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _registerUser,
                  child: const Text('Sign Up'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
