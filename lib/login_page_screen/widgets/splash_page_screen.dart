import 'package:flutter/material.dart';
import 'package:projeto_escola/utils/routes.dart';

class SplashPageScreen extends StatelessWidget {
  const SplashPageScreen({super.key});

  Future<bool> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tela de carregamento com imagem e CircularProgressIndicator
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
        } else {
          // Quando o Future é completado, navega para a próxima tela
          if (snapshot.hasData && snapshot.data == true) {
            // Usa WidgetsBinding.instance.addPostFrameCallback para garantir que a navegação ocorra após o build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (route) => false);
            });
          }

          // Retorna um widget vazio enquanto aguarda a navegação
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
      },
    );
  }
}
