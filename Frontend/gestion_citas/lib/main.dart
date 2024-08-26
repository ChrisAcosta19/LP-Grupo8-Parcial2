import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Profesional/ver_citas.dart';
import 'Profesional/ver_horarios.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gestion_citas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 163, 255),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ProMeet'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? idUsuario;
  String? rolUsuario;
  String? opcionSeleccionada;
  dynamic fetchedData; // Variable para almacenar los datos obtenidos
  dynamic fetchedUserData = {"nombre": "Nombre Usuario", "correo_electronico": "correo@example.com"}; // Variable para almacenar los datos del usuario
  String? selectedDate = '2024-01-01';
  String? selectedProfession;
  String? selectedHoraInicio = '00:00';
  String? selectedHoraFin = '00:00';
  List<String> professionNames = [];

  // Método para obtener datos desde el servidor
  Future<void> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    fetchedData = List.empty(); // Limpiar los datos obtenidos
    if (response.statusCode == 200 && !response.body.contains('<!DOCTYPE html>')) {
      setState(() {
        fetchedData = json.decode(response.body);
      });
    }
  }

  Future<void> fetchUserData(String url) async {
    final response = await http.get(Uri.parse(url));
    fetchedUserData = List.empty(); // Limpiar los datos obtenidos
    if (response.statusCode == 200 && !response.body.contains('<!DOCTYPE html>')) {
      setState(() {
        fetchedUserData = json.decode(response.body);
      });
    }
  }

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

  List<Widget> _buildMenuOptions() {
    List<Widget> options = [];
    switch (rolUsuario) {
      case 'Profesional':
        options = [
          _buildMenuItem('Ver Citas', Icons.calendar_today,
              'http://localhost:8000/profesional/$idUsuario/citas/'),
          _buildMenuItem('Ver Horarios', Icons.access_time,
              'http://localhost:8000/profesional/$idUsuario/horarios/'),
          _buildMenuItem('Crear Horario', Icons.add,
           'http://localhost:8000/profesional/$idUsuario/profesiones/'),
          _buildMenuItem('Reprogramar Cita', Icons.edit, ''),
          _buildMenuItem('Cancelar Cita', Icons.delete, ''),
        ];
        break;
      case 'Administrador':
        options = [
          _buildMenuItem('Opción A', Icons.ac_unit, ''),
          _buildMenuItem('Opción B', Icons.access_alarm, ''),
        ];
        break;
      case 'Cliente':
        options = [
          _buildMenuItem('Opción X', Icons.ac_unit, ''),
          _buildMenuItem('Opción Y', Icons.access_alarm, ''),
        ];
        break;
      default:
        options = [const Text('Seleccione un rol')];
    }
    return options;
  }

  Widget _buildMenuItem(String title, IconData icon, String url) {
    return ListTile(
      leading: Icon(
        icon,
        color: opcionSeleccionada == title ? Colors.white : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: opcionSeleccionada == title ? Colors.white : Colors.black,
        ),
      ),
      onTap: () {
        setState(() {
          opcionSeleccionada = title;
          fetchData(url);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (rolUsuario) {
      case 'Profesional':
        switch (opcionSeleccionada) {
          case 'Ver Citas':
            child = verCitas(fetchedData);
            break;
          case 'Ver Horarios':
            child = verHorarios(fetchedData);
            break;
          case 'Crear Horario':
            setState(() {
              professionNames = [];
              try {
                for (var profession in fetchedData) {
                  professionNames.add(profession["profesion__nombre_profesion"]);
                }
              } catch (e) {
                // ignore: avoid_print
                print(e);
              }
            });
            child = Column(
              children: [
                Expanded(
                  flex: 2,
                  child:
                Row(
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
                                      setState(() {
                                        selectedDate = formatDateTime(selectedDateTime);
                                      });
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
                                setState(() {
                                  selectedProfession = newValue;
                                });
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
                                      setState(() {
                                        selectedHoraInicio = formatTimeOfDay(selectedTime);
                                      });
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
                                      setState(() {
                                        selectedHoraFin = formatTimeOfDay(selectedTime);
                                      });
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
                            onPressed: () {},
                            child: const Row(children: [
                              Icon(Icons.add),
                              SizedBox(width: 10),
                              Text('Crear Horario'),
                            ])),
                      ]),
                ),
              ],
            );
            break;
          case 'Reprogramar Cita':
            child = const Text('Reprogramación de citas');
            break;
          case 'Cancelar Cita':
            child = const Text('Cancelación de citas');
            break;
          default:
            child = const Text('Opción no válida');
        }
        break;
      case 'Administrador':
        child = const Text('Menú de Administrador');
        break;
      case 'Cliente':
        child = const Text('Menú de Cliente');
        break;
      default:
        child = const Text('Rol no válido');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ProMeet'),
      ),
      body: Center(
        child: idUsuario == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        idUsuario = 1;
                        rolUsuario = 'Profesional';
                        opcionSeleccionada = 'Ver Citas';
                        fetchData('http://localhost:8000/profesional/$idUsuario/citas/');
                        fetchUserData('http://localhost:8000/usuarios/$idUsuario/buscar/');
                      });
                    },
                    child: const Text('Profesional'),
                  ),
                  const SizedBox(width: 20), // Espacio entre los botones
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        idUsuario = 2;
                        rolUsuario = 'Cliente';
                      });
                    },
                    child: const Text('Cliente'),
                  ),
                  const SizedBox(width: 20), // Espacio entre los botones
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        idUsuario = 3;
                        rolUsuario = 'Administrador';
                      });
                    },
                    child: const Text('Administrador'),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    child: Column(
                      children: [
                        UserAccountsDrawerHeader(
                          accountName: Text(fetchedUserData['nombre']),
                          accountEmail: Text(fetchedUserData['correo_electronico']),
                          currentAccountPicture: const CircleAvatar(
                            backgroundImage: AssetImage('lib/images/avatar.png'),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: _buildMenuOptions(),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Cerrar sesión'),
                          onTap: () {
                            setState(() {
                              idUsuario = null;
                              rolUsuario = null;
                              opcionSeleccionada = null;
                              selectedProfession = null;
                              fetchedData = null;
                              fetchedUserData = {"nombre": "Nombre Usuario", "correo_electronico": "correo@example.com"};
                              selectedDate = '2024-01-01';
                              selectedHoraInicio = '00:00';
                              selectedHoraFin = '00:00';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: child,
                  ),
                ],
              ),
      ),
    );
  }
}
