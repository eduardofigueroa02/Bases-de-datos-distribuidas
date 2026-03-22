# Las 12 Reglas de las Bases de Datos Distribuidas
### C. J. Date (1987)

> **Fuente principal:**  
> Date, C. J. (2001). *An Introduction to Database Systems* (8th ed.). Addison-Wesley.  
> Capítulo 20: *Database Distribution* — pp. 617–650.

---

## Contexto

En 1987, C. J. Date propuso 12 objetivos que todo **Sistema Gestor de Bases de Datos Distribuidas (SGBDD / DDBMS)** debería cumplir. Son el equivalente distribuido de las *Reglas de Codd* para bases de datos relacionales. Aunque ningún DDBMS actual las satisface completamente, constituyen una guía de diseño fundamental.

> *"A distributed database system is one in which the data is stored across multiple sites, each site being controlled by its own DBMS, but cooperating so that a user at any site can access data anywhere in the network as if it were all stored locally."*  
> — Date, C. J. (2001), p. 617

---

## Las 12 Reglas

---

### Regla 1 — Autonomía Local

Cada nodo del sistema distribuido debe ser **autónomo e independiente**. Cada sitio administra su propia seguridad, bloqueo, integridad y recuperación. Las operaciones locales no dependen de otros nodos para funcionar.

**Punto clave:** el sistema no colapsa si un nodo se desconecta del resto.

> *Referencia:* Date (2001), p. 620 — *"Each site should be able to operate as a standalone system."*

---

### Regla 2 — No Dependencia de un Sitio Central

El sistema **no debe depender de un único nodo central**, ya que representaría un punto único de fallo (*Single Point of Failure*, SPOF) y un cuello de botella de rendimiento. Todos los nodos deben tener roles equivalentes.

**Punto clave:** eliminar el SPOF es esencial para alta disponibilidad.

> *Referencia:* Özsu, M. T. & Valduriez, P. (2020). *Principles of Distributed Database Systems* (4th ed.). Springer. Cap. 1, p. 8.

---

### Regla 3 — Operación Continua

El DDBMS debe ofrecer **disponibilidad ininterrumpida**. Las tareas de respaldo, recuperación y mantenimiento deben poder ejecutarse en línea (*online*) sin interrupciones perceptibles ni degradación grave del rendimiento.

**Punto clave:** objetivo de uptime ≥ 99.9 %.

> *Referencia:* Date (2001), p. 621 — operaciones de mantenimiento no deben requerir detener el sistema.

---

### Regla 4 — Independencia de Ubicación *(Transparencia de Localización)*

Los usuarios y las aplicaciones **no deben saber en qué nodo físico** se almacenan los datos. La base de datos debe comportarse como si todos los datos fueran locales, abstrayendo la distribución mediante el diccionario de datos y sinónimos extendidos.

**Punto clave:** el usuario accede a los datos sin conocer su ubicación física.

> *Referencia:* Özsu & Valduriez (2020), Cap. 4 — *"Location transparency means users need not know where data is stored."*

---

### Regla 5 — Independencia de Fragmentación

Las tablas pueden **dividirse en fragmentos** (horizontal o vertical) y distribuirse en distintos nodos de forma transparente. Los usuarios y aplicaciones no deben notar que acceden a partes de una tabla almacenada en múltiples sitios.

**Punto clave:**  
- *Fragmentación horizontal* → división por filas (subconjuntos de registros).  
- *Fragmentación vertical* → división por columnas (subconjuntos de atributos).

> *Referencia:* Date (2001), p. 625; Özsu & Valduriez (2020), Cap. 5 — *Data Fragmentation*.

---

### Regla 6 — Independencia de Replicación

El sistema puede **mantener y sincronizar réplicas** de los datos en varios nodos automáticamente para mejorar disponibilidad y rendimiento. Los usuarios y aplicaciones no deben gestionar estas réplicas manualmente.

**Punto clave:** la replicación mejora tolerancia a fallos y velocidad de lectura.

> *Referencia:* Özsu & Valduriez (2020), Cap. 6 — *Data Replication and Consistency*.

---

