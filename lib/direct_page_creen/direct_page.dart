import 'package:flutter/material.dart';
import 'package:projeto_escola/utils/check_token.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectPageScreen extends StatefulWidget {
  const DirectPageScreen({super.key});

  @override
  State<DirectPageScreen> createState() => _DirectPageScreenState();
}

class _DirectPageScreenState extends State<DirectPageScreen> {
  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    _navigateBasedOnToken(token);
  }

  Future<void> _navigateBasedOnToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      final isValid = await TokenValidator(token).checkTokenValidity();
      if (isValid) {
        // Token válido, navegar para a tela home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        // Token inválido, navegar para a tela de login
        prefs.setString('access_token', '');

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/logo_app.png'),
              width: 300,
              height: 300,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
