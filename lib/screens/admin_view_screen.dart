import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'edit_trip_screen.dart';
import 'add_trip_screen.dart'; // Importa a tela de adicionar viagens

class AdminView extends StatefulWidget {
  @override
  _AdminTripsScreenState createState() => _AdminTripsScreenState();
}

class _AdminTripsScreenState extends State<AdminView> {
  bool _showPendingTrips =
      true; // Alterna entre viagens pendentes e concluídas.
  bool _isLoading = false;
  List<dynamic> _trips = []; // Armazena as viagens.

  @override
  void initState() {
    super.initState();
    _fetchTrips(); // Carrega as viagens ao iniciar.
  }

  Future<void> _fetchTrips() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'http://192.168.1.69:3000/trips/${_showPendingTrips ? 'pending' : 'completed'}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _trips = jsonDecode(response.body);
        });
      } else {
        throw Exception('Erro ao buscar viagens');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar viagens do servidor')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleTripsView() {
    setState(() {
      _showPendingTrips = !_showPendingTrips;
    });
    _fetchTrips();
  }

  void _editTrip(dynamic trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(trip: trip),
      ),
    ).then((_) => _fetchTrips()); // Recarrega as viagens após a edição.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Viagens'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _showPendingTrips ? null : _toggleTripsView,
                child: const Text('Viagens em Execução'),
              ),
              ElevatedButton(
                onPressed: !_showPendingTrips ? null : _toggleTripsView,
                child: const Text('Viagens Concluídas'),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                    ? const Center(child: Text('Nenhuma viagem encontrada'))
                    : ListView.builder(
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          return ListTile(
                            title: Text(
                                '${trip['start_location']} -> ${trip['destination']}'),
                            subtitle:
                                Text('Passageiros: ${trip['num_passengers']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTrip(trip),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de criação de viagens
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTripScreen()),
          ).then(
              (_) => _fetchTrips()); // Atualiza a lista após criar uma viagem
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add), // Ícone de adicionar
      ),
    );
  }
}
