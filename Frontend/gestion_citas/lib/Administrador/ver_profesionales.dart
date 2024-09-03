import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'editar_profesional.dart';
import 'crear_profesional.dart';

class VerProfesionales extends StatefulWidget {
  const VerProfesionales({Key? key}) : super(key: key);

  @override
  _VerProfesionalesState createState() => _VerProfesionalesState();
}

class _VerProfesionalesState extends State<VerProfesionales> {
  List<dynamic> profesionales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfesionales();
  }

  Future<void> _loadProfesionales() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/administrador/profesionales/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            profesionales = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        print('Error al cargar profesionales');
      }
    } catch (e) {
      print('Excepción al cargar profesionales: $e');
    }
  }

  Future<void> _deleteProfesional(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/usuarios/eliminar/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _loadProfesionales();
        print('Profesional eliminado exitosamente');
      } else {
        print('Error al eliminar el profesional');
      }
    } catch (e) {
      print('Excepción al eliminar profesional: $e');
    }
  }

  void _showOptions(BuildContext context, dynamic profesional) {
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
                    builder: (context) => EditProfesionalScreen(profesional: profesional),
                  ),
                ).then((_) => _loadProfesionales());
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar'),
              onTap: () {
                _deleteProfesional(profesional['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addProfesional() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearProfesionalScreen()),
    );
    _loadProfesionales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Profesionales'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _addProfesional,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 10),
                        Text('Nuevo Profesional'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: profesionales.isEmpty
                      ? const Center(child: Text('No hay profesionales disponibles'))
                      : ListView.builder(
                          itemCount: profesionales.length,
                          itemBuilder: (context, index) {
                            final profesional = profesionales[index];
                            return ListTile(
                              title: Text(profesional['nombre'] ?? 'Nombre no disponible'),
                              subtitle: Text(profesional['correo_electronico'] ?? 'Correo no disponible'),
                              onTap: () {
                                _showOptions(context, profesional);
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
