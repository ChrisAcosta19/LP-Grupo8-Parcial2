// lib/services/usuario_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  final String apiUrl = 'http://localhost:8000/usuarios/lista/';

  Future<List<Usuario>> fetchUsuarios() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load usuarios');
    }
  }
}
