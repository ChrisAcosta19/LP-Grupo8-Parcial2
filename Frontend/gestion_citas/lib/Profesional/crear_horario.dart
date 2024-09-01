// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0'); // Asegura dos dígitos
  final minute = time.minute.toString().padLeft(2, '0'); // Asegura dos dígitos
  return '$hour:$minute';
}

String formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0'); // Asegura dos dígitos
  final month = date.month.toString().padLeft(2, '0'); // Asegura dos dígitos
  final year = date.year.toString();
  return '$year-$month-$day';
}

int? idProfesion;
Future<void> fetchProfesion(BuildContext context, String nombre) async {
  final urlProfesiones = Uri.parse('http://localhost:8000/profesion/$nombre/');
  try {
    final response = await http.get(urlProfesiones);
    if (response.statusCode == 200) {
      idProfesion = json.decode(response.body)['id'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener profesiones')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al conectar con el servidor')),
    );
  }
}

int? idProfesional;
Future<void> fetchProfesional(int? idUsuario, int? idProfesion, BuildContext context) async {
  final urlProfesional = Uri.parse('http://localhost:8000/profesional/$idUsuario/profesion/$idProfesion/');
  try {
    final response = await http.get(urlProfesional);
    if (response.statusCode == 200) {
      idProfesional = json.decode(response.body)['id'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener profesional')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al conectar con el servidor')),
    );
  }
}

Future<void> makePostRequest(
  BuildContext context,
  String selectedDate,
  String selectedHoraInicio,
  String selectedHoraFin,
) async {
  final response = await http.post(
    Uri.parse(
        'http://localhost:8000/profesional/$idProfesional/horarios/crear/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'fecha': selectedDate,
      'horaInicio': selectedHoraInicio,
      'horaFin': selectedHoraFin,
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Horario creado')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al crear horario')),
    );
  }
}


Column crearHorario({
  required List<String> professionNames,
  required String selectedDate,
  required String? selectedProfession,
  required String selectedHoraInicio,
  required String selectedHoraFin,
  required Function(String) onDateChanged,
  required Function(String) onProfessionChanged,
  required Function(String) onHoraInicioChanged,
  required Function(String) onHoraFinChanged,
  required BuildContext context,
  required int? idUsuario,
}) {
  return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Date Picker
                            const Text('Fecha:'),
                            SizedBox(
                              height: 50, // Adjust height as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  ).then((selectedDateTime) {
                                    if (selectedDateTime != null) {
                                      onDateChanged(formatDateTime(selectedDateTime));
                                    }
                                  });
                                },
                                child: const Text('Seleccionar Fecha'),
                              ),
                            ),
                            Text('Fecha elegida: $selectedDate'),
                            const SizedBox(height: 150),
                            const Text('Seleccione la profesión:'),
                            DropdownButton<String>(
                              value: selectedProfession,
                              items: professionNames.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                onProfessionChanged(newValue!);
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Time Picker for Start Time
                            const Text('Hora inicio:'),
                            SizedBox(
                              height: 50, // Adjust height as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((selectedTime) {
                                    if (selectedTime != null) {
                                      onHoraInicioChanged(formatTimeOfDay(selectedTime));
                                    }
                                  });
                                },
                                child: const Text('Seleccionar hora inicio'),
                              ),
                            ),
                            Text('Hora elegida: $selectedHoraInicio'),
                            const SizedBox(height: 150),
                            // Time Picker for End Time
                            const Text('Hora fin:'),
                            SizedBox(
                              height: 50, // Adjust height as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((selectedTime) {
                                    if (selectedTime != null) {
                                      onHoraFinChanged(formatTimeOfDay(selectedTime));
                                    }
                                  });
                                },
                                child: const Text('Seleccionar hora fin'),
                              ),
                            ),
                            Text('Hora elegida: $selectedHoraFin'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              // Obtener id de la profesion
                              await fetchProfesion(context, selectedProfession!);
                              // Obtener el profesional segun el id de la profesion
                              await fetchProfesional(idUsuario, idProfesion, context);
                              // Crear horario con los datos seleccionados
                              await makePostRequest(context, selectedDate, selectedHoraInicio, selectedHoraFin);
                            },
                            child: const Row(children: [
                              Icon(Icons.add),
                              SizedBox(width: 10),
                              Text('Crear Horario'),
                            ])),
                      ]),
                ),
              ],
            );
}