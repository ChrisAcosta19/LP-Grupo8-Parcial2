-- Create model Usuario
CREATE TABLE `usuarios_usuario` (
`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `nombre` varchar(100) NOT NULL,
 `correo_electronico` varchar(254) NOT NULL UNIQUE,
 `contrasena` varchar(255) NOT NULL,
 `rol` varchar(15) NOT NULL -- Roles validos: Cliente, Profesional, Administrador
 );
 
-- Create model Profesion
CREATE TABLE `profesiones_profesion` (
`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `nombre_profesion` varchar(100) NOT NULL
 );
 
-- Create model Profesional
CREATE TABLE `profesionales_profesional` (
`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `profesion_id` bigint NOT NULL,
 `usuario_id` bigint NOT NULL UNIQUE
 );
 
ALTER TABLE `profesionales_profesional`
 ADD CONSTRAINT `profesionales_profes_profesion_id_0ddd490d_fk_profesion`
 FOREIGN KEY (`profesion_id`) REFERENCES `profesiones_profesion` (`id`);
 
ALTER TABLE `profesionales_profesional`
 ADD CONSTRAINT `profesionales_profes_usuario_id_04be34f0_fk_usuarios_`
 FOREIGN KEY (`usuario_id`) REFERENCES `usuarios_usuario` (`id`);
 
-- Create model Cita
CREATE TABLE `citas_cita` (
`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `fecha_hora` datetime(6) NOT NULL,
 `estado` varchar(15) NOT NULL, -- Estados validos: Agendada, Reprogramada, Cancelada
 `cliente_id` bigint NOT NULL,
 `profesional_id` bigint NOT NULL
 );
 
ALTER TABLE `citas_cita`
 ADD CONSTRAINT `citas_cita_cliente_id_c277d0e3_fk_usuarios_usuario_id`
 FOREIGN KEY (`cliente_id`) REFERENCES `usuarios_usuario` (`id`);
 
ALTER TABLE `citas_cita`
 ADD CONSTRAINT `citas_cita_profesional_id_105a49ce_fk_profesion`
 FOREIGN KEY (`profesional_id`) REFERENCES `profesionales_profesional` (`id`);
 
-- Create model HorarioDisponible
CREATE TABLE `horarios_horariodisponible` (
`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `fecha` date NOT NULL,
 `hora_inicio` time(6) NOT NULL,
 `hora_fin` time(6) NOT NULL,
 `profesional_id` bigint NOT NULL
 );
 
ALTER TABLE `horarios_horariodisponible`
 ADD CONSTRAINT `horarios_horariodisp_profesional_id_658bd614_fk_profesion`
 FOREIGN KEY (`profesional_id`) REFERENCES `profesionales_profesional` (`id`);