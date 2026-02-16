# Bloque 4. *Consultas SQL - Nivel examen*
_______________________________

📌 Nivel: Intermedio

---

## 1. 🧠 Cliente con mayor gasto total

```sql
USE tiendachida;

SELECT customer.name AS nombre_cliente, 
       SUM(customerOrder.total) AS total_gastado
  FROM customer
 INNER JOIN customerOrder ON customer.customerID = customerOrder.customerID
 GROUP BY customer.customerID, customer.name
 ORDER BY total_gastado DESC
 LIMIT 1;
```

**Resultado:**

| nombre_cliente | total_gastado |
| -------------- | ------------- |
| Juan Pérez     | 15250.00      |

---

## 2. 🧠 Producto más vendido (en unidades)

```sql
USE tiendachida;

SELECT product.name AS nombre_producto,
       SUM(orderProduct.quantity) AS unidades_vendidas
  FROM product
 INNER JOIN orderProduct ON product.productID = orderProduct.productID
 GROUP BY product.productID, product.name
 ORDER BY unidades_vendidas DESC
 LIMIT 1;
```

**Resultado:**

| nombre_producto | unidades_vendidas |
| --------------- | ----------------- |
| Laptop          | 1                 |

---

## 3. 🧠 Total de ventas por ciudad

```sql
USE tiendachida;

SELECT address.city AS ciudad,
       SUM(customerOrder.total) AS total_ventas
  FROM customer
 INNER JOIN customerOrder ON customer.customerID = customerOrder.customerID
 INNER JOIN address ON customer.addressID = address.addressID
 GROUP BY address.city
 ORDER BY total_ventas DESC;
```

**Resultado:**

| ciudad      | total_ventas |
| ----------- | ------------ |
| Monterrey   | 15250.00     |
| Mérida      | 3500.00      |
| Pachuca     | 4200.00      |
| Querétaro   | 450.00       |

---

## 4. 🧠 Clientes con más de una dirección

```sql
USE tiendachida;

SELECT customer.name AS nombre_cliente,
       COUNT(customerAddress.addressID) AS cantidad_direcciones
  FROM customer
 INNER JOIN customerAddress ON customer.customerID = customerAddress.customerID
 GROUP BY customer.customerID, customer.name
HAVING COUNT(customerAddress.addressID) > 1;
```

**Resultado:**

| nombre_cliente | cantidad_direcciones |
| -------------- | -------------------- |
| (Sin resultados) | |

---

## 5. 🧠 Pedidos con total superior al promedio

```sql
USE tiendachida;

SELECT orderID,
       customerID,
       date AS fecha,
       total,
       paymentMethod AS metodo_pago,
       status AS estado
  FROM customerOrder
 WHERE total > (SELECT AVG(total) FROM customerOrder);
```

**Resultado:**

| orderID | customerID | fecha               | total     | metodo_pago   | estado   |
| ------- | ---------- | ------------------- | --------- | ------------- | -------- |
| 1       | 1          | 2025-01-10 10:30:00 | 15250.00  | Tarjeta       | Pagado   |
| 4       | 4          | 2025-01-13 09:20:00 | 3500.00   | Tarjeta       | Pagado   |
| 5       | 5          | 2025-01-14 18:10:00 | 4200.00   | Efectivo      | Cancelado|

---

## 6. 🧠 Proveedor con más productos vendidos

```sql
USE tiendachida;

SELECT supplier.name AS nombre_proveedor,
       SUM(orderProduct.quantity) AS unidades_vendidas
  FROM supplier
 INNER JOIN product ON supplier.supplierID = product.supplierID
 INNER JOIN orderProduct ON product.productID = orderProduct.productID
 GROUP BY supplier.supplierID, supplier.name
 ORDER BY unidades_vendidas DESC
 LIMIT 1;
```

**Resultado:**

| nombre_proveedor | unidades_vendidas |
| ---------------- | ----------------- |
| Proveedor A      | 1                 |

---

## 7. 🧠 Clientes que nunca cancelaron pedidos

