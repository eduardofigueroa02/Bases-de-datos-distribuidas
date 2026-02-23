
## 0. Proceso para construir el fragmento 1 de la base de datos salesbd.
   
**Esquema del fragmento** ✅

![Modelo relacional salesdb](salesdb.png)

**Script para crear fragmento** ✅

```sql
   SELECT *
     FROM mi_tablas
    WHERE condicion_1
```

**Scripts para descargar los datos de la base de datos salesbd.** 📌

```sql
   SELECT *
     FROM mi_tablas
    WHERE condicion_1
```

**Scripts para cargar los datos al fragmento 1.** 📌

```sql
   INSERT INTO mi_tablas
    FROM origen_1
```


Fragmentos verticales
------------------------

1. 🧠 *Fragmento customerDB*. Construye un fragmento vertical que contenga todos los datos de customer, pero sólo los de customer.
   
**Esquema del fragmento** ✅

```
customerDB
┌─────────────────────────────────────────┐
│ customer                                │
├──────────────┬──────────────────────────┤
│ customerID   │ INT (PK, AUTO_INCREMENT) │
│ name         │ VARCHAR(100)             │
│ phone        │ VARCHAR(20)              │
│ email        │ VARCHAR(100)             │
│ addressID    │ INT (FK → address)       │
└──────────────┴──────────────────────────┘
```

**Script para crear fragmento** ✅

```sql
-- Crear base de datos del fragmento
CREATE DATABASE customerDB;
USE customerDB;

-- Crear tabla address (requerida por FK)
CREATE TABLE address (
  addressID INT(11) NOT NULL AUTO_INCREMENT,
  street    VARCHAR(100) DEFAULT NULL,
  localy    VARCHAR(50)  DEFAULT NULL,
  city      VARCHAR(50)  DEFAULT NULL,
  postcode  VARCHAR(10)  DEFAULT NULL,
  state     VARCHAR(50)  DEFAULT NULL,
  PRIMARY KEY (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Crear tabla customer
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
```

**Scripts para descargar los datos de la base de datos salesbd.** 📌

```sql
-- Descargar direcciones referenciadas por clientes
SELECT a.*
  FROM salesdb.address a
 INNER JOIN salesdb.customer c ON c.addressID = a.addressID;

-- Descargar todos los clientes
SELECT *
  FROM salesdb.customer;
```

**Scripts para cargar los datos al fragmento customerDB.** 📌

```sql
-- Cargar primero las direcciones (por integridad referencial)
USE customerDB;

INSERT INTO address
SELECT a.*
  FROM salesdb.address a
 INNER JOIN salesdb.customer c ON c.addressID = a.addressID;

-- Cargar clientes
INSERT INTO customer
SELECT *
  FROM salesdb.customer;
```

---

2. 🧠 *Fragmento supplierDB*. Construye un fragmento vertical que contenga todos los datos de supplier, pero sólo los de supplier.
   
**Esquema del fragmento** ✅

```
supplierDB
┌─────────────────────────────────────────┐
│ supplier                                │
├──────────────┬──────────────────────────┤
│ supplierID   │ INT (PK, AUTO_INCREMENT) │
│ name         │ VARCHAR(100)             │
│ phone        │ VARCHAR(20)              │
│ email        │ VARCHAR(100)             │
│ addressID    │ INT (FK → address)       │
└──────────────┴──────────────────────────┘
```

**Script para crear fragmento** ✅

```sql
-- Crear base de datos del fragmento
CREATE DATABASE supplierDB;
USE supplierDB;

-- Crear tabla address (requerida por FK)
CREATE TABLE address (
  addressID INT(11) NOT NULL AUTO_INCREMENT,
  street    VARCHAR(100) DEFAULT NULL,
  localy    VARCHAR(50)  DEFAULT NULL,
  city      VARCHAR(50)  DEFAULT NULL,
  postcode  VARCHAR(10)  DEFAULT NULL,
  state     VARCHAR(50)  DEFAULT NULL,
  PRIMARY KEY (addressID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Crear tabla supplier
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
```

**Scripts para descargar los datos de la base de datos salesbd.** 📌

```sql
-- Descargar direcciones referenciadas por proveedores
SELECT a.*
  FROM salesdb.address a
 INNER JOIN salesdb.supplier s ON s.addressID = a.addressID;

-- Descargar todos los proveedores
SELECT *
  FROM salesdb.supplier;
```

**Scripts para cargar los datos al fragmento supplierDB.** 📌

```sql
-- Cargar primero las direcciones
USE supplierDB;

INSERT INTO address
SELECT a.*
  FROM salesdb.address a
 INNER JOIN salesdb.supplier s ON s.addressID = a.addressID;

-- Cargar proveedores
INSERT INTO supplier
SELECT *
  FROM salesdb.supplier;
```

---

Fragmentos horizontales
------------------------

3. 🧠 *Fragmento zona1DB*. Construye un fragmento horizontal que contenga todos los clientes con dirección en los estados **CDMX e Hidalgo**. Incluye toda la información de los clientes y sus órdenes de compra.
   
**Esquema del fragmento** ✅

