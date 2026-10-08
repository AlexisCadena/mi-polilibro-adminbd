-- =====================================================
-- Práctica Clínica Veterinaria | Tema 2.5 Respaldos y recuperación
-- Motor MySQL 8.0 | Requiere el tema 2.4
-- La ruta debe ser la carpeta que indica secure_file_priv en tu servidor
-- =====================================================
USE veterinaria;

-- Paso 1. ¿Dónde puede escribir respaldos MySQL y está activo su registro?
SHOW VARIABLES
WHERE Variable_name IN ('secure_file_priv', 'log_bin', 'log_bin_basename');

-- Paso 2. Respaldar la tabla receta en un archivo
SELECT * FROM receta
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/receta_respaldo.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT COUNT(*) AS filas_respaldadas FROM receta;

-- Paso 3. Accidente. Alguien vacía la tabla receta por error
TRUNCATE TABLE receta;

SELECT COUNT(*) AS recetas_que_quedan FROM receta;

-- Paso 4. Recuperar la tabla desde el respaldo
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/receta_respaldo.csv'
INTO TABLE receta
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT * FROM v_recetas ORDER BY fecha;
