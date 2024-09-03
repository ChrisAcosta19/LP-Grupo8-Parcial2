import 'package:flutter/material.dart';

class VerProfesiones extends StatelessWidget {
  final List<dynamic> profesiones;

  const VerProfesiones(this.profesiones, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Profesiones'),
      ),
      body: profesiones.isEmpty
          ? const Center(child: Text('No hay profesiones disponibles'))
          : ListView.builder(
              itemCount: profesiones.length,
              itemBuilder: (context, index) {
                final profesion = profesiones[index];
                return ListTile(
                  title: Text(profesion['nombre_profesion'] ?? 'Nombre no disponible'),
                );
              },
            ),
    );
  }
}