```sql
USE tiendachida;

SELECT DISTINCT customer.customerID,
                customer.name AS nombre_cliente,
                customer.email
  FROM customer
 INNER JOIN customerOrder ON customer.customerID = customerOrder.customerID
 WHERE customer.customerID NOT IN (
       SELECT customerID 
         FROM customerOrder 
        WHERE status = 'Cancelado'
 );
```

**Resultado:**

| customerID | nombre_cliente | email           |
| ---------- | -------------- | --------------- |
| 1          | Juan Pérez     | juan@gmail.com  |
| 2          | María López    | maria@gmail.com |
| 3          | Susana Ruiz    | susana@gmail.com|
| 4          | Ana Torres     | ana@gmail.com   |

---

## 8. 🧠 Ingreso total por método de pago

```sql
USE tiendachida;

SELECT paymentMethod AS metodo_pago,
       SUM(total) AS ingreso_total,
       COUNT(*) AS cantidad_pedidos
  FROM customerOrder
 WHERE status != 'Cancelado'
 GROUP BY paymentMethod
 ORDER BY ingreso_total DESC;
```

**Resultado:**

| metodo_pago    | ingreso_total | cantidad_pedidos |
| -------------- | ------------- | ---------------- |
| Tarjeta        | 18750.00      | 2                |
| Transferencia  | 450.00        | 1                |

---

## 9. 🧠 Pedidos con más de un producto distinto

```sql
USE tiendachida;

SELECT customerOrder.orderID,
       customerOrder.date AS fecha,
       COUNT(DISTINCT orderProduct.productID) AS productos_distintos,
       SUM(orderProduct.quantity) AS total_unidades
  FROM customerOrder
 INNER JOIN orderProduct ON customerOrder.orderID = orderProduct.orderID
 GROUP BY customerOrder.orderID, customerOrder.date
HAVING COUNT(DISTINCT orderProduct.productID) > 1;
```

**Resultado:**

| orderID | fecha               | productos_distintos | total_unidades |
| ------- | ------------------- | ------------------- | -------------- |
| 1       | 2025-01-10 10:30:00 | 2                   | 2              |

---

## 10. 🧠 Clientes con pedidos en más de una ciudad

```sql
USE tiendachida;

SELECT customer.customerID,
       customer.name AS nombre_cliente,
       COUNT(DISTINCT address.city) AS ciudades_diferentes
  FROM customer
 INNER JOIN customerOrder ON customer.customerID = customerOrder.customerID
 INNER JOIN address ON customer.addressID = address.addressID
 GROUP BY customer.customerID, customer.name
HAVING COUNT(DISTINCT address.city) > 1;
```

**Resultado:**

| customerID | nombre_cliente | ciudades_diferentes |
| ---------- | -------------- | ------------------- |
| (Sin resultados) | | |

---

### Consulta alternativa (usando customerAddress):

```sql
USE tiendachida;

SELECT customer.customerID,
       customer.name AS nombre_cliente,
       COUNT(DISTINCT address.city) AS ciudades_diferentes,
       GROUP_CONCAT(DISTINCT address.city) AS ciudades
  FROM customer
 INNER JOIN customerAddress ON customer.customerID = customerAddress.customerID
 INNER JOIN address ON customerAddress.addressID = address.addressID
 GROUP BY customer.customerID, customer.name
HAVING COUNT(DISTINCT address.city) > 1;
```

**Resultado:**

| customerID | nombre_cliente | ciudades_diferentes | ciudades |
| ---------- | -------------- | ------------------- | -------- |
| (Sin resultados) | | | |

---

## 📊 Resumen de Técnicas Utilizadas

✔ **INNER JOIN** - Unión de múltiples tablas  
✔ **GROUP BY** - Agrupación de datos  
✔ **HAVING** - Filtrado de grupos  
✔ **SUM(), COUNT(), AVG()** - Funciones de agregación  
✔ **COUNT(DISTINCT)** - Conteo de valores únicos  
✔ **Subconsultas** - Consultas anidadas  
✔ **ORDER BY + LIMIT** - Ordenamiento y limitación  
✔ **NOT IN** - Exclusión de valores  
✔ **GROUP_CONCAT** - Concatenación de resultados  

---
