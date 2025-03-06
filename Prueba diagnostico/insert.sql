-- Inserción de datos
-- Tabla TipoUsuario
INSERT INTO TipoUsuario (nombre) VALUES 
('Paciente'), ('Médico'), ('Administrativo'), ('Enfermero'), ('Técnico'), ('Recepcionista'), ('Especialista');



INSERT INTO Usuarios (nombre, rut, correo, telefono, idTipoUsuario) VALUES
('Juan Pérez', '12345678-9', 'juan@example.com', '123456789', 1),
('Dr. Carlos López', '23456789-0', 'carlos@example.com', '987654321', 2),
('Ana Gómez', '34567890-1', 'ana@example.com', '555555555', 3),
('Luisa Martínez', '45678901-2', 'luisa@example.com', '111111111', 1),
('Dr. Pedro Sánchez', '56789012-3', 'pedro@example.com', '222222222', 2),
('María Torres', '67890123-4', 'maria@example.com', '333333333', 1),
('Dr. Roberto Díaz', '78901234-5', 'roberto@example.com', '444444444', 2);

-- Tabla Pacientes
INSERT INTO Pacientes (idUsuario, fechaNacimiento) VALUES
(1, '1990-05-15'),
(4, '1985-12-20'),
(6, '1980-07-11'),
(3, '1995-03-22'),
(7, '2002-09-18');

-- Tabla Medicos
INSERT INTO Medicos (idUsuario, especialidad) VALUES
(2, 'Cardiología'),
(5, 'Pediatría'),
(7, 'Dermatología'),
(6, 'Neurología');

-- Tabla Consultas
INSERT INTO Consultas (idMedico, idPaciente, idTratamiento, fecha, hora, motivo, diagnostico) VALUES
(1, 1, '2023-10-01', '10:00:00', 'Dolor de pecho', 'Angina de pecho'),
(2, 2, '2023-10-02', '11:00:00', 'Fiebre alta', 'Gripe'),
(3, 3, '2023-10-03', '12:00:00', 'Dolor de cabeza', 'Migraña'),
(4, 4, '2023-10-04', '13:00:00', 'Dolor de espalda', 'Contractura muscular'),
(1, 5, '2023-10-05', '14:00:00', 'Mareos', 'Hipotensión'),
(2, 1, '2023-10-06', '09:00:00', 'Tos persistente', 'Bronquitis'),
(3, 2, '2023-10-07', '15:00:00', 'Falta de aire', 'Asma');

-- Tabla Tratamientos
INSERT INTO Tratamientos (nombre, descripcion) VALUES
('Medicamento X', 'Tomar cada 8 horas'),
('Terapia física', 'Sesiones de 30 minutos'),
('Cirugía menor', 'Intervención quirúrgica ambulatoria'),
('Fisioterapia', 'Ejercicios guiados por especialistas'),
('Reposo absoluto', 'Permanecer en cama sin esfuerzo físico'),
('Analgésicos', 'Alivio del dolor moderado'),
('Antibióticos', 'Tratamiento contra infecciones');


-- Tabla Citas
INSERT INTO Citas (idPaciente, fecha, hora, estado) VALUES
(1, '2023-10-10', '09:00:00', 'aprobada'),
(2, '2023-10-11', '14:00:00', 'rechazada'),
(3, '2023-10-12', '10:30:00', 'aprobada'),
(4, '2023-10-13', '11:15:00', 'rechazada'),
(5, '2023-10-14', '08:45:00', 'aprobada'),
(1, '2023-10-15', '13:30:00', 'aprobada'),
(2, '2023-10-16', '15:00:00', 'rechazada');