import 'package:flutter/material.dart';
import 'package:gestion_citas/Cliente/agendar_citas.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Profesional/ver_citas.dart';
import 'Profesional/ver_horarios.dart';
import 'Administrador/ver_profesionales.dart';
import 'Administrador/ver_profesiones.dart';
import 'Administrador/ver_citasAdmin.dart';
import 'Administrador/ver_perfil.dart';
import 'Profesional/crear_horario.dart';
import 'Profesional/ver_ubicaciones.dart';
import 'Profesional/reprogramar_cita.dart';
import 'Profesional/cancelar_cita.dart';
import 'Administrador/ver_clientes.dart';
import 'Cliente/ver_citas.dart';
import 'Cliente/eliminar_cita.dart';
import 'Cliente/reagendar_citas.dart';


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
  // Método para obtener datos desde el servidor
  Future<void> fetchData(String url) async {
    setState(() {
      fetchedData = List.empty(); // Limpiar los datos obtenidos
    });
    final response = await http.get(Uri.parse(url));
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
          _buildMenuItem('Cancelar Cita', Icons.delete,''),
          _buildMenuItem('Ver Ubicaciones', Icons.location_on,
              'http://localhost:8000/profesional/$idUsuario/profesiones/'),
        ];
        break;
      case 'Administrador':
        options = [
          _buildMenuItem('Clientes', Icons.people,
          'http://localhost:8000/usuarios/clientes/'),
          _buildMenuItem('Profesionales', Icons.school,
          'http://localhost:8000/administrador/profesionales/'),
          _buildMenuItem('Profesiones',Icons.business_center,
          'http://localhost:8000/profesiones/lista/'),
          _buildMenuItem('Citas', Icons.calendar_today,
          'http://localhost:8000/administrador/lista_citas/'),
          _buildMenuItem('Perfil', Icons.person_outline, 
          'http://localhost:8000/usuarios/$idUsuario/'),
        ];
        break;
      case 'Cliente':
        options = [
          _buildMenuItem('Ver Citas Agendadas', Icons.calendar_today,
              'http://localhost:8000/cliente/$idUsuario/citas/'),
          _buildMenuItem('Agendar Cita', Icons.access_time,
              'http://localhost:8000/usuarios/citas/horarios_disponibles/'),
          _buildMenuItem('Reprogramar Cita', Icons.edit, 
              'http://localhost:8000/cliente/$idUsuario/citas/'),
          _buildMenuItem('Cancelar Cita', Icons.delete, 
              'http://localhost:8000/cliente/$idUsuario/citas/'),
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
      onTap: () async {
        setState(() {
          opcionSeleccionada = title;
        });
        await fetchData(url);
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
              for (var profession in fetchedData) {
                professionNames.add(profession["profesion__nombre_profesion"]);
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
            child = ReprogramarCitas(idUsuario: idUsuario);
            break;
          case 'Cancelar Cita':
            child = CancelarCitas(idUsuario: idUsuario);
            break;
          case 'Ver Ubicaciones':
            setState(() {
              professionNames = [];
              for (var profession in fetchedData) {
                professionNames.add(profession["profesion__nombre_profesion"]);
              }
            });
            child = VerUbicaciones(idUsuario: idUsuario, professionNames: professionNames);
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
            child = const VerProfesionales();
            break;
          case 'Profesiones':
            child = const VerProfesiones();
            break;
          case 'Citas':
            child = VerCitasAdmin(fetchedData);
            break;
          case 'Perfil':
            child = VerPerfil(fetchedUserData);
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
          case 'Agendar Cita':
            child = AgendarCita(idUsuario.toString()); //Obtencion de id para crear la cita, esto para que se consistente con mi back-end :c
            break;
          case 'Reprogramar Cita':
            child = ReagendarCitaScreen(fetchedData: fetchedData, currentidUser: idUsuario.toString());
            break;
          case 'Cancelar Cita':
            child = CancelarCitaScreen(fetchedData: fetchedData);
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
                    onPressed: () async {
                      setState(() {
                        idUsuario = 2 ;
                        rolUsuario = 'Profesional';
                        opcionSeleccionada = 'Ver Citas';
                      });
                      await fetchData(
                          'http://localhost:8000/profesional/$idUsuario/citas/');
                      await fetchUserData(
                          'http://localhost:8000/usuarios/$idUsuario/buscar/');
                    },
                    child: const Text('Profesional'),
                  ),
                  const SizedBox(width: 20), // Espacio entre los botones
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        idUsuario = 1;
                        rolUsuario = 'Cliente';
                        opcionSeleccionada = 'Ver Citas Agendadas';  
                      });
                      await fetchUserData(
                            'http://localhost:8000/usuarios/$idUsuario/buscar/');
                      await fetchData(
                            'http://localhost:8000/cliente/$idUsuario/citas/');
                    },
                    child: const Text('Cliente'),
                  ),
                  const SizedBox(width: 20), // Espacio entre los botones
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        idUsuario = 3;
                        rolUsuario = 'Administrador';
                        opcionSeleccionada = 'Clientes';
                      });
                      await fetchData('http://localhost:8000/usuarios/clientes/');
                      await fetchUserData(
                            'http://localhost:8000/usuarios/$idUsuario/buscar/');
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
                          accountEmail:
                              Text(fetchedUserData['correo_electronico']),
                          currentAccountPicture: const CircleAvatar(
                            backgroundImage:
                                AssetImage('lib/images/avatar.png'),
                          ),
                        ),
                        if (rolUsuario == 'Administrador')
                          const Padding(
                            padding: EdgeInsets.all(
                                8.0), // Ajustar el padding según sea necesario
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
