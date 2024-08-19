-- Create model Usuario
CREATE TABLE `usuarios_usuario` (
 `id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `nombre` varchar(100) NOT NULL,
 `correo_electronico` varchar(254) NOT NULL UNIQUE,
 `contrasena` varchar(255) NOT NULL,
 `rol` varchar(20) NOT NULL
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
 `usuario_id` bigint NOT NULL
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
 `fecha` date NOT NULL,
 `hora_inicio` time(6) NOT NULL,
 `hora_fin` time(6) NOT NULL,
 `estado` varchar(20) NOT NULL,
 `cliente_id` bigint NOT NULL,
 `profesional_id` bigint NOT NULL,
 `ubicacion_id` bigint NOT NULL
 );

ALTER TABLE `citas_cita`
 ADD CONSTRAINT `citas_cita_cliente_id_c277d0e3_fk_usuarios_usuario_id`
 FOREIGN KEY (`cliente_id`) REFERENCES `usuarios_usuario` (`id`);
 
ALTER TABLE `citas_cita`
 ADD CONSTRAINT `citas_cita_profesional_id_105a49ce_fk_profesion`
 FOREIGN KEY (`profesional_id`) REFERENCES `profesionales_profesional` (`id`);
 
ALTER TABLE `citas_cita`
 ADD CONSTRAINT `citas_cita_ubicacion_id_4ca0e7d4_fk_ubicaciones_ubicacion_id`
 FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones_ubicacion` (`id`);
 
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
 
-- Create model Ubicacion
CREATE TABLE `ubicaciones_ubicacion` (
`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY,
 `direccion` varchar(255) NOT NULL,
 `profesional_id` bigint NOT NULL
 );
 
ALTER TABLE `ubicaciones_ubicacion`
 ADD CONSTRAINT `ubicaciones_ubicacio_profesional_id_2d8ac087_fk_profesion`
 FOREIGN KEY (`profesional_id`) REFERENCES `profesionales_profesional` (`id`);