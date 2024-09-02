import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendarCita extends StatefulWidget {
  const AgendarCita({super.key});

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
                  return ListTile(
                    title: Text('Fecha: ${availableSlots[index]['fecha']}'),
                    subtitle: Text('Hora: ${availableSlots[index]['hora_inicio']} - ${availableSlots[index]['hora_fin']}'),
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
