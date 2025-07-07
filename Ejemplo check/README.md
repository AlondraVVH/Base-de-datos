# Proyecto Base de Datos: ejemploSelect

## 👨‍🏫 Descripción

Este proyecto fue desarrollado como parte del curso de SQL básico. Contiene la creación de una base de datos relacional llamada `ejemploSelect`, donde se modelan usuarios, sus tipos, ciudades y datos personales.

Se incluyen:
- Script completo para creación de tablas con restricciones básicas.
- Campos de auditoría (`created_at`, `updated_at`).
- Restricciones `DEFAULT` y `CHECK` aplicadas de forma simple y educativa.
- Población de datos.
- Consultas `SELECT` usando `WHERE` para práctica.

---


## 🧾 Contenido del Script

- **tipo_usuarios**: contiene tipos como "Administrador", "Cliente", etc.
- **usuarios**: credenciales, email, tipo y estado.
- **ciudad**: ciudades y regiones donde residen los usuarios.
- **personas**: datos personales como nombre, RUT y ciudad de origen.

Cada tabla tiene:
- Auditoría: `created_at`, `updated_at`
- Restricciones `DEFAULT`
- Restricción `CHECK` explicada

---

## 📋 Consultas SELECT

Se realizaron consultas como:
- Usuarios de tipo Cliente
- Personas nacidas después de 1990
- Personas que comienzan con "A"
- Usuarios con correos @mail.com
- Personas que no viven en Valparaíso
- Usernames con más de 7 caracteres
- Personas nacidas entre 1990 y 1995

---

## 🧰 Herramientas

- MySQL Workbench (para crear ERD y ejecutar scripts)
- Visual Studio Code o editor de texto
- Git y GitHub

---

## 👩‍💻 Instrucciones de uso

1. Abre `script.sql` en MySQL Workbench y ejecútalo para crear la BD y poblarla.
2. Ejecuta las consultas desde `consultas.sql`.
3. Verifica los resultados (o revisa las imágenes en `evidencias/`).
4. Visualiza el diagrama en `erd.png`.

---

## 📝 Autor

- Nombre: Alondra Pino
- Curso: Introducción a Bases de Datos / SQL Básico
- Año: 2025
