INSERT INTO tipohabitacion (descripcion) VALUES('1 persona'),('2 personas'),('3 personas'),('4 personas');
INSERT INTO cliente (nombre, apellido) VALUES('Juan', 'Pérez'), ('Ana', 'Gómez'),('Carlos', 'Ramírez'),('Laura', 'Martínez'),('Andrés', 'Gómez'),('Sofía', 'López'),('Miguel', 'Torres');
INSERT INTO dormitorios (idtipohabitacion, disponibles, costonoche) VALUES (1, 5, 100.00),(2, 8, 150.00),(3, 4, 150.00),(4, 2, 140.00);  


CALL reserva(1, 2, CURDATE(), '2024-07-15', '2024-07-20');
CALL reserva(3,'1',CURDATE(), '2024-08-25','2024-08-30');

SELECT * FROM cliente WHERE idcliente =3;
SELECT * FROM dormitorios WHERE idtipohabitacion = '2 personas' AND disponibles > 0;

SELECT * FROM logs_reservas;
SELECT * FROM cliente WHERE idcliente = 1;
SELECT * FROM tipohabitacion;