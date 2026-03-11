-- ============================================================
--  FRAGMENTACIÓN VERTICAL — salesDB
--  MySQL 8.0 + Windows  (secure_file_priv activo)
-- ============================================================
--
--  ANTES DE CORRER ESTE SCRIPT:
--  1. Restaurar backup:
--       mysql> CREATE DATABASE salesDB;
--       $ mysql -u root -p salesDB < salesBD_bk.sql
--  2. Abrir MySQL Workbench como Administrador
--  3. Ejecutar cada sección en orden
-- ============================================================

-- ── Configuración global MySQL 8 ─────────────────────────────
SET NAMES utf8mb4;
SET GLOBAL local_infile = 1;
SET FOREIGN_KEY_CHECKS = 0;


-- ============================================================
--  PASO 0: Corregir error de diseño en customer (salesDB)
-- ============================================================
USE salesDB;

ALTER TABLE customer DROP CONSTRAINT customer_ibfk_1;
-- Nota: el .md tiene typo "adressID" — el nombre correcto en el backup es addressID
ALTER TABLE customer DROP COLUMN addressID;

-- Verificar resultado: debe quedar customerID | name | phone | email
DESC customer;

-- Estadísticas salesDB:
SELECT   t.TABLE_NAME                                             AS `Tabla`,
         t.TABLE_ROWS                                             AS `Registros`,
         t.AVG_ROW_LENGTH                                         AS `Tamaño fila (bytes)`,
         ROUND(t.DATA_LENGTH / 1024 / 1024, 2)                    AS `Datos (MB)`,
         ROUND(t.INDEX_LENGTH / 1024 / 1024, 2)                   AS `Índices (MB)`,
         ROUND((t.DATA_LENGTH + t.INDEX_LENGTH) / 1024 / 1024, 2) AS `Total (MB)`
FROM     information_schema.TABLES t
WHERE    t.TABLE_SCHEMA = 'salesDB'
  AND    t.TABLE_TYPE   = 'BASE TABLE'
ORDER BY t.TABLE_ROWS DESC;


-- ============================================================
--  PASO 1: Exportar CSV desde salesDB
--  Destino: C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
--  Nota: si un archivo ya existe, MySQL falla — borrar manualmente
--        antes de volver a exportar
-- ============================================================
USE salesDB;

SELECT addressID, street, city, postcode, state
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/address.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM address;

SELECT customerID, name, email, phone
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM customer;

SELECT customerAddressID, customerID, addressID, type
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customeraddress.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM customeraddress;

-- product: mapeamos detail→description, amount→stock
SELECT productID, supplierID, name, detail, price, amount
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM product;

-- customerorder: mapeamos date→orderDate, total→totalAmount
SELECT orderID, customerID, `date`, status, total
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customerorder.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM customerorder;

SELECT orderProductID, orderID, productID, quantity, price
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orderproduct.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM orderproduct;

-- supplier: backup no tiene contactName → se llenará NULL en carga
SELECT supplierID, name, email, phone, addressID
  INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/supplier.csv'
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  FROM supplier;


-- ============================================================
--  FRAGMENTO 1: customerDB
-- ============================================================
DROP DATABASE IF EXISTS customerDB;
CREATE DATABASE customerDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE customerDB;

CREATE TABLE address (
    addressId   INT          NOT NULL AUTO_INCREMENT,
    street      VARCHAR(255) NOT NULL,
    city        VARCHAR(100) NOT NULL,
    state       VARCHAR(100) NOT NULL,
    zipCode     VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_address PRIMARY KEY (addressId)
);

