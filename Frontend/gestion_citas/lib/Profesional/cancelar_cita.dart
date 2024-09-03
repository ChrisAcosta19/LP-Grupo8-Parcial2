// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CancelarCitas extends StatefulWidget {
  final int? idUsuario;

  const CancelarCitas({super.key, required this.idUsuario});

  @override
  _CancelarCitasState createState() => _CancelarCitasState();
}

class _CancelarCitasState extends State<CancelarCitas> {
  dynamic fetchedData = [];

  @override
  void initState() {
    super.initState();
    fetchCitas(widget.idUsuario);
  }

  Future<void> fetchCitas(int? idUsuario) async {
    final urlCitas = Uri.parse('http://localhost:8000/profesional/$idUsuario/citas/');
    try {
      final response = await http.get(urlCitas);
      if (response.statusCode == 200) {
        setState(() {
          fetchedData = json.decode(response.body).where((cita) => cita["estado"] == "Agendada").toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener citas')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  Future<void> cancelAppointment(int citaId) async {
    final url = Uri.parse('http://localhost:8000/profesional/citas/$citaId/cancelar/');
    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada exitosamente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text('Error al cancelar la cita: ${response.statusCode}')),
      );
    }
  }

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
                  title: Row(
                    children: [
                      Text('Servicios de ${cita["profesional__profesion__nombre_profesion"]}'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Aquí se agrega la lógica cuando se presiona el botón de eliminar
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar cancelación'),
                                content: const Text('¿Está seguro de cancelar esta cita?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Aceptar'),
                                    onPressed: () async {
                                      await cancelAppointment(cita["id"]);
                                      await fetchCitas(widget.idUsuario);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
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
}
