//If the user is not logged in they will be redirected here from the auth_page.
//Then from here it will render either the register page or the login page depending on showLoginPage.
//togglePages() changes this stateful variable and will trigger a rebuild of the page. 

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegisterPage> {
  // intially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