CREATE TABLE customer (
    customerId  INT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    phone       VARCHAR(20),
    CONSTRAINT pk_customer       PRIMARY KEY (customerId),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

CREATE TABLE customerAddress (
    customerAddressId INT         NOT NULL AUTO_INCREMENT,
    customerId        INT         NOT NULL,
    addressId         INT         NOT NULL,
    addressType       VARCHAR(50) NOT NULL,
    CONSTRAINT pk_customerAddress PRIMARY KEY (customerAddressId),
    CONSTRAINT fk_ca_customer     FOREIGN KEY (customerId)
        REFERENCES customer (customerId),
    CONSTRAINT fk_ca_address      FOREIGN KEY (addressId)
        REFERENCES address (addressId)
);

-- product sin FK a supplier (supplier no existe en customerDB)
CREATE TABLE product (
    productId   INT            NOT NULL AUTO_INCREMENT,
    supplierId  INT,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    price       DECIMAL(10,2)  NOT NULL,
    stock       INT            NOT NULL DEFAULT 0,
    CONSTRAINT pk_product PRIMARY KEY (productId)
);

CREATE TABLE customerOrder (
    orderId     INT            NOT NULL AUTO_INCREMENT,
    customerId  INT            NOT NULL,
    orderDate   DATE           NOT NULL,
    status      VARCHAR(50)    NOT NULL DEFAULT 'pending',
    totalAmount DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_customerOrder PRIMARY KEY (orderId),
    CONSTRAINT fk_co_customer   FOREIGN KEY (customerId)
        REFERENCES customer (customerId)
);

CREATE TABLE orderProduct (
    orderProductId INT            NOT NULL AUTO_INCREMENT,
    orderId        INT            NOT NULL,
    productId      INT            NOT NULL,
    quantity       INT            NOT NULL,
    unitPrice      DECIMAL(10,2)  NOT NULL,
    CONSTRAINT pk_orderProduct PRIMARY KEY (orderProductId),
    CONSTRAINT fk_op_order     FOREIGN KEY (orderId)
        REFERENCES customerOrder (orderId),
    CONSTRAINT fk_op_product   FOREIGN KEY (productId)
        REFERENCES product (productId)
);

-- ── Carga de datos customerDB (orden FK obligatorio) ─────────

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/address.csv'
  INTO TABLE address
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (addressId, street, city, zipCode, state);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv'
  INTO TABLE customer
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (customerId, name, email, phone);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customeraddress.csv'
  INTO TABLE customerAddress
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (customerAddressId, customerId, addressId, addressType);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product.csv'
  INTO TABLE product
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (productId, supplierId, name, description, price, stock);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customerorder.csv'
  INTO TABLE customerOrder
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (orderId, customerId, orderDate, status, totalAmount);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orderproduct.csv'
  INTO TABLE orderProduct
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (orderProductId, orderId, productId, quantity, unitPrice);

-- ── Estadísticas customerDB ───────────────────────────────────
SELECT   t.TABLE_NAME                                             AS `Tabla`,
         t.TABLE_ROWS                                             AS `Registros`,
         t.AVG_ROW_LENGTH                                         AS `Tamaño fila (bytes)`,
         ROUND(t.DATA_LENGTH / 1024 / 1024, 2)                    AS `Datos (MB)`,
         ROUND(t.INDEX_LENGTH / 1024 / 1024, 2)                   AS `Índices (MB)`,
         ROUND((t.DATA_LENGTH + t.INDEX_LENGTH) / 1024 / 1024, 2) AS `Total (MB)`
FROM     information_schema.TABLES t
WHERE    t.TABLE_SCHEMA = 'customerDB'
  AND    t.TABLE_TYPE   = 'BASE TABLE'
ORDER BY t.TABLE_ROWS DESC;


-- ============================================================
--  FRAGMENTO 2: supplierDB
-- ============================================================
DROP DATABASE IF EXISTS supplierDB;
CREATE DATABASE supplierDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE supplierDB;

CREATE TABLE address (
    addressId   INT          NOT NULL AUTO_INCREMENT,
    street      VARCHAR(255) NOT NULL,
    city        VARCHAR(100) NOT NULL,
    state       VARCHAR(100) NOT NULL,
    zipCode     VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_address PRIMARY KEY (addressId)
);

CREATE TABLE supplier (
    supplierId  INT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    contactName VARCHAR(100),
    email       VARCHAR(255),
    phone       VARCHAR(20),
    addressId   INT,
    CONSTRAINT pk_supplier    PRIMARY KEY (supplierId),
    CONSTRAINT fk_sup_address FOREIGN KEY (addressId)
        REFERENCES address (addressId)
);

CREATE TABLE product (
    productId   INT            NOT NULL AUTO_INCREMENT,
    supplierId  INT,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    price       DECIMAL(10,2)  NOT NULL,
    stock       INT            NOT NULL DEFAULT 0,
    CONSTRAINT pk_product       PRIMARY KEY (productId),
    CONSTRAINT fk_prod_supplier FOREIGN KEY (supplierId)
        REFERENCES supplier (supplierId)
);

-- ── Carga de datos supplierDB (address primero por FK) ────────

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/address.csv'
  INTO TABLE address
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (addressId, street, city, zipCode, state);

-- El CSV de supplier tiene 4 columnas (sin contactName)
-- Se asigna NULL a contactName con variable ficticia
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/supplier.csv'
  INTO TABLE supplier
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (supplierId, name, email, phone, addressId)
  SET contactName = NULL;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product.csv'
  INTO TABLE product
  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
  (productId, supplierId, name, description, price, stock);

-- ── Estadísticas supplierDB ───────────────────────────────────
SELECT   t.TABLE_NAME                                             AS `Tabla`,
         t.TABLE_ROWS                                             AS `Registros`,
         t.AVG_ROW_LENGTH                                         AS `Tamaño fila (bytes)`,
         ROUND(t.DATA_LENGTH / 1024 / 1024, 2)                    AS `Datos (MB)`,
         ROUND(t.INDEX_LENGTH / 1024 / 1024, 2)                   AS `Índices (MB)`,
         ROUND((t.DATA_LENGTH + t.INDEX_LENGTH) / 1024 / 1024, 2) AS `Total (MB)`
FROM     information_schema.TABLES t
WHERE    t.TABLE_SCHEMA = 'supplierDB'
  AND    t.TABLE_TYPE   = 'BASE TABLE'
ORDER BY t.TABLE_ROWS DESC;

-- ── Restaurar configuración ───────────────────────────────────
SET FOREIGN_KEY_CHECKS = 1;
