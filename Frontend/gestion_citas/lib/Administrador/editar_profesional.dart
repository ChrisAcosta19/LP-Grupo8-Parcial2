import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditarProfesionalScreen extends StatefulWidget {
  final int profesionalId;

  EditarProfesionalScreen({required this.profesionalId});

  @override
  _EditarProfesionalScreenState createState() => _EditarProfesionalScreenState();
}

class _EditarProfesionalScreenState extends State<EditarProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();

  List<Map<String, dynamic>> _profesiones = [];
  int? _selectedProfesionId;

  @override
  void initState() {
    super.initState();
    _fetchProfesiones();
    _fetchProfesionalDetails();
  }

  Future<void> _fetchProfesiones() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/profesiones/lista/'));
    if (response.statusCode == 200) {
      setState(() {
        _profesiones = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Error al cargar profesiones');
    }
  }

  Future<void> _fetchProfesionalDetails() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/administrador/profesionales/${widget.profesionalId}/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nombreController.text = data['usuario_nombre'];
        _correoController.text = data['correo_electronico'];
        _direccionController.text = data['direccion_ubicacion'];
        _selectedProfesionId = data['profesion_id'];
      });
    } else {
      print('Error al cargar detalles del profesional');
    }
  }

  Future<void> _editarProfesional() async {
    if (_formKey.currentState?.validate() ?? false) {
      final jsonBody = jsonEncode({
        'usuario_nombre': _nombreController.text,
        'correo_electronico': _correoController.text,
        'profesion_id': _selectedProfesionId,
        'direccion_ubicacion': _direccionController.text,
      });

      final response = await http.put(
        Uri.parse('http://localhost:8000/administrador/profesionales/modificar/${widget.profesionalId}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Error al editar profesional');
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Profesional'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el correo electrónico';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedProfesionId,
                items: _profesiones.map((profesion) {
                  return DropdownMenuItem<int>(
                    value: profesion['id'],
                    child: Text(profesion['nombre_profesion']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfesionId = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Nombre de Profesión'),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una profesión';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección de Ubicación'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarProfesional,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
