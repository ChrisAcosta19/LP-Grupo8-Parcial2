import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditClienteScreen extends StatefulWidget {
  final dynamic cliente;

  const EditClienteScreen({Key? key, required this.cliente}) : super(key: key);

  @override
  _EditClienteScreenState createState() => _EditClienteScreenState();
}

class _EditClienteScreenState extends State<EditClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _correoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente['nombre']);
    _correoController = TextEditingController(text: widget.cliente['correo_electronico']);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _updateCliente() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:8000/usuarios/actualizar/${widget.cliente['id']}/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'nombre': _nombreController.text,
            'correo_electronico': _correoController.text,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, true); // Notificar que el cliente se actualizó
        } else {
          _showError('Error al actualizar el cliente');
        }
      } catch (e) {
        _showError('Excepción al actualizar cliente: $e');
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
        title: const Text('Editar Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un correo electrónico';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCliente,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
