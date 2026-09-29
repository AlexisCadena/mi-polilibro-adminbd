-- =====================================================
-- Práctica: Clínica Veterinaria | Tema 1.5 (DML)
-- Motor: MySQL 8.0 | Requiere la base creada en el tema 1.4
-- =====================================================
USE veterinaria;

-- Paso 1. INSERT: registrar a los dueños
INSERT INTO dueno (id_dueno, nombre, telefono, direccion, correo) VALUES
    (1, 'Laura Martínez Ríos',  '5512345678', 'Av. Té 950, Granjas México',             'laura.mtz@gmail.com'),
    (2, 'Jorge Hernández Luna', '5523456789', 'Oriente 253, Agrícola Oriental',         'jorge.hl@hotmail.com'),
    (3, 'Ana Sofía Cruz Pérez', '5534567890', 'Av. Río Churubusco 1200, Iztacalco',     'anasofia.cruz@gmail.com'),
    (4, 'Ricardo Gómez Salas',  '5545678901', 'Sur 8 núm. 45, Agrícola Pantitlán',      'rgomez@outlook.com'),
    (5, 'Mariana López Vega',   '5556789012', 'Av. Tláhuac 300, Iztapalapa',            'mariana.lv@gmail.com');

SELECT * FROM dueno;

-- Paso 2. INSERT: registrar a los veterinarios
INSERT INTO veterinario (id_veterinario, nombre, cedula, especialidad, telefono, sueldo) VALUES
    (1, 'Dra. Paola Ramírez',  '12345678', 'Medicina general', '5511112222', 18500.00),
    (2, 'Dr. Luis Fernández',  '23456789', 'Cirugía',          '5522223333', 24000.00),
    (3, 'Dra. Carmen Ortiz',   '34567890', 'Dermatología',     '5533334444', 21000.00),
    (4, 'Dr. Andrés Molina',   '45678901', 'Medicina general', '5544445555', 17800.00);

SELECT * FROM veterinario;

-- Paso 3. INSERT: catálogo de medicamentos
INSERT INTO medicamento (id_medicamento, nombre, presentacion, precio, existencia) VALUES
    (1, 'Amoxicilina', 'Tabletas 250 mg',           185.50, 40),
    (2, 'Meloxicam',   'Suspensión oral 15 ml',     230.00, 25),
    (3, 'Ivermectina', 'Solución inyectable 50 ml', 310.00, 12),
    (4, 'Omeprazol',   'Cápsulas 20 mg',             95.00, 60),
    (5, 'Ketoconazol', 'Shampoo 250 ml',            275.00, 18);

SELECT * FROM medicamento;

-- Paso 4. INSERT: registrar las mascotas (id_dueno debe existir en dueno)
INSERT INTO mascota (id_mascota, nombre, especie, raza, fecha_nacimiento, sexo, peso_kg, id_dueno) VALUES
    (1, 'Firulais', 'Perro', 'Labrador',         '2019-03-14', 'M', 28.50, 1),
    (2, 'Michi',    'Gato',  'Siamés',           '2021-07-02', 'H',  4.20, 1),
    (3, 'Rocky',    'Perro', 'Pastor alemán',    '2018-11-20', 'M', 32.00, 2),
    (4, 'Luna',     'Gato',  'Persa',            '2022-01-09', 'H',  3.80, 3),
    (5, 'Kiwi',     'Ave',   'Periquito',        '2023-05-30', 'M',  0.05, 3),
    (6, 'Max',      'Perro', 'Chihuahua',        '2020-09-12', 'M',  2.90, 4),
    (7, 'Nala',     'Perro', 'Golden retriever', '2021-12-25', 'H', 26.40, 4);

SELECT * FROM mascota;

