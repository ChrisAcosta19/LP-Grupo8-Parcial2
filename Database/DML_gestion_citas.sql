-- DROP DATABASE IF EXISTS gestion_citas;
-- CREATE DATABASE gestion_citas;
USE gestion_citas;

INSERT INTO `usuarios_usuario` (`nombre`, `correo_electronico`, `contrasena`, `rol`) VALUES
('Christopher Acosta', 'chriacos@espol.edu.ec', 'test123', 'Profesional'),
('Peter Miranda', 'pemiplua@espol.edu.ec', 'test456', 'Cliente'),
('Jefferson Eras', 'jeras@espol.edu.ec', 'test789', 'Administrador');

INSERT INTO `profesiones_profesion` (`nombre_profesion`) VALUES
('Abogado'),
('Contador');

INSERT INTO `profesionales_profesional` (`profesion_id`, `usuario_id`) VALUES
(1, 1),
(2, 1);

INSERT INTO `horarios_horariodisponible` (`fecha`, `hora_inicio`, `hora_fin`, `profesional_id`) VALUES
('2024-08-17', '08:00:00.000000', '08:30:00.000000', 1),
('2024-08-17', '08:30:00.000000', '09:00:00.000000', 2);

INSERT INTO `ubicaciones_ubicacion` (`direccion`, `profesional_id`) VALUES
('Oficina 1', 1),
('Oficina 2', 2);

INSERT INTO `citas_cita` (`fecha`, `hora_inicio`, `hora_fin`, `estado`, `cliente_id`, `profesional_id`, `ubicacion_id`) VALUES
('2024-08-17', '07:00:00.000000', '07:30:00.000000', 'Agendada', 2, 1, 2),
('2024-08-16', '18:00:00.000000', '18:30:00.000000', 'Reprogramada', 2, 1, 2),
('2024-08-15', '20:00:00.000000', '20:30:00.000000', 'Agendada', 2, 2, 1),
('2024-08-14', '19:00:00.000000', '19:30:00.000000', 'Cancelada', 2, 2, 1);