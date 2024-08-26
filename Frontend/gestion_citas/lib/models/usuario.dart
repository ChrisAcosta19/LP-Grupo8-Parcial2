// lib/models/usuario.dart
class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      correoElectronico: json['correo_electronico'],
      rol: json['rol'],
    );
  }
}
