import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrearProfesionalScreen extends StatefulWidget {
  @override
  _CrearProfesionalScreenState createState() => _CrearProfesionalScreenState();
}

class _CrearProfesionalScreenState extends State<CrearProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _direccionController = TextEditingController();

  List<Map<String, dynamic>> _profesiones = [];
  int? _selectedProfesionId;

  @override
  void initState() {
    super.initState();
    _fetchProfesiones();
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

  Future<void> _crearProfesional() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Crea el JSON que se enviará
      final jsonBody = jsonEncode({
        'usuario_nombre': _nombreController.text,
        'correo_electronico': _correoController.text,
        'contrasena': _contrasenaController.text,
        'profesion_id': _selectedProfesionId,  // Cambiado de nombre_profesion a profesion_id
        'direccion_ubicacion': _direccionController.text,
      });
    
      // Imprime el JSON en la consola
      print('JSON enviado: $jsonBody');

      final response = await http.post(
        Uri.parse('http://localhost:8000/administrador/profesionales/crear/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        print('Error al crear profesional');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Profesional'),
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
              TextFormField(
                controller: _contrasenaController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la contraseña';
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
                onPressed: _crearProfesional,
                child: Text('Crear Profesional'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
