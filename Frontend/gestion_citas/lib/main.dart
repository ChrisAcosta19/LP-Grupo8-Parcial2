import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Profesional/ver_citas.dart';
import 'Profesional/ver_horarios.dart';
import 'Administrador/ver_clientes.dart';
import 'Profesional/crear_horario.dart';
import 'Cliente/ver_citas.dart';

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
  dynamic fetchedData = List.empty(); // Variable para almacenar los datos obtenidos
  dynamic fetchedUserData = {
    "nombre": "Nombre Usuario",
    "correo_electronico": "correo@example.com"
  }; // Variable para almacenar los datos del usuario
  String selectedDate = '2024-01-01';
  String? selectedProfession;
  String selectedHoraInicio = '00:00';
  String selectedHoraFin = '00:00';
  List<String> professionNames = [];

  // Método para obtener datos desde el servidor
  Future<void> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    fetchedData = List.empty(); // Limpiar los datos obtenidos
    if (response.statusCode == 200 &&
        !response.body.contains('<!DOCTYPE html>')) {
      setState(() {
        fetchedData = json.decode(response.body);
      });
    }
  }

  Future<void> fetchUserData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 &&
        !response.body.contains('<!DOCTYPE html>')) {
      setState(() {
        fetchedUserData = json.decode(response.body);
      });
    }
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
          _buildMenuItem('Clientes', Icons.people,
              'http://localhost:8000/usuarios/clientes/'),
          _buildMenuItem('Profesionales', Icons.person, ''),
          _buildMenuItem('Citas', Icons.calendar_today,''),
          _buildMenuItem('Perfil', Icons.person_outline, ''),
        ];
        break;
      case 'Cliente':
        options = [
          _buildMenuItem('Ver Citas Agendadas', Icons.calendar_today, 
              'http://localhost:8000/cliente/$idUsuario/citas/'),
          _buildMenuItem('Agendar Citas', Icons.access_time, ''),
              ///Code de relocalizacion
          _buildMenuItem('Reprogramar Cita', Icons.edit, ''),
              ///Code de relocalizacion
          _buildMenuItem('Cancelar Cita', Icons.delete, ''),
              ///Code de relocalizacion
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
            child = crearHorario(
              professionNames: professionNames,
              selectedDate: selectedDate,
              selectedProfession: selectedProfession,
              selectedHoraInicio: selectedHoraInicio,
              selectedHoraFin: selectedHoraFin,
              context: context,
              idUsuario: idUsuario,
              onDateChanged: (newDate) {
                setState(() {
                  selectedDate = newDate;
                });
              },
              onProfessionChanged: (newProfession) {
                setState(() {
                  selectedProfession = newProfession;
                });
              },
              onHoraInicioChanged: (newHoraInicio) {
                setState(() {
                  selectedHoraInicio = newHoraInicio;
                });
              },
              onHoraFinChanged: (newHoraFin) {
                setState(() {
                  selectedHoraFin = newHoraFin;
                });
              },
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
        switch (opcionSeleccionada) {
          case 'Clientes':
            child = VerClientes(fetchedData: fetchedData);
            break;
          case 'Profesionales':
            child = const Text('Todas las Profesionales (por implementar)');
            break;
          case 'Citas':
            child = const Text('Todas las Citas (por implementar)');
            break;
          case 'Perfil':
            child = const Text('Perfil del Administrador (por implementar)');
            break;
          default:
            child = const Text('Opción no válida');
        }
        break;
      case 'Cliente':
        switch (opcionSeleccionada) {
          case 'Ver Citas Agendadas':
            child = verCitasClientes(fetchedData);
            break;
          case 'Agendar cita':
            child = const Text('agendar Cita');
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
                        fetchData(
                            'http://localhost:8000/profesional/$idUsuario/citas/');
                        fetchUserData(
                            'http://localhost:8000/usuarios/$idUsuario/buscar/');
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
                        opcionSeleccionada = 'Ver Citas Agendadas';
                        fetchUserData(
                            'http://localhost:8000/usuarios/$idUsuario/buscar/');
                        fetchData(
                            'http://localhost:8000/cliente/$idUsuario/citas/');
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
                        opcionSeleccionada = 'Clientes';
                        fetchData('http://localhost:8000/usuarios/clientes/');
                        fetchUserData(
                            'http://localhost:8000/usuarios/$idUsuario/buscar/');
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
                            backgroundImage:
                                AssetImage('lib/images/avatar.png'),
                          ),
                        ),
                        if (rolUsuario == 'Administrador')
                          const Padding(
                            padding: EdgeInsets.all(8.0), // Ajustar el padding según sea necesario
                            child: Text(
                              'ADMINISTRADOR',
                              style: TextStyle(
                                fontSize: 16.0, // Tamaño de fuente ajustable
                                fontWeight: FontWeight.bold,
                                color: Colors.red, // Color ajustable
                              ),
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
                              fetchedData = List.empty();
                              fetchedUserData = {
                                "nombre": "Nombre Usuario",
                                "correo_electronico": "correo@example.com"
                              };
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
