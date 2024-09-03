import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'crear_profesional.dart';
import 'editar_profesional.dart';

class VerProfesionales extends StatefulWidget {
  const VerProfesionales({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        Uri.parse('http://127.0.0.1:8000/usuarios/profesionales/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          profesionales = jsonDecode(response.body);
          _isLoading = false; // Actualiza el estado de carga
        });
      } else {
        print('Error al cargar profesionales');
        // Puedes agregar un manejo de errores aquí
      }
    } catch (e) {
      print('Excepción al cargar profesionales: $e');
      // Puedes agregar un manejo de errores aquí
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
              leading: const Icon(Icons.edit),
              title: const Text('Modificar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarProfesionalScreen(
                      profesional: profesional,
                    ),
                  ),
                ).then((_) {
                  _loadProfesionales(); // Recargar la lista después de editar
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(context);
                _deleteProfesional(profesional['id']);
              },
            ),
          ],
        );
      },
    );
  }

  
  Future<void> _deleteProfesional(int id) async {
  try {
    // Eliminar la relación con la profesión, si aplica
    final deleteProfesionResponse = await http.delete(
      Uri.parse('http://127.0.0.1:8000/usuarios/eliminar_profesion2/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (deleteProfesionResponse.statusCode != 204) {
      print('Error al eliminar la profesión asociada');
      return;
    }

    // Eliminar la ubicación, si aplica
    final deleteUbicacionResponse = await http.delete(
      Uri.parse('http://127.0.0.1:8000/ubicaciones/eliminar_ubicacion2/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (deleteUbicacionResponse.statusCode != 204) {
      print('Error al eliminar la ubicación asociada');
      return;
    }

    // Eliminar el profesional
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/usuarios/eliminar2/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        profesionales.removeWhere((profesional) => profesional['id'] == id);
      });
    } else {
      print('Error al eliminar profesional');
      // Manejo de errores aquí
    }
  } catch (e) {
    print('Excepción al eliminar profesional: $e');
    // Manejo de errores aquí
  }
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CrearProfesionalScreen(),
                        ),
                      ).then((_) {
                        _loadProfesionales(); // Recargar la lista después de crear un nuevo profesional
                      });
                    },
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Correo: ${profesional['correo_electronico'] ?? 'No disponible'}'),
                                  Text('Rol: ${profesional['rol'] ?? 'No disponible'}'),
                                  Text('Profesión: ${profesional['profesion'] ?? 'No disponible'}'),
                                  Text('Dirección: ${profesional['direccion'] ?? 'No disponible'}'),
                                ],
                              ),
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
