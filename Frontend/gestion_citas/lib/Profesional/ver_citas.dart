import 'package:flutter/material.dart';

Widget verCitas(fetchedData) {
  return fetchedData == List.empty()
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: fetchedData!.length,
          itemBuilder: (context, index) {
            final cita = fetchedData![index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  children: [
                    Text('Servicios de ${cita["profesional__profesion__nombre_profesion"]}'),
                    const Spacer(),
                    Text('${cita["estado"]}'),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text('${cita["cliente__nombre"]}'),
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
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text('${cita["fecha"]}'),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8),
                        Text('${cita["hora_inicio"]} - ${cita["hora_fin"]}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
}
