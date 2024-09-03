import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfesionScreen extends StatefulWidget {
  final dynamic profesion;

  const EditProfesionScreen({Key? key, required this.profesion}) : super(key: key);

  @override
  _EditProfesionScreenState createState() => _EditProfesionScreenState();
}

class _EditProfesionScreenState extends State<EditProfesionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.profesion['nombre_profesion']);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _updateProfesion() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:8000/administrador/actualizar_profesion_admin/${widget.profesion['id']}/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'nombre_profesion': _nombreController.text,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, true);
        } else {
          _showError('Error al actualizar la profesión');
        }
      } catch (e) {
        _showError('Excepción al actualizar profesión: $e');
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
        title: const Text('Modificar Profesión'),
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
                onPressed: _updateProfesion,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
