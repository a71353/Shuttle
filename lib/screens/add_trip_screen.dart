import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTripScreen extends StatefulWidget {
  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();
  final _passengersController =
      TextEditingController(); // Adicionando o campo para número de passageiros.
  String? _assignedUser;
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  List<String> _availableUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableUsers(); // Carrega os utilizadores disponíveis ao iniciar a tela.
  }

  Future<void> _fetchAvailableUsers() async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/users/available');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final users = jsonDecode(response.body);
        print('Utilizadores disponíveis no Flutter: $users'); // LOG

        setState(() {
          _availableUsers = List<String>.from(users);
          _isLoadingUsers = false;
        });
      } else {
        throw Exception('Erro ao buscar utilizadores disponíveis');
      }
    } catch (error) {
      print('Erro: $error'); // LOG
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro ao buscar utilizadores do servidor')),
      );
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _submitTrip() async {
    final startLocation = _startController.text;
    final destination = _destinationController.text;
    final numPassengers = int.tryParse(
        _passengersController.text); // Valida o número de passageiros.

    if (startLocation.isEmpty ||
        destination.isEmpty ||
        _assignedUser == null ||
        numPassengers == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os campos são obrigatórios!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://10.0.2.2:3000/trips');
      final response = await http.post(
        url,
        body: jsonEncode({
          'start_location': startLocation,
          'destination': destination,
          'created_by': 'user1@example.com',
          'assigned_to': _assignedUser,
          'num_passengers': numPassengers, // Adiciona o número de passageiros.
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        Navigator.pop(context); // Voltar para a tela anterior.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? 'Erro ao criar a viagem')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao comunicar com o servidor')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Viagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _startController,
              decoration: const InputDecoration(labelText: 'Local de Partida'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destino'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passengersController,
              decoration:
                  const InputDecoration(labelText: 'Número de Passageiros'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : _availableUsers.isEmpty
                    ? const Text('Nenhum utilizador disponível')
                    : DropdownButton<String>(
                        value: _assignedUser,
                        hint: const Text('Selecionar Utilizador'),
                        onChanged: (value) {
                          setState(() {
                            _assignedUser = value;
                          });
                        },
                        items: _availableUsers.map((user) {
                          return DropdownMenuItem(
                            value: user,
                            child: Text(user),
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitTrip,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Criar Viagem'),
            ),
          ],
        ),
      ),
    );
  }
}
