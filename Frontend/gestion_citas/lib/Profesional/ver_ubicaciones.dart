// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerUbicaciones extends StatefulWidget {
  final int? idUsuario;
  final List<String> professionNames;
  const VerUbicaciones({super.key, this.idUsuario, required this.professionNames});

  @override
  _VerUbicacionesState createState() => _VerUbicacionesState();
}

class _VerUbicacionesState extends State<VerUbicaciones> {
  List _ubicaciones = [];
  List _ubicacionesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  String? _profesionSeleccionada;

  @override
  void initState() {
    super.initState();
    _fetchUbicaciones(widget.idUsuario);
    _searchController.addListener(_filterUbicaciones);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _fetchUbicaciones(int? idUsuario) async {
    final urlUbicaciones = Uri.parse('http://localhost:8000/profesional/$idUsuario/ubicaciones/');
    try {
      final response = await http.get(urlUbicaciones);
      if (response.statusCode == 200) {
        setState(() {
          _ubicaciones = json.decode(response.body);
          _ubicacionesFiltradas = _ubicaciones; // Inicialmente, mostrar todas las ubicaciones
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ubicaciones')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  void _filterUbicaciones() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _ubicacionesFiltradas = _ubicaciones;
      } else {
        _ubicacionesFiltradas = _ubicaciones.where((ubicacion) {
          final direccion = ubicacion['direccion'].toLowerCase();
          final profesion = ubicacion['profesional__profesion__nombre_profesion'].toLowerCase();
          return direccion.contains(query) || profesion.contains(query);
        }).toList();
      }
    });
  }

  int? idProfesion;
  Future<void> fetchProfesion(BuildContext context, String nombre) async {
    final urlProfesiones = Uri.parse('http://localhost:8000/profesion/$nombre/');
    try {
      final response = await http.get(urlProfesiones);
      if (response.statusCode == 200) {
        setState(() {
          idProfesion = json.decode(response.body)['id'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener profesiones')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  int? idProfesional;
  Future<void> fetchProfesional(int? idUsuario, int? idProfesion, BuildContext context) async {
    final urlProfesional = Uri.parse('http://localhost:8000/profesional/$idUsuario/profesion/$idProfesion/');
    try {
      final response = await http.get(urlProfesional);
      if (response.statusCode == 200) {
        setState(() {
          idProfesional = json.decode(response.body)['id'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener profesional')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  Future<void> makePostRequest(
    BuildContext context,
    String direccion,
  ) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/profesional/$idProfesional/ubicaciones/crear/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'direccion': direccion,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación creada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear ubicación')),
      );
    }
  }

  void _showAgregarUbicacionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva ubicación'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _direccionController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButton<String>(
                    value: _profesionSeleccionada,
                    hint: const Text('Selecciona una profesión'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _profesionSeleccionada = newValue;
                      });
                    },
                    items: widget.professionNames.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin agregar
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await fetchProfesion(context, _profesionSeleccionada!);
                await fetchProfesional(widget.idUsuario, idProfesion, context);
                await makePostRequest(context, _direccionController.text);
                await _fetchUbicaciones(widget.idUsuario);
                Navigator.of(context).pop(); // Cierra el diálogo después de agregar
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por dirección',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _showAgregarUbicacionDialog,
                child: const Row(
                  children: [Icon(Icons.add), Text('Añadir ubicación')],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _ubicacionesFiltradas.isNotEmpty
              ? ListView.builder(
                  itemCount: _ubicacionesFiltradas.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(_ubicacionesFiltradas[index]['profesional__profesion__nombre_profesion']),
                        subtitle: Text(_ubicacionesFiltradas[index]['direccion']),
                      ),
                    );
                  },
                )
              : const Center(child: Text('No hay ubicaciones')),
        ),
      ],
    );
  }
}
