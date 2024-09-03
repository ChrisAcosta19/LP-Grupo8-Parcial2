import 'package:http/http.dart' as http;
import 'dart:convert';

class ClienteService {
  final String baseUrl = 'http://localhost:8000/usuarios/clientes/';

  Future<void> createCliente(Map<String, dynamic> newClient) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newClient),
      );

      if (response.statusCode == 201) {
        // Aquí podrías añadir lógica para actualizar la UI si es necesario
      } else {
        print('Error al crear cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al crear cliente: $e');
    }
  }

  Future<void> deleteCliente(int clientId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$clientId/'),
      );

      if (response.statusCode == 204) {
        // Aquí podrías añadir lógica para actualizar la UI si es necesario
      } else {
        print('Error al eliminar cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar cliente: $e');
    }
  }

  Future<void> updateCliente(int clientId, Map<String, dynamic> updatedClient) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$clientId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedClient),
      );

      if (response.statusCode == 200) {
        // Aquí podrías añadir lógica para actualizar la UI si es necesario
      } else {
        print('Error al actualizar cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar cliente: $e');
    }
  }
}
