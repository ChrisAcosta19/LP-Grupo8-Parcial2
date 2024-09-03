import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrearProfesionalScreen extends StatefulWidget {
  @override
  _CrearProfesionalScreenState createState() => _CrearProfesionalScreenState();
}

class _CrearProfesionalScreenState extends State<CrearProfesionalScreen> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _direccionController = TextEditingController();
  String? _selectedProfesion;
  List<dynamic> _profesiones = [];

  @override
  void initState() {
    super.initState();
    _loadProfesiones();
  }

  Future<void> _loadProfesiones() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/profesiones/lista/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _profesiones = jsonDecode(response.body);
      });
    } else {
      print('Error al cargar profesiones');
    }
  }

  Future<void> _guardarProfesional() async {
    // Verificar que todos los campos obligatorios estén llenos
    if (_nombreController.text.isEmpty || _correoController.text.isEmpty || _contrasenaController.text.isEmpty || _selectedProfesion == null) {
      print('Por favor complete todos los campos');
      return;
    }

    // Primero, crear el usuario
    final usuarioResponse = await http.post(
      Uri.parse('http://localhost:8000/usuarios/crear_profesional/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nombre': _nombreController.text,
        'correo_electronico': _correoController.text,
        'contrasena': _contrasenaController.text,
        'rol': 'Profesional',
      }),
    );

    if (usuarioResponse.statusCode == 201) {
      // Buscar el ID del usuario creado
      final nombreUsuario = _nombreController.text;
      final idResponse = await http.get(
        Uri.parse('http://localhost:8000/usuarios/obtener_id/?nombre=$nombreUsuario'),
      );

      if (idResponse.statusCode == 200) {
        final usuarioId = jsonDecode(idResponse.body)['id'];

        // Crear el registro en profesionales_profesional
        final profesionId = _profesiones.firstWhere((p) => p['nombre_profesion'] == _selectedProfesion)['id'];
        final profesionalesResponse = await http.post(
          Uri.parse('http://localhost:8000/usuarios/asignar_profesion/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'profesion_id': profesionId,
            'usuario_id': usuarioId,
          }),
        );

        if (profesionalesResponse.statusCode == 201) {
          // Crear el registro en ubicaciones_ubicacion (opcional)
          if (_direccionController.text.isNotEmpty) {
            final ubicacionResponse = await http.post(
              Uri.parse('http://localhost:8000/ubicaciones/crear/'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                'direccion': _direccionController.text,
                'usuario_id': usuarioId, // Asegúrate de que el ID de usuario es el correcto aquí
              }),
            );

            if (ubicacionResponse.statusCode == 201) {
              Navigator.of(context).pop(); // Regresa a la pantalla anterior
            } else {
              print('Error al guardar la ubicación');
            }
          } else {
            Navigator.of(context).pop(); // Regresa a la pantalla anterior si no se proporciona dirección
          }
        } else {
          print('Error al guardar el profesional');
        }
      } else {
        print('Error al obtener el ID del usuario');
      }
    } else {
      print('Error al crear el usuario');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Profesional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _selectedProfesion,
              hint: const Text('Seleccione Profesión'),
              items: _profesiones.map((profesion) {
                return DropdownMenuItem<String>(
                  value: profesion['nombre_profesion'],
                  child: Text(profesion['nombre_profesion']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProfesion = value;
                });
              },
            ),
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarProfesional,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
