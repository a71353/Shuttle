import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTripScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  EditTripScreen({required this.trip});

  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _startLocation;
  late String _destination;
  late int _numPassengers;

  @override
  void initState() {
    super.initState();
    _startLocation = widget.trip['start_location'];
    _destination = widget.trip['destination'];
    _numPassengers = widget.trip['num_passengers'];
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final url =
        Uri.parse('http://192.168.1.69:3000/trips/${widget.trip['id']}');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'start_location': _startLocation,
          'destination': _destination,
          'num_passengers': _numPassengers,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viagem atualizada com sucesso!')),
        );
        Navigator.pop(context); // Volta para a tela anterior
      } else {
        throw Exception('Erro ao atualizar viagem.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao comunicar com o servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Viagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _startLocation,
                decoration:
                    const InputDecoration(labelText: 'Local de Partida'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo é obrigatório';
                  }
                  return null;
                },
                onSaved: (value) => _startLocation = value!,
              ),
              TextFormField(
                initialValue: _destination,
                decoration: const InputDecoration(labelText: 'Destino'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo é obrigatório';
                  }
                  return null;
                },
                onSaved: (value) => _destination = value!,
              ),
              TextFormField(
                initialValue: _numPassengers.toString(),
                decoration:
                    const InputDecoration(labelText: 'Número de Passageiros'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Insira um número válido';
                  }
                  return null;
                },
                onSaved: (value) => _numPassengers = int.parse(value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTrip,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
