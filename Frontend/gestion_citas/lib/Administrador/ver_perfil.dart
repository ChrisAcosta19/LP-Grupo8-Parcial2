import 'package:flutter/material.dart';

class VerPerfil extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const VerPerfil(this.usuario, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: usuario.isEmpty
            ? const Center(child: Text('No se encontraron datos del usuario'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nombre: ${usuario['nombre']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correo Electrónico: ${usuario['correo_electronico']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rol: ${usuario['rol']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
