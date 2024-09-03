import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class AgendarCita extends StatefulWidget {
  final String actualClient;

  const AgendarCita(this.actualClient, {super.key});

  @override
  _AgendarCitaState createState() => _AgendarCitaState();
}

class _AgendarCitaState extends State<AgendarCita> {
  String? selectedProfession;
  String? selectedProfessional;
  List<dynamic> professions = [];
  List<dynamic> professionals = [];
  List<dynamic> availableSlots = [];
  
  @override
  void initState() {
    super.initState();
    fetchProfessions();
  }

  Future<void> fetchProfessions() async {
    final response = await http.get(Uri.parse('http://localhost:8000/profesiones/lista/'));
    if (response.statusCode == 200) {
      setState(() {
        professions = json.decode(response.body);
      });
    }
  }

  Future<void> fetchProfessionals(String professionId) async {
    final response = await http.get(Uri.parse('http://localhost:8000/profesionales/profesion/$professionId/'));
    if (response.statusCode == 200) {
      setState(() {
        professionals = json.decode(response.body);
      });
    }
  }

  Future<void> fetchAvailableSlots(String professionId, String professionalId) async {
    final response = await http.get(Uri.parse('http://localhost:8000/usuarios/citas/horarios_disponibles?profesion=$professionId&profesional=$professionalId'));
    if (response.statusCode == 200) {
      setState(() {
        availableSlots = json.decode(response.body);
      });
    }
  }

// Future Widger para la Creaciónn de citas por usuarios
Future<void> createAppointment(String fecha, String horaInicio, String horaFin) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/cliente/${widget.actualClient}/citas/crear'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'cliente': widget.actualClient, // Este codigo obteniene el id del cliente actual para el cliente actual xD
      'profesional': selectedProfessional,
      'ubicacion': '1', // Falta lógica para seleccionar una ubicación
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': 'Agendada', //cuando cliente agenda = cita agendada
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita agendada con éxito')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al agendar la cita')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedProfession,
              hint: const Text('Selecciona una Profesión'),
              items: professions.map<DropdownMenuItem<String>>((profession) {
                return DropdownMenuItem<String>(
                  value: profession['id'].toString(),
                  child: Text(profession['nombre_profesion']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProfession = value;
                  selectedProfessional = null; // Reset professional selection
                  professionals = [];
                  availableSlots = [];
                  fetchProfessionals(value!);
                });
              },
            ),
            const SizedBox(height: 20),
            if (professionals.isNotEmpty) // Mostrar solo si hay profesionales disponibles
              DropdownButtonFormField<String>(
                value: selectedProfessional,
                hint: const Text('Selecciona un Profesional'),
                items: professionals.map<DropdownMenuItem<String>>((professional) {
                  return DropdownMenuItem<String>(
                    value: professional['id'].toString(),
                    child: Text('${professional['usuario__nombre']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfessional = value;
                    fetchAvailableSlots(selectedProfession!, value!);
                  });
                },
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {    
                                 
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Cita disponible para ${availableSlots[index]["profesional__profesion__nombre_profesion"]}'),     
                      
                      subtitle: Column(

                        children: <Widget>[
                          Row(
                            children: [
                              const Icon(Icons.date_range),
                              const SizedBox(width: 8),
                              Text('Fecha: ${availableSlots[index]['fecha']}'),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time),
                              const SizedBox(width: 8),
                              Text('Hora: ${availableSlots[index]['hora_inicio']} - ${availableSlots[index]['hora_fin']}'),
                            ],
                          ),
                        ],
                      ),

                      trailing: ElevatedButton(
                        onPressed: () {
                          createAppointment(
                            availableSlots[index]['fecha'],
                            availableSlots[index]['hora_inicio'],
                            availableSlots[index]['hora_fin'],
                          );
                        },
                        child: const Text('Agendar Cita'),
                      ),

                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
