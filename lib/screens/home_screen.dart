import 'package:flutter/material.dart';
import 'admin_view_screen.dart';
import 'user_view_screen.dart';

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: email == 'user1@example.com'
          ? AdminView()
          : ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserViewScreen(userEmail: email),
                  ),
                );
              },
              child: const Text('Ver Minhas Viagens'),
            ),
    );
  }
}