-- Paso 5. INSERT: registrar las consultas (mascota y veterinario deben existir)
INSERT INTO consulta (id_consulta, fecha, hora, motivo, diagnostico, costo, id_mascota, id_veterinario) VALUES
    (1, '2026-09-01', '09:30', 'Vacunación anual',          'Sano, se aplica vacuna múltiple', 450.00, 1, 1),
    (2, '2026-09-03', '11:00', 'Vómito y falta de apetito', 'Gastritis leve',                  600.00, 2, 1),
    (3, '2026-09-05', '16:15', 'Cojera en pata trasera',    'Esguince, reposo 2 semanas',      850.00, 3, 2),
    (4, '2026-09-10', '10:45', 'Caída de pelo',             'Dermatitis por hongos',           700.00, 4, 3),
    (5, '2026-09-12', '13:00', 'Revisión general',          'Sano',                            350.00, 5, 4),
    (6, '2026-09-15', '17:30', 'Herida en oreja',           'Otitis infecciosa',               650.00, 6, 2),
    (7, '2026-09-20', '12:00', 'Parásitos',                 'Infestación de pulgas',           500.00, 7, 3),
    (8, '2026-09-25', '09:00', 'Seguimiento de gastritis',  'Mejoría notable',                 300.00, 2, 1);

SELECT * FROM consulta;

-- Paso 6. INSERT en la tabla intermedia: qué medicamentos se recetaron en cada consulta
INSERT INTO receta (id_consulta, id_medicamento, cantidad, indicaciones) VALUES
    (2, 4, 1, '1 cápsula cada 24 h por 7 días'),
    (3, 2, 1, '5 ml cada 24 h por 5 días'),
    (4, 5, 1, 'Baño cada 3 días'),
    (6, 1, 2, '1 tableta cada 12 h por 10 días'),
    (6, 2, 1, '3 ml cada 24 h por 3 días'),
    (7, 3, 1, 'Dosis única'),
    (8, 4, 1, '1 cápsula cada 24 h por 7 días más');

SELECT * FROM receta;

-- Paso 7. Integridad referencial: intentar registrar una mascota con un dueño que NO existe
-- (esta instrucción DEBE fallar con el error 1452)
INSERT INTO mascota (id_mascota, nombre, especie, raza, fecha_nacimiento, sexo, peso_kg, id_dueno)
VALUES (8, 'Toby', 'Perro', 'Beagle', '2022-04-04', 'M', 12.00, 99);

-- Paso 8. UPDATE: modificar datos que ya existen
-- Sube 10 % el precio de los medicamentos con poca existencia (Ivermectina y Ketoconazol)
UPDATE medicamento
SET    precio = precio * 1.10
WHERE  id_medicamento IN (3, 5);

-- Corrige el peso de Firulais después de pesarlo otra vez
UPDATE mascota
SET    peso_kg = 29.10
WHERE  id_mascota = 1;

SELECT id_medicamento, nombre, precio, existencia FROM medicamento;

-- Paso 9. DELETE: eliminar registros
-- Mariana López (id 5) se registró pero nunca llevó mascotas, así que se da de baja
DELETE FROM dueno
WHERE  id_dueno = 5;

SELECT * FROM dueno;

-- Paso 10. SELECT con WHERE y ORDER BY
-- Perros de más de 10 kg, del más pesado al más ligero
SELECT nombre, raza, peso_kg
FROM   mascota
WHERE  especie = 'Perro' AND peso_kg > 10
ORDER  BY peso_kg DESC;

-- Paso 11. SELECT con BETWEEN y LIKE
-- Consultas de la primera quincena de septiembre cuyo diagnóstico empieza con "S" o "G"
SELECT id_consulta, fecha, motivo, diagnostico, costo
FROM   consulta
WHERE  fecha BETWEEN '2026-09-01' AND '2026-09-15'
  AND  (diagnostico LIKE 'S%' OR diagnostico LIKE 'G%')
ORDER  BY fecha;

-- Paso 12. SELECT sobre la vista creada en el tema 1.4
SELECT *
FROM   v_mascotas_duenos
ORDER  BY dueno, mascota;

-- Paso 13. Funciones de agregado: COUNT, SUM, AVG, MIN y MAX
SELECT COUNT(*)            AS total_consultas,
       SUM(costo)          AS ingresos,
       ROUND(AVG(costo),2) AS costo_promedio,
       MIN(costo)          AS mas_barata,
       MAX(costo)          AS mas_cara
FROM   consulta;

-- Paso 14. Agregado por grupos: GROUP BY
SELECT especie,
       COUNT(*)               AS mascotas,
       ROUND(AVG(peso_kg), 2) AS peso_promedio,
       MAX(peso_kg)           AS peso_maximo
FROM   mascota
GROUP  BY especie
ORDER  BY mascotas DESC;
