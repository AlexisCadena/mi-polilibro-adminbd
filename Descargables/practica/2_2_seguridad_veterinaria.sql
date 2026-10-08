-- =====================================================
-- Práctica Clínica Veterinaria | Tema 2.2 Seguridad e integridad
-- Motor MySQL 8.0 | Requiere el tema 2.1
-- La contraseña es solo de práctica para el servidor local
-- =====================================================
USE veterinaria;

-- Paso 1. Crear un usuario para la recepción (como root)
CREATE USER 'recepcion'@'localhost' IDENTIFIED BY 'Recep#2026';

SELECT user, host, account_locked
FROM   mysql.user
WHERE  user = 'recepcion';

-- Paso 2. Dar permisos con GRANT
GRANT SELECT, INSERT ON veterinaria.dueno   TO 'recepcion'@'localhost';
GRANT SELECT, INSERT ON veterinaria.mascota TO 'recepcion'@'localhost';
GRANT SELECT         ON veterinaria.v_consultas_detalle TO 'recepcion'@'localhost';

SELECT grantee, table_name, privilege_type
FROM   information_schema.table_privileges
WHERE  grantee LIKE '%recepcion%'
ORDER  BY table_name, privilege_type;

-- Paso 3. En Workbench crear una conexión con el usuario recepcion

-- Paso 4. Probar los permisos (conectado como recepcion)
SELECT CURRENT_USER() AS usuario_conectado;

INSERT INTO mascota (id_mascota, nombre, especie, raza, fecha_nacimiento, sexo, peso_kg, id_dueno)
VALUES (8, 'Toby', 'Perro', 'Beagle', '2022-04-04', 'M', 12.00, 2);

SELECT id_mascota, nombre, especie, id_dueno FROM mascota;

-- Esta instrucción DEBE fallar con el error 1142
DELETE FROM mascota WHERE id_mascota = 8;

-- Paso 5. Quitar un permiso con REVOKE (conectado como root)
REVOKE INSERT ON veterinaria.mascota FROM 'recepcion'@'localhost';

SELECT grantee, table_name, privilege_type
FROM   information_schema.table_privileges
WHERE  grantee LIKE '%recepcion%'
ORDER  BY table_name, privilege_type;

-- Paso 6. Comprobar el REVOKE (conectado como recepcion)
SELECT id_mascota, nombre FROM mascota;

-- Esta instrucción DEBE fallar con el error 1142
INSERT INTO mascota (id_mascota, nombre, especie, raza, fecha_nacimiento, sexo, peso_kg, id_dueno)
VALUES (9, 'Pelusa', 'Gato', 'Angora', '2023-02-14', 'H', 3.10, 3);

-- Paso 7. Las reglas de integridad también cuidan los datos (como root)
-- DEBE fallar con el error 3819 porque CHECK no deja un sueldo negativo
INSERT INTO veterinario VALUES (5, 'Dr. Prueba Uno', '99999999', 'General', '5500000000', -500);
-- DEBE fallar con el error 1062 porque UNIQUE no deja repetir la cédula
INSERT INTO veterinario VALUES (5, 'Dr. Prueba Dos', '12345678', 'General', '5500000000', 15000);