### Regla 7 — Procesamiento Distribuido de Consultas

El sistema debe incluir un **optimizador de consultas distribuidas** capaz de seleccionar el mejor plan de ejecución considerando ubicación de datos, carga de CPU por nodo y tráfico de red. Una consulta enviada desde cualquier nodo debe ejecutarse con igual eficiencia.

**Punto clave:** el optimizador minimiza la transferencia de datos entre nodos (*semi-join optimization*).

> *Referencia:* Date (2001), p. 630; Özsu & Valduriez (2020), Cap. 9 — *Distributed Query Processing*.

---

### Regla 8 — Administración Distribuida de Transacciones

Las transacciones pueden **abarcar múltiples nodos** y deben cumplir las propiedades **ACID** de forma global. Requiere protocolos como *Two-Phase Commit* (2PC) para garantizar atomicidad y control de concurrencia distribuido.

**Punto clave:** ACID distribuido: Atomicidad · Consistencia · Aislamiento · Durabilidad.

> *Referencia:* Date (2001), pp. 633–638 — *Distributed Transactions and 2PC Protocol*;  
> Gray, J. & Reuter, A. (1992). *Transaction Processing: Concepts and Techniques*. Morgan Kaufmann. Cap. 12.

---

### Regla 9 — Independencia del Hardware

El sistema debe ejecutarse sobre **diferentes arquitecturas de hardware** (x86, ARM, mainframes, etc.) sin requerir modificaciones. Todos los nodos participan como iguales independientemente de su hardware subyacente.

**Punto clave:** nodos heterogéneos en hardware pueden coexistir en el mismo sistema distribuido.

> *Referencia:* Date (2001), p. 641.

---

### Regla 10 — Independencia del Sistema Operativo

El DDBMS debe funcionar correctamente sobre **distintos sistemas operativos** (Windows, Linux, Unix, macOS, etc.). Un nodo con Linux y otro con Windows deben poder integrarse sin problemas de interoperabilidad.

**Punto clave:** la heterogeneidad de SO no debe ser un obstáculo para la distribución.

> *Referencia:* Özsu & Valduriez (2020), Cap. 2 — *Heterogeneous Distributed Databases*.

---

### Regla 11 — Independencia de la Red

El sistema debe soportar **diferentes protocolos y tecnologías de red** (TCP/IP, Ethernet, WAN, etc.). La infraestructura de comunicación no debe limitar qué nodos pueden participar.

**Punto clave:** la comunicación es transparente independientemente del protocolo de red.

> *Referencia:* Date (2001), p. 642.

---

### Regla 12 — Independencia del DBMS

Los nodos pueden usar **distintos motores de bases de datos** (MySQL, PostgreSQL, Oracle, SQL Server, etc.) y aun así colaborar como parte del mismo sistema distribuido. Esto garantiza interoperabilidad entre sistemas legados y modernos.

**Punto clave:** la heterogeneidad de DBMS permite integración de plataformas diversas.

> *Referencia:* Özsu & Valduriez (2020), Cap. 3 — *Federated Database Systems and DBMS Independence*.

---

## Tabla Resumen

| # | Regla | Concepto Clave |
|:---:|---|---|
| 1 | Autonomía Local | Cada nodo es independiente |
| 2 | Sin Sitio Central | Elimina SPOF y cuellos de botella |
| 3 | Operación Continua | Sin tiempos de inactividad |
| 4 | Independencia de Ubicación | El usuario ignora dónde están los datos |
| 5 | Independencia de Fragmentación | Fragmentos transparentes (horizontal/vertical) |
| 6 | Independencia de Replicación | Réplicas gestionadas automáticamente |
| 7 | Proc. Distribuido de Consultas | Optimización automática entre nodos |
| 8 | Gestión Distribuida de Transacciones | ACID en múltiples nodos (2PC) |
| 9 | Independencia de Hardware | Multiplataforma física |
| 10 | Independencia del S.O. | Multiplataforma de software |
| 11 | Independencia de Red | Multiprotocolo |
| 12 | Independencia del DBMS | Interoperabilidad entre motores |

---
