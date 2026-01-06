import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/pages/home.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go(HomePage.routeName);
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
