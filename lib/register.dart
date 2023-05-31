import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/authservice.dart';
import 'package:tic_tac_toe/game.dart';
import 'package:tic_tac_toe/helpers.dart';
import 'package:tic_tac_toe/login.dart';
import 'package:tic_tac_toe/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  AuthService authService = AuthService();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'REGISTER',
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.contact_page)),
                            validator: (val) {
                              if (val!.isNotEmpty) {
                                return null;
                              } else {
                                return "Name cannot be empty";
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock)),
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password must be at least 6 characters";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                register();
                              },
                              child: const Text('Register')),
                          const SizedBox(
                            height: 10,
                          ),
                          Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Login now",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, const LoginPage());
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final String name = nameController.text;
      final String email = emailController.text;
      final String password = passwordController.text;
      await authService
          .registerUserWithEmailandPassword(name, email, password)
          .then((value) async {
        if (value == true) {
          //saving the shared preference state
          await HelperFunctions.saveUserloggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(name);
          nextScreenReplace(context, const GamePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }
}
