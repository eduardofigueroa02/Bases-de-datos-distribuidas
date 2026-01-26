CREATE DATABASE tiendachida;
USE tiendachida;

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
