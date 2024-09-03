// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReprogramarCitas extends StatefulWidget {
  final int? idUsuario;
  const ReprogramarCitas({super.key, required this.idUsuario});

  @override
  _ReprogramarCitasState createState() => _ReprogramarCitasState();
}

class _ReprogramarCitasState extends State<ReprogramarCitas> {
  dynamic fetchedData = [];
  dynamic ubicaciones;
  String? selectedUbicacion;
  int? selectedID;

  int? selectedYear;
  int? selectedMonth;
  int? selectedDay;
  
  int? selectedStartHour;
  int? selectedStartMinute;
  int? selectedEndHour;
  int? selectedEndMinute;

  List<int> years = List.generate(50, (index) => DateTime.now().year - 25 + index);
  List<int> months = List.generate(12, (index) => index + 1);
  List<int> days = [];
  List<int> hours = List.generate(24, (index) => index);
  List<int> minutes = List.generate(60, (index) => index);

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
          fetchedData = json.decode(response.body);
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

  Future<void> fetchUbicaciones(int? idProfesional) async {
    final urlUbicaciones = Uri.parse('http://localhost:8000/profesional/$idProfesional/ubicacionesProfesional/');
    try {
      final response = await http.get(urlUbicaciones);
      if (response.statusCode == 200) {
        setState(() {
          ubicaciones = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ubicaciones')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }
  }

  Future<void> updateAppointment(int citaId, String ubicacion, String fecha, String horaInicio, String horaFin) async {
    final url = Uri.parse('http://localhost:8000/profesional/citas/$citaId/actualizar/');
    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'fecha': fecha,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'ubicacion': ubicaciones.firstWhere((ubicacionData) => ubicacionData["direccion"] == ubicacion)["id"],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita actualizada exitosamente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text('Error al actualizar la cita: ${response.statusCode}')),
      );
    }
  }

  void updateDaysList() {
    if (selectedYear != null && selectedMonth != null) {
      int daysInMonth = DateTime(selectedYear!, selectedMonth! + 1, 0).day;
      days = List.generate(daysInMonth, (index) => index + 1);
      if (selectedDay != null && selectedDay! > daysInMonth) {
        selectedDay = daysInMonth;
      }
    }
  }

  String formatDate(int? year, int? month, int? day) {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String formatTime(int? hour, int? minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = fetchedData.where((cita) => cita["estado"] == "Agendada").toList();

    return filteredData.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final cita = filteredData[index];

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  children: [
                    Text('Servicios de ${cita["profesional__profesion__nombre_profesion"]}'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await fetchUbicaciones(cita["profesional_id"]);
                        // Inicializar los valores seleccionados basados en la fecha de la cita actual
                        DateTime citaFecha = DateTime.parse(cita["fecha"]);
                        setState(() {
                          selectedYear = citaFecha.year;
                          selectedMonth = citaFecha.month;
                          selectedDay = citaFecha.day;
                          selectedID = cita["id"]; // ID de la cita actual

                          // Inicializar hora de inicio y fin
                          final startTimeParts = cita["hora_inicio"].split(':');
                          final endTimeParts = cita["hora_fin"].split(':');
                          selectedStartHour = int.parse(startTimeParts[0]);
                          selectedStartMinute = int.parse(startTimeParts[1]);
                          selectedEndHour = int.parse(endTimeParts[0]);
                          selectedEndMinute = int.parse(endTimeParts[1]);

                          // Inicializar ubicación
                          selectedUbicacion = cita["ubicacion__direccion"];
                        });
                        updateDaysList(); // Actualiza la lista de días según el año y mes seleccionados
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Editar Cita'),
                              content: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Ubicación'),
                                      DropdownButton<String>(
                                          value: selectedUbicacion,
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedUbicacion = newValue;
                                            });
                                          },
                                          items: ubicaciones
                                              .map((ubicacion) => ubicacion["direccion"])
                                              .cast<String>()
                                              .map<DropdownMenuItem<String>>((ubicacion) {
                                            return DropdownMenuItem<String>(
                                              value: ubicacion,
                                              child: Text(ubicacion),
                                            );
                                          }).toList(),
                                        ),
                                      const Text('Fecha'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          DropdownButton<int>(
                                            value: selectedYear,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedYear = newValue;
                                                updateDaysList();
                                              });
                                            },
                                            items: years.map<DropdownMenuItem<int>>((year) {
                                              return DropdownMenuItem<int>(
                                                value: year,
                                                child: Text(year.toString()),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('-'),
                                          const SizedBox(width: 8),
                                          DropdownButton<int>(
                                            value: selectedMonth,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedMonth = newValue;
                                                updateDaysList();
                                              });
                                            },
                                            items: months.map<DropdownMenuItem<int>>((month) {
                                              return DropdownMenuItem<int>(
                                                value: month,
                                                child: Text(month.toString()),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('-'),
                                          const SizedBox(width: 8),
                                          DropdownButton<int>(
                                            value: selectedDay,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedDay = newValue;
                                              });
                                            },
                                            items: days.map<DropdownMenuItem<int>>((day) {
                                              return DropdownMenuItem<int>(
                                                value: day,
                                                child: Text(day.toString()),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      const Text('Hora de Inicio'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          DropdownButton<int>(
                                            value: selectedStartHour,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedStartHour = newValue;
                                              });
                                            },
                                            items: hours.map<DropdownMenuItem<int>>((hour) {
                                              return DropdownMenuItem<int>(
                                                value: hour,
                                                child: Text(hour.toString().padLeft(2, '0')),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(':'),
                                          const SizedBox(width: 8),
                                          DropdownButton<int>(
                                            value: selectedStartMinute,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedStartMinute = newValue;
                                              });
                                            },
                                            items: minutes.map<DropdownMenuItem<int>>((minute) {
                                              return DropdownMenuItem<int>(
                                                value: minute,
                                                child: Text(minute.toString().padLeft(2, '0')),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      const Text('Hora de Fin'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          DropdownButton<int>(
                                            value: selectedEndHour,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedEndHour = newValue;
                                              });
                                            },
                                            items: hours.map<DropdownMenuItem<int>>((hour) {
                                              return DropdownMenuItem<int>(
                                                value: hour,
                                                child: Text(hour.toString().padLeft(2, '0')),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(':'),
                                          const SizedBox(width: 8),
                                          DropdownButton<int>(
                                            value: selectedEndMinute,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedEndMinute = newValue;
                                              });
                                            },
                                            items: minutes.map<DropdownMenuItem<int>>((minute) {
                                              return DropdownMenuItem<int>(
                                                value: minute,
                                                child: Text(minute.toString().padLeft(2, '0')),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Guardar'),
                                  onPressed: () async{
                                    // Lógica para guardar los cambios
                                    await updateAppointment(
                                      selectedID!,
                                      selectedUbicacion!,
                                      formatDate(selectedYear, selectedMonth, selectedDay),
                                      formatTime(selectedStartHour, selectedStartMinute),
                                      formatTime(selectedEndHour, selectedEndMinute)
                                    );
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
