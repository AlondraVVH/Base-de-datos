-- 1.-  Mostrar todos los usuarios de tipo Cliente
-- Seleccionar nombre de usuario, correo y tipo_usuario
SELECT u.username, u.email, t.nombre_tipo 
FROM usuarios u
INNER JOIN tipo_usuarios t ON  u.id_tipo_usuario = t.id_tipo 
WHERE u.id_tipo_usuario = 2;

-- 2.-  Mostrar Personas nacidas despues del año 1990
-- Seleccionar Nombre, fecha de nacimiento y username.
SELECT p.rut, p.nombre_completo, p.fecha_nac, u.username 
FROM personas p 
INNER JOIN usuarios u ON u.id_usuario = p.id_usuario 
WHERE "1990-01-01" <= fecha_nac;

-- 3.- Seleccionar nombres de personas que comiencen con la 
-- letra A - Seleccionar nombre y correo la persona.
SELECT p.nombre_completo , u.email
FROM usuarios u
INNER JOIN personas p ON u.id_usuario = p.id_usuario
WHERE p.nombre_completo LIKE "A%";

-- 4.- Mostrar usuarios cuyos dominios de correo sean
-- mail.commit LIKE '%mail.com%'
SELECT u.id_usuario, u.username, p.nombre_completo, u.email 
FROM usuarios u 
INNER JOIN personas p ON p.id_usuario = u.id_usuario
WHERE email LIKE "%mail.com%";

-- 5.- Mostrar todas las personas que no viven en 
-- Valparaiso y su usuario + ciudad.
 -- select * from ciudad; -- ID 2 VALPARAISO
SELECT u.username ,c.nombre_ciudad
FROM usuarios u INNER JOIN personas p ON p.id_usuario = u.id_usuario
INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad  
WHERE c.id_ciudad != 2;

-- 6.- Mostrar usuarios que contengan más de 7 
-- carácteres de longitud.
SELECT u.id_usuario, u.username, p.nombre_completo, u.email 
FROM usuarios u 
INNER JOIN personas p ON p.id_usuario = u.id_usuario 
WHERE length(u.username) > 7;

-- 7.- Mostrar username de personas nacidas entre
-- 1990 y 1995
SELECT u.username, p.fecha_nac 
FROM usuarios u
INNER JOIN personas p ON p.id_usuario = u.id_usuario 
WHERE p.fecha_nac BETWEEN "1990-01-01" AND "1995-12-31";