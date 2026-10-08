-- =====================================================
-- Práctica Clínica Veterinaria | Tema 2.3 Concurrencia y bloqueos
-- Se necesitan DOS pestañas de conexión en Workbench (sesión 1 y sesión 2)
-- Ejecuta cada bloque en la sesión que indica y en el orden de los pasos
-- =====================================================

-- Paso 1. SESIÓN 1 abre una transacción y aparta la Amoxicilina
USE veterinaria;
SELECT CONNECTION_ID() AS sesion, @@transaction_isolation AS aislamiento;

START TRANSACTION;
UPDATE medicamento SET existencia = existencia - 5 WHERE id_medicamento = 1;

SELECT id_medicamento, nombre, existencia FROM medicamento WHERE id_medicamento = 1;
-- Todavía NO se hace COMMIT

-- Paso 2. SESIÓN 2 quiere el mismo medicamento al mismo tiempo
USE veterinaria;
SELECT CONNECTION_ID() AS sesion;

-- Todavía ve 40 porque la sesión 1 no ha confirmado
SELECT id_medicamento, nombre, existencia FROM medicamento WHERE id_medicamento = 1;

-- Este cambio se queda esperando el candado de la sesión 1
UPDATE medicamento SET existencia = existencia - 2 WHERE id_medicamento = 1;

-- Paso 3. SESIÓN 1 revisa quién espera a quién y luego confirma
SELECT waiting_pid  AS sesion_que_espera,
       waiting_query AS lo_que_quiere_hacer,
       blocking_pid AS sesion_que_bloquea,
       wait_age     AS tiempo_esperando
FROM   sys.innodb_lock_waits;

COMMIT;

-- Paso 4. SESIÓN 2 termina en cuanto la sesión 1 suelta el candado
SELECT id_medicamento, nombre, existencia FROM medicamento WHERE id_medicamento = 1;
-- 40 - 5 de la sesión 1 - 2 de la sesión 2 = 33. No se perdió ningún cambio

-- Paso 5. Abrazo mortal (ejecuta una instrucción a la vez, alternando sesiones)
-- SESIÓN 1
START TRANSACTION;
UPDATE medicamento SET existencia = existencia - 1 WHERE id_medicamento = 2;
-- SESIÓN 2
START TRANSACTION;
UPDATE medicamento SET existencia = existencia - 1 WHERE id_medicamento = 3;
-- SESIÓN 1 pide el medicamento 3 y se queda esperando
UPDATE medicamento SET existencia = existencia - 1 WHERE id_medicamento = 3;
-- SESIÓN 2 pide el medicamento 2. MySQL detecta el abrazo mortal (error 1213)
UPDATE medicamento SET existencia = existencia - 1 WHERE id_medicamento = 2;
-- SESIÓN 1 deshace su transacción para no alterar las existencias
ROLLBACK;
