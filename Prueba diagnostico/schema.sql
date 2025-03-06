-- Creación de la Base de Datos
CREATE DATABASE Clinica;
USE Clinica;

-- Tabla TipoUsuario
CREATE TABLE TipoUsuario (
    idTipoUsuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla Usuarios
CREATE TABLE Usuarios (
    idUsuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    rut VARCHAR(12) NOT NULL UNIQUE, 
    correo VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    idTipoUsuario INT,
    FOREIGN KEY (idTipoUsuario) REFERENCES TipoUsuario(idTipoUsuario)
);

-- Tabla Pacientes
CREATE TABLE Pacientes (
    idPaciente INT PRIMARY KEY AUTO_INCREMENT,
    idUsuario INT UNIQUE,
    fechaNacimiento DATE,
    FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario)
);

-- Tabla Medicos
CREATE TABLE Medicos (
    idMedico INT PRIMARY KEY AUTO_INCREMENT,
    idUsuario INT UNIQUE,
    especialidad VARCHAR(100) NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario)
);

-- Tabla Consultas
CREATE TABLE Consultas (
    idConsulta INT PRIMARY KEY AUTO_INCREMENT,
    idMedico INT,
    idPaciente INT,
    idTratamiento INT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    motivo TEXT,
    diagnostico TEXT,
    FOREIGN KEY (idMedico) REFERENCES Medicos(idMedico),
    FOREIGN KEY (idPaciente) REFERENCES Pacientes(idPaciente)
);

-- Tabla Tratamientos
CREATE TABLE Tratamientos (
    idTratamiento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);


-- Tabla Citas
CREATE TABLE Citas (
    idCita INT PRIMARY KEY AUTO_INCREMENT,
    idPaciente INT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado ENUM('aprobada', 'rechazada') DEFAULT 'aprobada',
    FOREIGN KEY (idPaciente) REFERENCES Pacientes(idPaciente)
);