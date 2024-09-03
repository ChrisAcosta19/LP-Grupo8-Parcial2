import 'package:flutter/material.dart';

class VerCitasAdmin extends StatelessWidget {
  final dynamic fetchedData; // Asegúrate de que el tipo sea compatible con los datos que pasas

  const VerCitasAdmin(this.fetchedData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Administrador'),
      ),
      body: fetchedData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: fetchedData.length,
              itemBuilder: (context, index) {
                final cita = fetchedData[index];
                return ListTile(
                  title: Text('Cita ${cita['id']}'),
                  subtitle: Text('Fecha: ${cita['fecha']}'),
                );
              },
            ),
    );
}
}