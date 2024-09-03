import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'editar_profesion.dart';
import 'crear_profesion.dart';

class VerProfesiones extends StatefulWidget {
  const VerProfesiones({Key? key}) : super(key: key);

  @override
  _VerProfesionesState createState() => _VerProfesionesState();
}

class _VerProfesionesState extends State<VerProfesiones> {
  List<dynamic> profesiones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfesiones();
  }

  Future<void> _loadProfesiones() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/profesiones/lista/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            profesiones = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        print('Error al cargar profesiones');
      }
    } catch (e) {
      print('Excepción al cargar profesiones: $e');
    }
  }

  Future<void> _deleteProfesion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/administrador/eliminar_profesion/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _loadProfesiones();
        print('Profesión eliminada exitosamente');
      } else {
        print('Error al eliminar la profesión');
      }
    } catch (e) {
      print('Excepción al eliminar profesión: $e');
    }
  }

  void _showOptions(BuildContext context, dynamic profesion) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Modificar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfesionScreen(profesion: profesion),
                  ),
                ).then((_) => _loadProfesiones());
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar'),
              onTap: () {
                _deleteProfesion(profesion['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addProfesion() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearProfesionScreen()),
    );
    _loadProfesiones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Profesiones'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _addProfesion,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 10),
                        Text('Nueva Profesión'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: profesiones.isEmpty
                      ? const Center(child: Text('No hay profesiones disponibles'))
                      : ListView.builder(
                          itemCount: profesiones.length,
                          itemBuilder: (context, index) {
                            final profesion = profesiones[index];
                            return ListTile(
                              title: Text(profesion['nombre_profesion'] ?? 'Nombre no disponible'),
                              onTap: () {
                                _showOptions(context, profesion);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
