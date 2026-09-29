-- =====================================================
-- Práctica: Clínica Veterinaria | Tema 1.4 (DDL)
-- Motor: MySQL 8.0 | Herramienta: MySQL Workbench
-- =====================================================

-- Paso 1. Crear la base de datos
DROP DATABASE IF EXISTS veterinaria;

CREATE DATABASE veterinaria
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci;

USE veterinaria;

SHOW DATABASES;

-- Paso 2. Tablas catálogo (no dependen de otras tablas)
CREATE TABLE dueno (
    id_dueno     INT          NOT NULL PRIMARY KEY,
    nombre       VARCHAR(60)  NOT NULL,
    telefono     CHAR(10)     NOT NULL,
    direccion    VARCHAR(100),
    correo       VARCHAR(80)  UNIQUE
) ENGINE = InnoDB;

CREATE TABLE veterinario (
    id_veterinario INT           NOT NULL PRIMARY KEY,
    nombre         VARCHAR(60)   NOT NULL,
    cedula         CHAR(8)       NOT NULL UNIQUE,
    especialidad   VARCHAR(40),
    telefono       CHAR(10),
    sueldo         DECIMAL(10,2) NOT NULL CHECK (sueldo > 0)
) ENGINE = InnoDB;

SHOW TABLES;

-- Paso 3. Catálogo de medicamentos y tabla mascota (con llave foránea)
CREATE TABLE medicamento (
    id_medicamento INT           NOT NULL PRIMARY KEY,
    nombre         VARCHAR(60)   NOT NULL,
    presentacion   VARCHAR(40),
    precio         DECIMAL(8,2)  NOT NULL CHECK (precio >= 0),
    existencia     INT           NOT NULL DEFAULT 0 CHECK (existencia >= 0)
) ENGINE = InnoDB;

CREATE TABLE mascota (
    id_mascota       INT         NOT NULL PRIMARY KEY,
    nombre           VARCHAR(40) NOT NULL,
    especie          VARCHAR(20) NOT NULL,
    raza             VARCHAR(40),
    fecha_nacimiento DATE,
    sexo             CHAR(1)     CHECK (sexo IN ('M','H')),
    id_dueno         INT         NOT NULL,
    CONSTRAINT fk_mascota_dueno FOREIGN KEY (id_dueno)
        REFERENCES dueno (id_dueno)
) ENGINE = InnoDB;

SHOW TABLES;

-- Paso 4. Tabla consulta: depende de mascota y de veterinario
CREATE TABLE consulta (
    id_consulta    INT           NOT NULL PRIMARY KEY,
    fecha          DATE          NOT NULL,
    hora           TIME          NOT NULL,
    motivo         VARCHAR(100)  NOT NULL,
    diagnostico    VARCHAR(150),
    costo          DECIMAL(8,2)  NOT NULL CHECK (costo >= 0),
    id_mascota     INT           NOT NULL,
    id_veterinario INT           NOT NULL,
    CONSTRAINT fk_consulta_mascota FOREIGN KEY (id_mascota)
        REFERENCES mascota (id_mascota),
    CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario)
        REFERENCES veterinario (id_veterinario)
) ENGINE = InnoDB;

DESCRIBE consulta;

-- Paso 5. Tabla intermedia de la relación N:M consulta - medicamento
CREATE TABLE receta (
    id_consulta    INT          NOT NULL,
    id_medicamento INT          NOT NULL,
    cantidad       INT          NOT NULL CHECK (cantidad > 0),
    indicaciones   VARCHAR(150),
    PRIMARY KEY (id_consulta, id_medicamento),
    CONSTRAINT fk_receta_consulta FOREIGN KEY (id_consulta)
        REFERENCES consulta (id_consulta),
    CONSTRAINT fk_receta_medicamento FOREIGN KEY (id_medicamento)
        REFERENCES medicamento (id_medicamento)
) ENGINE = InnoDB;

SHOW TABLES;

-- Paso 6. Modificar la estructura: ALTER TABLE y DROP TABLE
-- Agregar una columna que faltó en el diseño
ALTER TABLE mascota ADD COLUMN peso_kg DECIMAL(5,2) AFTER sexo;

-- Agregar y después quitar una columna que ya no se usa
ALTER TABLE dueno ADD COLUMN fax VARCHAR(15);
ALTER TABLE dueno DROP COLUMN fax;

-- Crear una tabla de prueba y eliminarla completa
CREATE TABLE proveedor_prueba (
    id_proveedor INT PRIMARY KEY,
    nombre       VARCHAR(60)
);
DROP TABLE proveedor_prueba;

DESCRIBE mascota;

-- Paso 7. Otros objetos: vista (VIEW) e índices (INDEX)
CREATE VIEW v_mascotas_duenos AS
    SELECT m.id_mascota, m.nombre AS mascota, m.especie,
           d.nombre AS dueno, d.telefono
    FROM mascota m
    INNER JOIN dueno d ON d.id_dueno = m.id_dueno;

CREATE INDEX idx_mascota_especie ON mascota (especie);
CREATE INDEX idx_consulta_fecha  ON consulta (fecha DESC);

SHOW INDEX FROM mascota;

-- Paso 8. ¿Dónde y cómo guarda MySQL la base de datos?
SELECT @@datadir                AS carpeta_de_datos,
       @@default_storage_engine AS motor,
       @@innodb_page_size       AS bytes_por_pagina;

-- Espacio que ocupa cada objeto de la base de datos
SELECT table_name   AS objeto,
       table_type   AS tipo,
       engine       AS motor,
       data_length  AS bytes_datos,
       index_length AS bytes_indices
FROM information_schema.tables
WHERE table_schema = 'veterinaria'
ORDER BY table_type, table_name;
