import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'eliminar_cita.dart';
import 'agendar_citas.dart';

class ReagendarCitaScreen extends StatelessWidget {
  final List<dynamic> fetchedData;
  final String currentidUser;

  const ReagendarCitaScreen({Key? key, required this.fetchedData, required this.currentidUser}) : super(key: key);

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
          child: Text('Pestaña reagenddar Cita'),
        ),
      ),
    );
  }
    //return CancelarCitaScreen(fetchedData: fetchedData); Luego cargar AgendarCita(idUsuario.toString());
}


