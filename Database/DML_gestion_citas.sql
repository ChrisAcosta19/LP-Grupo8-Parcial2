USE gestion_citas;

INSERT INTO `usuarios_usuario` (`nombre`, `correo_electronico`, `contrasena`, `rol`) VALUES
('Christopher Acosta', 'chriacos@espol.edu.ec', 'test123', 'Profesional'),
('Peter Miranda', 'pemiplua@espol.edu.ec', 'test456', 'Cliente');

INSERT INTO `profesiones_profesion` (`nombre_profesion`) VALUES
('Abogado');

INSERT INTO `profesionales_profesional` (`profesion_id`, `usuario_id`) VALUES
(1, 1);

INSERT INTO `horarios_horariodisponible` (`fecha`, `hora_inicio`, `hora_fin`, `profesional_id`) VALUES
('2024-08-17', '08:00:00.000000', '08:30:00.000000', 1),
('2024-08-17', '08:30:00.000000', '09:00:00.000000', 1);

INSERT INTO `citas_cita` (`fecha_hora`, `estado`, `cliente_id`, `profesional_id`) VALUES
('2024-08-17 07:00:00.000000', 'Agendada', 2, 1),
('2024-08-16 18:00:00.000000', 'Reprogramada', 2, 1),
('2024-08-16 19:00:00.000000', 'Cancelada', 2, 1);