# informacion para ver si realmente sirve 
INSERT INTO documento (tipodocumento) VALUES
('Cédula'),
('Tarjeta Identidad'),
('Pasaporte'),
('Cédula Extranjería');

INSERT INTO plazas_espacios (plaza) VALUES
('Normal'),
('Discapacidad'),
('Moto');

INSERT INTO color_vehiculos (color) VALUES
('Rojo'),
('Azul'),
('Negro'),
('Blanco'),
('Gris');

INSERT INTO marca_vehiculos (marca) VALUES
('Toyota'),
('Honda'),
('Ford'),
('Chevrolet'),
('BMW'),
('Yamaha');

INSERT INTO categoria_vehiculos (categoria) VALUES
('Automóvil'),
('Camioneta'),
('Motocicleta'),
('Camión');

INSERT INTO modelo_vehiculos (modelo) VALUES
('Corolla'),
('Civic'),
('F-150'),
('Spark'),
('X5'),
('R3');
# insertamos cliente como prueba
INSERT INTO clientes (numerodoc, nombre, apellido, telefono, ID_documento) 
VALUES (123456789, 'Juan', 'Pérez', 3101234567, 1);

# insertar espacios que esta disponibles 
INSERT INTO espacios (numeroespacio, estado, ID_plaza) VALUES
(1, 0, 1),  -- Espacio normal disponible
(2, 0, 1),  -- Espacio normal disponible
(3, 0, 3);  -- Espacio para moto disponible

#verficar espacios para el vehiculo 
SELECT espaciodisponible(1) AS espacios_autos;

#verificar espacio para la moto 
SELECT espaciodisponible(3) AS espacios_motos;

#registramos el primer vehiculo 
CALL registrarvehiculo('ABC123', 1, 1, 1, 1, 1, @mensaje);
SELECT @mensaje;

#verificamos si el vehiculo si se registro 
SELECT * FROM vehiculos;

# el vehiculo que espacio ocupo 
SELECT * FROM espacios;

#registramos una moto 
CALL registrarvehiculo('MOT456', 1, 2, 6, 6, 3, @mensaje);
SELECT @mensaje;

#############
# ingresamos un segundo cliente
INSERT INTO clientes (numerodoc, nombre, apellido, telefono, ID_documento) 
VALUES (987654321, 'María', 'Gómez', 3209876543, 1);

# ingresamos un segundo vehiculo para el cliente 
CALL registrarvehiculo('DEF456', 2, 3, 2, 3, 1, @mensaje);
SELECT @mensaje;

# verificamos los vehiculos que estan
SELECT * FROM vehiculos;

#creamos reserva para el primer carro esta da inicio 27/05 y da fin el 29/05
INSERT INTO reservas (fechainicio, fechafin, ID_espacios, ID_clientes)
VALUES (DATE_SUB(CURDATE(), INTERVAL 2 DAY), CURDATE(), 1, 1);

# actualizar el cliente con la reserva
UPDATE clientes SET ID_reserva = LAST_INSERT_ID() WHERE ID_clientes = 1;

# este va reservar por dias completos 
INSERT INTO reservas (fechainicio, fechafin, ID_espacios, ID_clientes)
VALUES (CURDATE(), CURDATE(), 2, 2);

# actualizamos el cliente de la reserva 
UPDATE clientes SET ID_reserva = LAST_INSERT_ID() WHERE ID_clientes = 2;

# miramos si la reserva se realizo
SELECT * FROM reservas;
