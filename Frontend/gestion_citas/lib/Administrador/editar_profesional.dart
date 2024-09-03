import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarProfesionalScreen extends StatefulWidget {
  final dynamic profesional;
  
  const EditarProfesionalScreen({super.key, required this.profesional});

  @override
  _EditarProfesionalScreenState createState() => _EditarProfesionalScreenState();
}

class _EditarProfesionalScreenState extends State<EditarProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;
  String? _selectedProfesion;
  List<dynamic> _profesiones = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.profesional['nombre']);
    _correoController = TextEditingController(text: widget.profesional['correo_electronico']);
    _direccionController = TextEditingController(text: widget.profesional['direccion']);
    _selectedProfesion = widget.profesional['profesion'];

    _fetchProfesiones();
  }

  Future<void> _fetchProfesiones() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/usuarios/profesiones/'),
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

  Future<void> _actualizarUsuario() async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/usuarios/actualizar/${widget.profesional['id']}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': _nombreController.text,
        'correo_electronico': _correoController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el usuario')),
      );
    }
  }

  Future<void> _actualizarProfesion() async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/usuarios/actualizar_profesion/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'usuario_id': widget.profesional['id'], // o el ID que corresponda
        'profesion_id': _selectedProfesion, // Aquí debe ir el ID de la profesión seleccionada
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profesión actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la profesión')),
      );
    }
  }

  Future<void> _actualizarUbicacion() async {
    final response = await http.put(
      Uri.parse('http://localhost:8000/ubicaciones/actualizar_ubicacion/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'usuario_id': widget.profesional['id'], // o el ID que corresponda
        'direccion': _direccionController.text, // La nueva dirección desde el controlador
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la ubicación')),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Profesional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
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
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un correo electrónico';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una dirección';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedProfesion,
                decoration: const InputDecoration(labelText: 'Profesión'),
                items: _profesiones.map<DropdownMenuItem<String>>((profesion) {
                  return DropdownMenuItem<String>(
                    value: profesion['id'].toString(), // Cambia aquí si el ID está en otro campo
                    child: Text(profesion['nombre_profesion']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProfesion = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    bool cambios = false;

                    // Verificar si los datos del usuario han cambiado
                    if (_nombreController.text != widget.profesional['nombre'] ||
                        _correoController.text != widget.profesional['correo_electronico']) {
                      _actualizarUsuario();
                      cambios = true;
                    }

                    // Verificar si la profesión ha cambiado
                    if (_selectedProfesion != widget.profesional['profesion']) {
                      _actualizarProfesion();
                      cambios = true;
                    }

                    // Verificar si la dirección ha cambiado
                    if (_direccionController.text != widget.profesional['direccion']) {
                      _actualizarUbicacion();
                      cambios = true;
                    }

                    // Si se realizaron cambios, mostrar un mensaje de éxito
                    if (cambios) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cambios guardados correctamente')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se realizaron cambios')),
                      );
                    }
                  }
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
