DROP DATABASE IF EXISTS parq2;
CREATE DATABASE parq2;
USE parq2;
CREATE TABLE documento (
    ID_documento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    tipodocumento VARCHAR(20)
);

CREATE TABLE plazas_espacios (
    ID_plazas INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    plaza VARCHAR(20)
);

CREATE TABLE color_vehiculos (
    ID_color INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    color VARCHAR(20)
);

CREATE TABLE marca_vehiculos (
    ID_marca INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    marca VARCHAR(20)
);

CREATE TABLE categoria_vehiculos (
    ID_categoria INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    categoria VARCHAR(20)
);

CREATE TABLE modelo_vehiculos (
    ID_modelo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(20)
);

CREATE TABLE clientes (
    ID_clientes INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    numerodoc INT (20),
    nombre VARCHAR(20),
    apellido VARCHAR(20),
    telefono VARCHAR(20),
    ID_documento INT,
    ID_reserva INT
);

CREATE TABLE espacios (
    ID_espacios INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    numeroespacio INT,
    estado INT,
    ID_plaza INT
);

CREATE TABLE vehiculos (
    ID_vehiculo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    placa VARCHAR(10),
    ID_clientes INT,
    ID_color INT,
    ID_modelo INT,
    ID_marca INT,
    ID_categoria INT
);

CREATE TABLE factura (
    ID_factura INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    montopagar DECIMAL(10,2),
    fechahora_generacion DATETIME,
    ID_clientes INT
);

CREATE TABLE reservas (
    ID_reserva INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    fechainicio DATETIME,
    fechafin DATETIME,
    horainicio TIME,
    horafin TIME,
    ID_factura INT,
    ID_espacios INT,
    ID_clientes INT
);

CREATE TABLE tarifas (
    ID_tarifas INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    costohora DECIMAL(10,2),
	costodia DECIMAL(10,2),
    ID_factura INT,
    ID_vehiculo INT
);

CREATE TABLE vehiculos_espacios (
    vehiculo_ID_vehiculo INT NOT NULL,
    espacio_ID_espacios INT NOT NULL,
    PRIMARY KEY (vehiculo_ID_vehiculo, espacio_ID_espacios)
);

ALTER TABLE clientes
ADD CONSTRAINT FK_clientes_documento
FOREIGN KEY (ID_documento) REFERENCES documento(ID_documento);

ALTER TABLE vehiculos
ADD CONSTRAINT FK_vehiculos_clientes
FOREIGN KEY (ID_clientes) REFERENCES clientes(ID_clientes);

ALTER TABLE vehiculos
ADD CONSTRAINT FK_vehiculos_color
FOREIGN KEY (ID_color) REFERENCES color_vehiculos(ID_color);

ALTER TABLE vehiculos
ADD CONSTRAINT FK_vehiculos_marca
FOREIGN KEY (ID_marca) REFERENCES marca_vehiculos(ID_marca);

ALTER TABLE vehiculos
ADD CONSTRAINT FK_vehiculos_categoria
FOREIGN KEY (ID_categoria) REFERENCES categoria_vehiculos(ID_categoria);

ALTER TABLE factura
ADD CONSTRAINT FK_factura_clientes
FOREIGN KEY (ID_clientes) REFERENCES clientes(ID_clientes);

ALTER TABLE reservas
ADD CONSTRAINT FK_reservas_factura
FOREIGN KEY (ID_factura) REFERENCES factura(ID_factura);

ALTER TABLE reservas
ADD CONSTRAINT FK_reservas_espacios
FOREIGN KEY (ID_espacios) REFERENCES espacios(ID_espacios);

ALTER TABLE clientes
ADD CONSTRAINT FK_clientes_reservas
FOREIGN KEY (ID_reserva) REFERENCES reservas(ID_reserva);

ALTER TABLE tarifas
ADD CONSTRAINT FK_tarifas_factura
FOREIGN KEY (ID_factura) REFERENCES factura(ID_factura);

ALTER TABLE tarifas
ADD CONSTRAINT FK_tarifas_vehiculo
FOREIGN KEY (ID_vehiculo) REFERENCES vehiculos(ID_vehiculo);

ALTER TABLE vehiculos_espacios
ADD CONSTRAINT FK_vehiculos_espacios_vehiculo
FOREIGN KEY (vehiculo_ID_vehiculo) REFERENCES vehiculos(ID_vehiculo);

ALTER TABLE vehiculos_espacios
ADD CONSTRAINT FK_vehiculos_espacios_espacio
FOREIGN KEY (espacio_ID_espacios) REFERENCES espacios(ID_espacios);

ALTER TABLE reservas
ADD CONSTRAINT FK_reservas_clientes
FOREIGN KEY (ID_clientes) REFERENCES clientes(ID_clientes);