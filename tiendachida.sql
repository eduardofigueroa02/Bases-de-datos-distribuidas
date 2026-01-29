CREATE TABLE address (
    addressID INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    localy VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postcode VARCHAR(20) NOT NULL,
    state VARCHAR(100) NOT NULL
);

CREATE TABLE customer (
    customerID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    addressID INT NOT NULL,
    FOREIGN KEY (addressID) REFERENCES address(addressID)
);

CREATE TABLE supplier (
    supplierID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    addressID INT NOT NULL,
    FOREIGN KEY (addressID) REFERENCES address(addressID)
);

CREATE TABLE customerAddress (
    customerAdressID INT AUTO_INCREMENT PRIMARY KEY,
    customerID INT NOT NULL,
    addressID INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    FOREIGN KEY (customerID) REFERENCES customer(customerID),
    FOREIGN KEY (addressID) REFERENCES address(addressID)
);

CREATE TABLE product (
    productID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    amount INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    detail TEXT NOT NULL,
    supplierID INT NOT NULL,
    FOREIGN KEY (supplierID) REFERENCES supplier(supplierID)
);

CREATE TABLE customerOrder (
    orderID INT AUTO_INCREMENT PRIMARY KEY,
    customerID INT NOT NULL,
    date DATETIME NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    paymentMethod VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customerID) REFERENCES customer(customerID)
);

CREATE TABLE orderProduct (
    orderProductID INT AUTO_INCREMENT PRIMARY KEY,
    orderID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (orderID) REFERENCES customerOrder(orderID),
    FOREIGN KEY (productID) REFERENCES product(productID)
);

INSERT INTO address (street, localy, city, postcode, state) VALUES
('Calle 1', 'Centro', 'Monterrey', '64000', 'Nuevo León'),
('Calle 2', 'Norte', 'Guadalajara', '44100', 'Jalisco'),
('Calle 3', 'Sur', 'Querétaro', '76000', 'Querétaro'),
('Calle 4', 'Este', 'Mérida', '97000', 'Yucatán'),
('Calle 5', 'Oeste', 'Pachuca', '42000', 'Hidalgo');

INSERT INTO customer (name, phone, email, addressID) VALUES
('Juan Pérez', '8112345678', 'juan@gmail.com', 1),
('María López', '3312345678', 'maria@gmail.com', 2),
('Susana Ruiz', '4421234567', 'susana@gmail.com', 3),
('Ana Torres', '9991234567', 'ana@gmail.com', 4),
('Carlos Gómez', '7711234567', 'carlos@gmail.com', 5);

INSERT INTO supplier (name, phone, email, addressID) VALUES
('Proveedor A', '8111111111', 'provA@gmail.com', 1),
('Proveedor B', '3322222222', 'provB@gmail.com', 2),
('Proveedor C', '4433333333', 'provC@gmail.com', 3),
('Proveedor D', '9944444444', 'provD@gmail.com', 4),
('Proveedor E', '7755555555', 'provE@gmail.com', 5);

INSERT INTO customerAddress (customerID, addressID, type, position) VALUES
(1, 1, 'Casa', 'Principal'),
(2, 2, 'Casa', 'Principal'),
(3, 3, 'Oficina', 'Secundaria'),
(4, 4, 'Casa', 'Principal'),
(5, 5, 'Oficina', 'Principal');

INSERT INTO product (name, type, amount, price, detail, supplierID) VALUES
('Laptop', 'Electrónica', 10, 15000.00, 'Laptop 16GB RAM', 1),
('Mouse', 'Accesorio', 50, 250.00, 'Mouse inalámbrico', 2),
('Teclado', 'Accesorio', 40, 450.00, 'Teclado mecánico', 3),
('Monitor', 'Electrónica', 20, 3500.00, 'Monitor 24 pulgadas', 4),
('Impresora', 'Electrónica', 15, 4200.00, 'Impresora láser', 5);

INSERT INTO customerOrder (customerID, date, total, paymentMethod, status) VALUES
(1, '2025-01-10 10:30:00', 15250.00, 'Tarjeta', 'Pagado'),
(2, '2025-01-11 12:00:00', 500.00, 'Efectivo', 'Pagado'),
(3, '2025-01-12 15:45:00', 450.00, 'Transferencia', 'Pendiente'),
(4, '2025-01-13 09:20:00', 3500.00, 'Tarjeta', 'Pagado'),
(5, '2025-01-14 18:10:00', 4200.00, 'Efectivo', 'Cancelado');

INSERT INTO orderProduct (orderID, productID, quantity, price) VALUES
(1, 1, 1, 15000.00),
(1, 2, 1, 250.00),
(2, 3, 1, 450.00),
(4, 4, 1, 3500.00),
(5, 5, 1, 4200.00);
