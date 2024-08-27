import 'package:flutter/material.dart';

class VerClientes extends StatefulWidget {
  final List<dynamic> fetchedData;
  const VerClientes({super.key, required this.fetchedData});

  @override
  _VerClientesState createState() => _VerClientesState();
}

class _VerClientesState extends State<VerClientes> {
  late List<dynamic> _clientes;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _clientes = widget.fetchedData;
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _clientes = widget.fetchedData.where((cliente) {
        final nombre = cliente["nombre"]?.toLowerCase() ?? '';
        final correo = cliente["correo_electronico"]?.toLowerCase() ?? '';
        return nombre.contains(_searchQuery.toLowerCase()) || correo.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _showAddClienteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nombreController = TextEditingController();
        final TextEditingController correoController = TextEditingController();
        final TextEditingController passwordController = TextEditingController();

        return AlertDialog(
          title: Text('Agregar Nuevo Cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: correoController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true, // Oculta el texto de la contraseña
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              // Agrega más campos según sea necesario
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('AGREGAR'),
              onPressed: () {
                final nombre = nombreController.text;
                final correo = correoController.text;
                final password = passwordController.text;

                // Aquí puedes añadir la lógica para enviar los datos al servidor
                // Por ahora, solo actualizamos el estado local
                setState(() {
                  _clientes.add({
                    "nombre": nombre,
                    "correo_electronico": correo,
                    "contraseña": password, // Agregamos la contraseña aquí
                    "rol": "Cliente",
                  });
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'CLIENTE',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _updateSearchQuery,
                ),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _showAddClienteDialog,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add),
                    SizedBox(width: 4.0),
                    Text('NUEVO'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _clientes.isEmpty
              ? Center(child: Text('No hay clientes'))
              : ListView.builder(
                  itemCount: _clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = _clientes[index];
                    final nombre = cliente["nombre"] ?? "Nombre no disponible";
                    final correoElectronico = cliente["correo_electronico"] ?? "Correo electrónico no disponible";
                    final rol = cliente["rol"] ?? "Rol no disponible";

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Icon(Icons.email),
                                const SizedBox(width: 8),
                                Text(correoElectronico),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(Icons.card_membership),
                                const SizedBox(width: 8),
                                Text(rol),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
