-- =====================================================
-- Práctica Clínica Veterinaria | Tema 2.4 Transacciones, procedimientos,
-- disparadores, funciones y cursores
-- Motor MySQL 8.0 | Requiere el tema 2.3
-- =====================================================
USE veterinaria;

-- Paso 1. Transacción dentro de un procedimiento
DELIMITER $$
CREATE PROCEDURE sp_recetar(IN p_consulta INT, IN p_medicamento INT,
                            IN p_cantidad INT, IN p_indicaciones VARCHAR(150))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error. Se deshizo todo y no se guardó la receta' AS mensaje;
    END;
    START TRANSACTION;
    INSERT INTO receta VALUES (p_consulta, p_medicamento, p_cantidad, p_indicaciones);
    UPDATE medicamento SET existencia = existencia - p_cantidad
    WHERE  id_medicamento = p_medicamento;
    COMMIT;
    SELECT 'Receta guardada y existencia descontada' AS mensaje;
END $$
DELIMITER ;

-- Paso 2. Firulais (consulta 1) recibe 1 Amoxicilina. Hay existencia, así que se guarda
CALL sp_recetar(1, 1, 1, '1 tableta cada 12 h por 5 días');

-- Paso 3. Kiwi (consulta 5) pide 50 Ivermectinas y solo hay 12. El CHECK lo impide
CALL sp_recetar(5, 3, 50, 'Dosis de prueba');

-- Paso 4. Comprobar lo que quedó guardado
SELECT r.id_consulta, md.nombre AS medicamento, r.cantidad, md.existencia
FROM   medicamento md
LEFT JOIN receta r ON r.id_medicamento = md.id_medicamento
                  AND r.id_consulta IN (1, 5)
WHERE  md.id_medicamento IN (1, 3);

-- Paso 5. Tabla bitácora y disparador para las altas
CREATE TABLE bitacora_veterinario (
    id_bitacora    INT AUTO_INCREMENT PRIMARY KEY,
    id_veterinario INT,
    fecha          DATETIME,
    usuario        VARCHAR(50),
    actividad      VARCHAR(12),
    detalle        VARCHAR(150)
);

CREATE TRIGGER tg_veterinario_alta
AFTER INSERT ON veterinario
FOR EACH ROW
INSERT INTO bitacora_veterinario (id_veterinario, fecha, usuario, actividad, detalle)
VALUES (NEW.id_veterinario, NOW(), CURRENT_USER(), 'ALTA', NEW.nombre);

-- Paso 6. Disparadores para los cambios y las bajas
CREATE TRIGGER tg_veterinario_cambio
AFTER UPDATE ON veterinario
FOR EACH ROW
INSERT INTO bitacora_veterinario (id_veterinario, fecha, usuario, actividad, detalle)
VALUES (NEW.id_veterinario, NOW(), CURRENT_USER(), 'CAMBIO',
        CONCAT('Sueldo anterior ', OLD.sueldo, ' y nuevo ', NEW.sueldo));

CREATE TRIGGER tg_veterinario_baja
AFTER DELETE ON veterinario
FOR EACH ROW
INSERT INTO bitacora_veterinario (id_veterinario, fecha, usuario, actividad, detalle)
VALUES (OLD.id_veterinario, NOW(), CURRENT_USER(), 'BAJA', OLD.nombre);

SELECT trigger_name, action_timing, event_manipulation, event_object_table
FROM   information_schema.triggers
WHERE  trigger_schema = 'veterinaria';

-- Paso 7. Procedimientos para dar de alta, cambiar, consultar y dar de baja
CREATE PROCEDURE sp_alta_veterinario(IN p_id INT, IN p_nombre VARCHAR(60), IN p_cedula CHAR(8),
       IN p_especialidad VARCHAR(40), IN p_telefono CHAR(10), IN p_sueldo DECIMAL(10,2))
INSERT INTO veterinario VALUES (p_id, p_nombre, p_cedula, p_especialidad, p_telefono, p_sueldo);

CREATE PROCEDURE sp_cambiar_sueldo(IN p_id INT, IN p_sueldo DECIMAL(10,2))
UPDATE veterinario SET sueldo = p_sueldo WHERE id_veterinario = p_id;

CREATE PROCEDURE sp_consultar_especialidad(IN p_especialidad VARCHAR(40))
SELECT id_veterinario, nombre, sueldo FROM veterinario WHERE especialidad = p_especialidad;

CREATE PROCEDURE sp_baja_veterinario(IN p_id INT)
DELETE FROM veterinario WHERE id_veterinario = p_id;

SELECT routine_name, routine_type
FROM   information_schema.routines
WHERE  routine_schema = 'veterinaria';

-- Paso 8. Usar los procedimientos
CALL sp_alta_veterinario(5, 'Dra. Sofía Reyes', '56789012', 'Medicina general', '5566778899', 19500.00);
CALL sp_cambiar_sueldo(5, 20500.00);

CALL sp_alta_veterinario(6, 'Dr. Mario Vela', '67890123', 'Cirugía', '5577889900', 21000.00);
CALL sp_baja_veterinario(6);

CALL sp_consultar_especialidad('Medicina general');

-- Paso 9. La bitácora se llenó sola gracias a los disparadores
SELECT id_bitacora, id_veterinario, fecha, usuario, actividad, detalle
FROM   bitacora_veterinario
ORDER  BY id_bitacora;

-- Paso 10. Función que regresa cuánto ha gastado un dueño en consultas
CREATE FUNCTION fn_total_dueno(p_dueno INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
RETURN (SELECT IFNULL(SUM(c.costo), 0)
        FROM   consulta c
        INNER JOIN mascota m ON m.id_mascota = c.id_mascota
        WHERE  m.id_dueno = p_dueno);

SELECT nombre, fn_total_dueno(id_dueno) AS total_gastado
FROM   dueno
ORDER  BY total_gastado DESC;

-- Paso 11. Cursor que recorre uno por uno los medicamentos con poca existencia
DELIMITER $$
CREATE PROCEDURE sp_revisar_inventario()
BEGIN
    DECLARE v_nombre VARCHAR(60);
    DECLARE v_existencia, fin INT DEFAULT 0;
    DECLARE lista VARCHAR(500) DEFAULT '';
    DECLARE cur CURSOR FOR SELECT nombre, existencia FROM medicamento WHERE existencia < 20;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;
    OPEN cur;
    FETCH cur INTO v_nombre, v_existencia;
    WHILE fin = 0 DO
        SET lista = CONCAT(lista, v_nombre, ' quedan ', v_existencia, '. ');
        FETCH cur INTO v_nombre, v_existencia;
    END WHILE;
    CLOSE cur;
    SELECT lista AS medicamentos_por_surtir;
END $$
DELIMITER ;

-- Paso 12. Ejecutar el procedimiento con cursor
CALL sp_revisar_inventario();
