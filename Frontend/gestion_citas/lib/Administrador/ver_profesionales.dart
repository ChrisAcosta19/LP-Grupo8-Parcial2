import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'editar_profesional.dart'; // Asegúrate de tener esta pantalla para modificar profesionales
import 'crear_profesional.dart'; // Asegúrate de tener esta pantalla para agregar nuevos profesionales

class VerProfesionales extends StatefulWidget {
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
        // Actualiza la lista de clientes después de eliminar
        _loadProfesionales();
        print('Cliente eliminado exitosamente');
      } else {
        print('Error al eliminar el cliente');
        // Considera mostrar un mensaje de error en la UI
      }
    } catch (e) {
      print('Excepción al eliminar cliente: $e');
      // Considera mostrar un mensaje de error en la UI
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
                    builder: (context) => EditarProfesionalScreen(profesionalId: profesional['usuario_id']),
                  ),
                ).then((_) => _loadProfesionales()); // Recargar profesionales después de volver
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar'),
              onTap: () {
                _deleteProfesional(profesional['usuario_id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addProfesional() async {
    // Abre la pantalla para agregar un nuevo profesional
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearProfesionalScreen()),
    );

    // Recarga la lista de profesionales después de agregar uno nuevo
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
                        Text('Nuevo Cliente'),
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
                            return Card(
                              child: ListTile(
                                title: Text(profesional['usuario_nombre']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Correo: ${profesional['correo_electronico']}'),
                                    Text('Profesión: ${profesional['nombre_profesion']}'),
                                    Text('Dirección: ${profesional['direccion_ubicacion'] ?? 'No disponible'}'),
                                  ],
                                ),
                                onTap: () {
                                  _showOptions(context, profesional);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
