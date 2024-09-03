import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'editar_cliente.dart'; // Asegúrate de tener esta pantalla para modificar clientes
import 'crear_cliente.dart'; // Asegúrate de tener esta pantalla para agregar clientes

class VerClientes extends StatefulWidget {
  final dynamic fetchedData; // Añadir esta línea
  const VerClientes({super.key, this.fetchedData}); // Modificar el constructor

  @override
  _VerClientesState createState() => _VerClientesState();
}

class _VerClientesState extends State<VerClientes> {
  List<dynamic> clientes = []; // Inicialmente vacío
  bool _isLoading = true; // Agregar estado de carga

  @override
  void initState() {
    super.initState();
    _loadClientes(); // Cargar clientes al inicio
  }

  Future<void> _loadClientes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/usuarios/clientes/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            clientes = jsonDecode(response.body);
            _isLoading = false; // Actualiza el estado de carga
          });
        }
      } else {
        print('Error al cargar clientes');
        // Considera mostrar un mensaje de error en la UI
      }
    } catch (e) {
      print('Excepción al cargar clientes: $e');
      // Considera mostrar un mensaje de error en la UI
    }
  }

  Future<void> _deleteCliente(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/usuarios/eliminar/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Actualiza la lista de clientes después de eliminar
        _loadClientes();
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

  void _showOptions(BuildContext context, dynamic cliente) {
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
                    builder: (context) => EditClienteScreen(cliente: cliente),
                  ),
                ).then((_) => _loadClientes()); // Recargar clientes después de volver
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar'),
              onTap: () {
                _deleteCliente(cliente['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addCliente() async {
    // Abre la pantalla para agregar un nuevo cliente
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearClienteScreen()),
    );

    // Recarga la lista de clientes después de agregar uno nuevo
    _loadClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _addCliente,
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
                  child: clientes.isEmpty
                      ? const Center(child: Text('No hay clientes disponibles'))
                      : ListView.builder(
                          itemCount: clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = clientes[index];
                            return ListTile(
                              title: Text(cliente['nombre'] ?? 'Nombre no disponible'),
                              subtitle: Text(cliente['correo_electronico'] ?? 'Correo no disponible'),
                              onTap: () {
                                _showOptions(context, cliente);
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
