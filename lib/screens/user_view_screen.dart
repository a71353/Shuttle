import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserViewScreen extends StatefulWidget {
  final String userEmail;

  const UserViewScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _UserViewScreenState createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  List<dynamic> _assignedTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedTrips();
  }

  Future<void> _fetchAssignedTrips() async {
    try {
      final url = Uri.parse(
        'http://192.168.1.69:3000/trips?assigned_to=${widget.userEmail}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _assignedTrips = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar viagens');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar viagens do servidor')),
      );
    }
  }

  Future<void> _completeTrip(int tripId) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/trips/$tripId/complete');
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viagem terminada com sucesso')),
        );
        setState(() {
          _assignedTrips.removeWhere((trip) => trip['id'] == tripId);
        });
      } else {
        throw Exception('Erro ao terminar a viagem');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao comunicar com o servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignedTrips.isEmpty
              ? const Center(child: Text('Nenhuma viagem atribuída.'))
              : ListView.builder(
                  itemCount: _assignedTrips.length,
                  itemBuilder: (context, index) {
                    final trip = _assignedTrips[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Destino: ${trip['destination']}'),
                        subtitle: Text('Partida: ${trip['start_location']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _completeTrip(trip['id']),
                          child: const Text('Terminar'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
