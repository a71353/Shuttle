import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importa a página de login

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navega para a página de login após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adicione aqui o logo da empresa
            Image.asset(
              'assets/logo.png', // Certifique-se de adicionar o ficheiro do logo em 'assets' e definir no pubspec.yaml
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Shuttle',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
