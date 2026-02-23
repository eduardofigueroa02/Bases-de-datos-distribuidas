-- Crear la base de datos vacía
CREATE DATABASE IF NOT EXISTS customerDB
  DEFAULT CHARACTER SET utf8;
  
-- Crear las tablas en customerDB
USE customerDB;

CREATE TABLE address (
  addressID INT(11)      NOT NULL AUTO_INCREMENT,
  street    VARCHAR(100) DEFAULT NULL,
  localy    VARCHAR(50)  DEFAULT NULL,
  city      VARCHAR(50)  DEFAULT NULL,
  postcode  VARCHAR(10)  DEFAULT NULL,
  state     VARCHAR(50)  DEFAULT NULL,
  PRIMARY KEY (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE customer (
  customerID INT(11)      NOT NULL AUTO_INCREMENT,
  name       VARCHAR(100) DEFAULT NULL,
  phone      VARCHAR(20)  DEFAULT NULL,
  email      VARCHAR(100) DEFAULT NULL,
  addressID  INT(11)      DEFAULT NULL,
  PRIMARY KEY (customerID),
  KEY addressID (addressID),
  CONSTRAINT customer_ibfk_1
    FOREIGN KEY (addressID) REFERENCES address (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Ahora sí, insertar TODAS las direcciones
INSERT INTO customerDB.address
SELECT * FROM salesdb.address;

-- Y luego los clientes (esto ya no debería fallar)
INSERT INTO customerDB.customer
SELECT * FROM salesdb.customer;

-- Verificar
SELECT COUNT(*) AS direcciones FROM customerDB.address;
SELECT COUNT(*) AS clientes    FROM customerDB.customer;

-- Fragmento vertical 2 (lo mismo pero para el otro fragmento)
-- 1. Crear BD
CREATE DATABASE IF NOT EXISTS supplierDB DEFAULT CHARACTER SET utf8;

-- 2. Crear tablas
USE supplierDB;

CREATE TABLE address (
  addressID INT(11)      NOT NULL AUTO_INCREMENT,
  street    VARCHAR(100) DEFAULT NULL,
  localy    VARCHAR(50)  DEFAULT NULL,
  city      VARCHAR(50)  DEFAULT NULL,
  postcode  VARCHAR(10)  DEFAULT NULL,
  state     VARCHAR(50)  DEFAULT NULL,
  PRIMARY KEY (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE supplier (
  supplierID INT(11)      NOT NULL AUTO_INCREMENT,
  name       VARCHAR(100) DEFAULT NULL,
  phone      VARCHAR(20)  DEFAULT NULL,
  email      VARCHAR(100) DEFAULT NULL,
  addressID  INT(11)      DEFAULT NULL,
  PRIMARY KEY (supplierID),
  KEY addressID (addressID),
  CONSTRAINT supplier_ibfk_1
    FOREIGN KEY (addressID) REFERENCES address (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 3. Copiar datos
INSERT INTO supplierDB.address
SELECT a.*
  FROM salesdb.address a
 INNER JOIN salesdb.supplier s ON s.addressID = a.addressID;

INSERT INTO supplierDB.supplier
SELECT * FROM salesdb.supplier;

-- 4. Verificar
SELECT COUNT(*) FROM supplierDB.supplier;

-- FRAGMENTO HORIZONTAL
-- La lógica es la misma pero el INSERT tiene un WHERE que filtra por estado
-- ══════════════════════════════════
--  zona1DB  →  CDMX e Hidalgo
-- ══════════════════════════════════

CREATE DATABASE IF NOT EXISTS zona1DB DEFAULT CHARACTER SET utf8;
USE zona1DB;

CREATE TABLE address (
  addressID INT(11) NOT NULL AUTO_INCREMENT,
  street VARCHAR(100) DEFAULT NULL,
  localy VARCHAR(50) DEFAULT NULL,
  city VARCHAR(50) DEFAULT NULL,
  postcode VARCHAR(10) DEFAULT NULL,
  state VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE customer (
  customerID INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) DEFAULT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  email VARCHAR(100) DEFAULT NULL,
  addressID INT(11) DEFAULT NULL,
  PRIMARY KEY (customerID),
  KEY addressID (addressID),
  CONSTRAINT customer_ibfk_1
    FOREIGN KEY (addressID) REFERENCES address (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE customerorder (
  orderID INT(11) NOT NULL AUTO_INCREMENT,
  customerID INT(11) DEFAULT NULL,
  date DATE DEFAULT NULL,
  total DECIMAL(10,2) DEFAULT NULL,
  paymentMethod VARCHAR(50) DEFAULT NULL,
  status VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (orderID),
  KEY customerID (customerID),
  CONSTRAINT customerorder_ibfk_1
    FOREIGN KEY (customerID) REFERENCES customer (customerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ── Copiar datos filtrados ──

INSERT INTO zona1DB.address
SELECT * FROM salesdb.address
 WHERE state IN ('CDMX', 'Hidalgo');

INSERT INTO zona1DB.customer
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('CDMX', 'Hidalgo');

INSERT INTO zona1DB.customerorder
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address  a ON c.addressID   = a.addressID
 WHERE a.state IN ('CDMX', 'Hidalgo');

-- ── Verificar ──
SELECT 'address'       AS tabla, COUNT(*) AS registros FROM zona1DB.address
UNION ALL
SELECT 'customer',       COUNT(*) FROM zona1DB.customer
UNION ALL
SELECT 'customerorder',  COUNT(*) FROM zona1DB.customerorder;

-- Para zona2DB y zona3DB es copiar ese mismo bloque y cambiar:
-- El nombre de la BD (zona2DB / zona3DB)
-- Los estados en el WHERE:
-- zona2: IN ('Queretaro', 'Puebla')
-- zona3: IN ('Veracruz', 'Morelos')
