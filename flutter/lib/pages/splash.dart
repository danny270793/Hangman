import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/pages/login.dart';

class SplashPage extends StatefulWidget {
  static const String routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if(!context.mounted) {
        return;
      }
      
      context.replace(LoginPage.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash Page'),
      ),
    );
  }
}