```
zona1DB  (estados: CDMX, Hidalgo)
┌──────────────────────────────────────────┐
│ address         (solo CDMX e Hidalgo)    │
├──────────────┬───────────────────────────┤
│ addressID    │ INT (PK)                  │
│ street       │ VARCHAR(100)              │
│ localy       │ VARCHAR(50)               │
│ city         │ VARCHAR(50)               │
│ postcode     │ VARCHAR(10)               │
│ state        │ VARCHAR(50)               │
└──────────────┴───────────────────────────┘
        ▲
        │ FK
┌──────────────────────────────────────────┐
│ customer        (clientes zona 1)        │
├──────────────┬───────────────────────────┤
│ customerID   │ INT (PK)                  │
│ name         │ VARCHAR(100)              │
│ phone        │ VARCHAR(20)               │
│ email        │ VARCHAR(100)              │
│ addressID    │ INT (FK → address)        │
└──────────────┴───────────────────────────┘
        ▲
        │ FK
┌──────────────────────────────────────────┐
│ customerorder   (órdenes zona 1)         │
├──────────────┬───────────────────────────┤
│ orderID      │ INT (PK)                  │
│ customerID   │ INT (FK → customer)       │
│ date         │ DATE                      │
│ total        │ DECIMAL(10,2)             │
│ paymentMethod│ VARCHAR(50)               │
│ status       │ VARCHAR(50)               │
└──────────────┴───────────────────────────┘
```

**Script para crear fragmento** ✅

```sql
CREATE DATABASE zona1DB;
USE zona1DB;

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

CREATE TABLE customerorder (
  orderID       INT(11)     NOT NULL AUTO_INCREMENT,
  customerID    INT(11)     DEFAULT NULL,
  date          DATE        DEFAULT NULL,
  total         DECIMAL(10,2) DEFAULT NULL,
  paymentMethod VARCHAR(50) DEFAULT NULL,
  status        VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (orderID),
  KEY customerID (customerID),
  CONSTRAINT customerorder_ibfk_1
    FOREIGN KEY (customerID) REFERENCES customer (customerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**Scripts para descargar los datos de la base de datos salesbd.** 📌

```sql
-- Descargar direcciones de CDMX e Hidalgo
SELECT *
  FROM salesdb.address
 WHERE state IN ('CDMX', 'Hidalgo');

-- Descargar clientes con dirección en CDMX e Hidalgo
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('CDMX', 'Hidalgo');

-- Descargar órdenes de los clientes de zona 1
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address a  ON c.addressID  = a.addressID
 WHERE a.state IN ('CDMX', 'Hidalgo');
```

**Scripts para cargar los datos al fragmento zona1DB.** 📌

```sql
USE zona1DB;

-- 1. Cargar direcciones
INSERT INTO address
SELECT *
  FROM salesdb.address
 WHERE state IN ('CDMX', 'Hidalgo');

-- 2. Cargar clientes
INSERT INTO customer
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('CDMX', 'Hidalgo');

-- 3. Cargar órdenes
INSERT INTO customerorder
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address a  ON c.addressID  = a.addressID
 WHERE a.state IN ('CDMX', 'Hidalgo');
```

---

4. 🧠 *Fragmento zona2DB*. Construye un fragmento horizontal que contenga todos los clientes con dirección en los estados **Queretaro y Puebla**. Incluye toda la información de los clientes y sus órdenes de compra.
   
**Esquema del fragmento** ✅

```
zona2DB  (estados: Queretaro, Puebla)
┌──────────────────────────────────────────┐
│ address    (solo Queretaro y Puebla)     │
├──────────────┬───────────────────────────┤
│ addressID    │ INT (PK)                  │
│ street       │ VARCHAR(100)              │
│ localy       │ VARCHAR(50)               │
│ city         │ VARCHAR(50)               │
│ postcode     │ VARCHAR(10)               │
│ state        │ VARCHAR(50)               │
└──────────────┴───────────────────────────┘
        ▲ FK
┌──────────────────────────────────────────┐
│ customer        (clientes zona 2)        │
├──────────────┬───────────────────────────┤
│ customerID   │ INT (PK)                  │
│ name         │ VARCHAR(100)              │
│ phone        │ VARCHAR(20)               │
│ email        │ VARCHAR(100)              │
│ addressID    │ INT (FK → address)        │
└──────────────┴───────────────────────────┘
        ▲ FK
┌──────────────────────────────────────────┐
│ customerorder   (órdenes zona 2)         │
├──────────────┬───────────────────────────┤
│ orderID      │ INT (PK)                  │
│ customerID   │ INT (FK → customer)       │
│ date         │ DATE                      │
│ total        │ DECIMAL(10,2)             │
│ paymentMethod│ VARCHAR(50)               │
│ status       │ VARCHAR(50)               │
└──────────────┴───────────────────────────┘
```

**Script para crear fragmento** ✅

```sql
CREATE DATABASE zona2DB;
USE zona2DB;

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

