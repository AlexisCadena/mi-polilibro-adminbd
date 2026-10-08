-- =====================================================
-- Práctica Clínica Veterinaria | Tema 2.1 Consultas simples y multitabla
-- Motor MySQL 8.0 | Requiere la base de los temas 1.4 y 1.5
-- =====================================================
USE veterinaria;

-- Paso 1. Vista multitabla con WHERE
CREATE VIEW v_consultas_detalle AS
SELECT c.id_consulta, c.fecha, m.nombre AS mascota, d.nombre AS dueno,
       v.nombre AS veterinario, c.motivo, c.costo
FROM   consulta c, mascota m, dueno d, veterinario v
WHERE  c.id_mascota     = m.id_mascota
  AND  m.id_dueno       = d.id_dueno
  AND  c.id_veterinario = v.id_veterinario;

SELECT * FROM v_consultas_detalle ORDER BY fecha;

-- Paso 2. Vista multitabla con INNER JOIN
CREATE VIEW v_recetas AS
SELECT c.fecha, m.nombre AS mascota, md.nombre AS medicamento,
       r.cantidad, r.indicaciones
FROM   receta r
INNER JOIN consulta    c  ON c.id_consulta     = r.id_consulta
INNER JOIN mascota     m  ON m.id_mascota      = c.id_mascota
INNER JOIN medicamento md ON md.id_medicamento = r.id_medicamento;

SELECT * FROM v_recetas ORDER BY fecha;

-- Paso 3. LEFT JOIN para ver también las consultas sin receta
SELECT c.id_consulta, c.fecha, c.motivo, r.id_medicamento, r.cantidad
FROM   consulta c
LEFT JOIN receta r ON r.id_consulta = c.id_consulta
ORDER  BY c.id_consulta;

-- Paso 4. Agrupar datos de dos tablas con GROUP BY y HAVING
SELECT v.nombre      AS veterinario,
       COUNT(*)      AS consultas,
       SUM(c.costo)  AS ingresos
FROM   consulta c
INNER JOIN veterinario v ON v.id_veterinario = c.id_veterinario
GROUP  BY v.nombre
HAVING SUM(c.costo) >= 1000
ORDER  BY ingresos DESC;

-- Paso 5. Subconsulta
SELECT m.nombre AS mascota, m.especie, c.motivo, c.costo
FROM   consulta c
INNER JOIN mascota m ON m.id_mascota = c.id_mascota
WHERE  c.costo > (SELECT AVG(costo) FROM consulta)
ORDER  BY c.costo DESC;
