import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrearProfesionScreen extends StatefulWidget {
  const CrearProfesionScreen({Key? key}) : super(key: key);

  @override
  _CrearProfesionScreenState createState() => _CrearProfesionScreenState();
}

class _CrearProfesionScreenState extends State<CrearProfesionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  Future<void> _crearProfesion() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/administrador/crear_profesion/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'nombre_profesion': _nombreController.text,
          }),
        );

        if (response.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          _showError('Error al crear la profesión');
        }
      } catch (e) {
        _showError('Excepción al crear profesión: $e');
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Profesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre de la Profesión'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearProfesion,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
