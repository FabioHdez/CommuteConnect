//This page is rendered if the statefull variable showLoginPage from login_or_register_page.dart is set to false.
//tapping the "Log in now" link will trigger the onTap function which was passed as an argument
//from login_or_register_page.dart -> return RegisterPage(onTap: togglePages);

import 'package:commute_connect/components/my_button.dart';
import 'package:commute_connect/components/my_textfield.dart';
import 'package:commute_connect/components/square_tile.dart';
import 'package:commute_connect/services/auth_sercives.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

 
class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

 // Sign user up method
void signUserUp() async {
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  if (passwordController.text != confirmPasswordController.text) {
    Navigator.pop(context);
    showErrorMessage("Passwords don't match");
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    final databaseReference = FirebaseDatabase.instance.reference();

    // Define a default profile image URL - ensure this URL is publicly accessible or correctly hosted
    const defaultProfileImageUrl = 'https://example.com/path/to/default/nino-nakano-image.png';

    if (userCredential.user != null) {
      await databaseReference.child("users").child(userCredential.user!.uid).set({
        'username': emailController.text.substring(0, emailController.text.indexOf('@')),
        'bio': '',
        'profileImageUrl': defaultProfileImageUrl,  // Add default profile image URL here
      });
    }

    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showErrorMessage(e.code);
  }
}
  // error message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text("Error: " + message + "\nPlease try again."),
          ),
        );
      },
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                const Icon(
                  Icons.lock,
                  size: 50,
                ),
                const SizedBox(height: 50),

                //let's create an account for you
                Text(
                  'Let\'s create an account for you!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                //sign in button
                MyButton(
                  text: "Sign Up",
                  onTap: signUserUp,
                ),

                const SizedBox(height: 50),
                //or continue with

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                //google sign in button
                // If we decide to add more sign in methods: https://youtu.be/Dh-cTQJgM-Q?t=851
                 SquareTile(onTap:() => AuthService().googleSignIn(),
                imagePath: 'lib/images/google.png'),

                const SizedBox(height: 50),

                //not a member? register now

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )));
  }
}