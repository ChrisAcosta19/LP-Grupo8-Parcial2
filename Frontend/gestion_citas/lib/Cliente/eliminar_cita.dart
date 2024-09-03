import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> cancelarCita(BuildContext context, int citaId) async {
  final response = await http.delete(
    Uri.parse('http://localhost:8000/usuario/citas/$citaId/'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  if (response.statusCode == 200) {
    // Lanzo el msn de eliminado y nuevo horario disponible
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita cancelada y horario disponible creado exitosamente.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al cancelar la cita.')),
    );
  }
}

class CancelarCitaScreen extends StatelessWidget {
  final List<dynamic> fetchedData;

  const CancelarCitaScreen({Key? key, required this.fetchedData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fetchedData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: fetchedData.length,
            itemBuilder: (context, index) {
              final cita = fetchedData[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Cita para servicio de ${cita['profesional__profesion__nombre_profesion']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text('${cita["profesional__usuario__nombre"]}'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Text('${cita["ubicacion__direccion"]}'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text('${cita["hora_inicio"]} - ${cita["hora_fin"]}'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.date_range),
                          const SizedBox(width: 8),
                          Text('${cita["fecha"]}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      cancelarCita(context, cita['id']);
                    },
                    child: const Text('Eliminar Cita'),
                  ),
                ),
              );
            },
          );
  }
}