CREATE TABLE customerorder (
  orderID       INT(11)     NOT NULL AUTO_INCREMENT,
  customerID    INT(11)     DEFAULT NULL,
  date          DATE        DEFAULT NULL,
  total         DECIMAL(10,2) DEFAULT NULL,
  paymentMethod VARCHAR(50) DEFAULT NULL,
  status        VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (orderID),
  KEY customerID (customerID),
  CONSTRAINT customerorder_ibfk_1
    FOREIGN KEY (customerID) REFERENCES customer (customerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**Scripts para descargar los datos de la base de datos salesbd.** 📌

```sql
-- Descargar direcciones de Queretaro y Puebla
SELECT *
  FROM salesdb.address
 WHERE state IN ('Queretaro', 'Puebla');

-- Descargar clientes con dirección en Queretaro y Puebla
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('Queretaro', 'Puebla');

-- Descargar órdenes de los clientes de zona 2
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address a  ON c.addressID  = a.addressID
 WHERE a.state IN ('Queretaro', 'Puebla');
```

**Scripts para cargar los datos al fragmento zona2DB.** 📌

```sql
USE zona2DB;

-- 1. Cargar direcciones
INSERT INTO address
SELECT *
  FROM salesdb.address
 WHERE state IN ('Queretaro', 'Puebla');

-- 2. Cargar clientes
INSERT INTO customer
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('Queretaro', 'Puebla');

-- 3. Cargar órdenes
INSERT INTO customerorder
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address a  ON c.addressID  = a.addressID
 WHERE a.state IN ('Queretaro', 'Puebla');
```

---

5. 🧠 *Fragmento zona3DB*. Construye un fragmento horizontal que contenga todos los clientes con dirección en los estados **Veracruz y Morelos**. Incluye toda la información de los clientes y sus órdenes de compra.
   
**Esquema del fragmento** ✅

```
zona3DB  (estados: Veracruz, Morelos)
┌──────────────────────────────────────────┐
│ address    (solo Veracruz y Morelos)     │
├──────────────┬───────────────────────────┤
│ addressID    │ INT (PK)                  │
│ street       │ VARCHAR(100)              │
│ localy       │ VARCHAR(50)               │
│ city         │ VARCHAR(50)               │
│ postcode     │ VARCHAR(10)               │
│ state        │ VARCHAR(50)               │
└──────────────┴───────────────────────────┘
        ▲ FK
┌──────────────────────────────────────────┐
│ customer        (clientes zona 3)        │
├──────────────┬───────────────────────────┤
│ customerID   │ INT (PK)                  │
│ name         │ VARCHAR(100)              │
│ phone        │ VARCHAR(20)               │
│ email        │ VARCHAR(100)              │
│ addressID    │ INT (FK → address)        │
└──────────────┴───────────────────────────┘
        ▲ FK
┌──────────────────────────────────────────┐
│ customerorder   (órdenes zona 3)         │
├──────────────┬───────────────────────────┤
│ orderID      │ INT (PK)                  │
│ customerID   │ INT (FK → customer)       │
│ date         │ DATE                      │
│ total        │ DECIMAL(10,2)             │
│ paymentMethod│ VARCHAR(50)               │
│ status       │ VARCHAR(50)               │
└──────────────┴───────────────────────────┘
```

**Script para crear fragmento** ✅

```sql
CREATE DATABASE zona3DB;
USE zona3DB;

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

CREATE TABLE customerorder (
  orderID       INT(11)     NOT NULL AUTO_INCREMENT,
  customerID    INT(11)     DEFAULT NULL,
  date          DATE        DEFAULT NULL,
  total         DECIMAL(10,2) DEFAULT NULL,
  paymentMethod VARCHAR(50) DEFAULT NULL,
  status        VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (orderID),
  KEY customerID (customerID),
  CONSTRAINT customerorder_ibfk_1
    FOREIGN KEY (customerID) REFERENCES customer (customerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**Scripts para descargar los datos de la base de datos salesbd.** 📌

```sql
-- Descargar direcciones de Veracruz y Morelos
SELECT *
  FROM salesdb.address
 WHERE state IN ('Veracruz', 'Morelos');

-- Descargar clientes con dirección en Veracruz y Morelos
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('Veracruz', 'Morelos');

-- Descargar órdenes de los clientes de zona 3
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address a  ON c.addressID  = a.addressID
 WHERE a.state IN ('Veracruz', 'Morelos');
```

**Scripts para cargar los datos al fragmento zona3DB.** 📌

```sql
USE zona3DB;

-- 1. Cargar direcciones
INSERT INTO address
SELECT *
  FROM salesdb.address
 WHERE state IN ('Veracruz', 'Morelos');

-- 2. Cargar clientes
INSERT INTO customer
SELECT c.*
  FROM salesdb.customer c
 INNER JOIN salesdb.address a ON c.addressID = a.addressID
 WHERE a.state IN ('Veracruz', 'Morelos');

-- 3. Cargar órdenes
INSERT INTO customerorder
SELECT co.*
  FROM salesdb.customerorder co
 INNER JOIN salesdb.customer c ON co.customerID = c.customerID
 INNER JOIN salesdb.address a  ON c.addressID  = a.addressID
 WHERE a.state IN ('Veracruz', 'Morelos');
```