-- READ
SELECT * FROM Usuarios;
SELECT * FROM Pacientes;
SELECT * FROM Medicos;
SELECT * FROM Consultas;
SELECT * FROM Citas;

-- UPDATE
UPDATE Usuarios
SET telefono = '111222333'
WHERE idUsuario = 2;

UPDATE Pacientes
SET fechaNacimiento = '1995-05-10'
WHERE idPaciente = 3;

UPDATE Medicos
SET especialidad = 'Medicina Interna'
WHERE idMedico = 4;

UPDATE Consultas
SET diagnostico = 'Hipertensión leve'
WHERE idConsulta = 2;

UPDATE Citas
SET estado = 'rechazada'
WHERE idCita = 3;

-- DELETE
SET SQL_SAFE_UPDATES = 0; -- desactiva el modo seguro
SET SQL_SAFE_UPDATES = 1; -- activa el modo seguro 

DELETE FROM Pacientes WHERE idUsuario = 2;
DELETE FROM Medicos WHERE idMedico = 6;
DELETE FROM ConsultaTratamiento WHERE idConsulta = 3;
DELETE FROM Consultas WHERE idConsulta = 3;
DELETE FROM Usuarios WHERE idUsuario = 2;