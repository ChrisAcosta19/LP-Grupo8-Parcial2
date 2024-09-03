// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'eliminar_cita.dart';
import 'agendar_citas.dart';

class ReagendarCitaScreen extends StatelessWidget {
  final List<dynamic> fetchedData;
  final String currentidUser;

  const ReagendarCitaScreen({super.key, required this.fetchedData, required this.currentidUser});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // ir aCancelarCitaScreen
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CancelarCitaScreen(fetchedData: fetchedData),
              ),
            );

            if (result == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgendarCita(currentidUser),
                ),
              );
            }
          },
          child: const Text('Pestaña reagenddar Cita'),
        ),
      ),
    );
  }
    //return CancelarCitaScreen(fetchedData: fetchedData); Luego cargar AgendarCita(idUsuario.toString());
}


