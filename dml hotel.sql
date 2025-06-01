INSERT INTO tipohabitacion (descripcion) VALUES('1 persona'),('2 personas'),('3 personas'),('4 personas');
INSERT INTO dormitoriodisponible (iddormitorio, disponibles)
SELECT iddormitorio, 
       CASE 
           WHEN idtipohabitacion = 1 THEN 5  
           WHEN idtipohabitacion = 2 THEN 8  
           WHEN idtipohabitacion = 3 THEN 4  
           WHEN idtipohabitacion = 4 THEN 2  
       END
FROM dormitorios;

INSERT INTO cliente (nombre, apellido, telefono, correo) VALUES('Juan', 'Pérez', '555-123-4567', 'juan.perez@example.com'),('Ana', 'Gómez', '555-234-5678', 'ana.gomez@example.com'),
('Carlos', 'Ramírez', '555-345-6789', 'carlos.ramirez@example.com'),
('Laura', 'Martínez', '555-456-7890', 'laura.martinez@example.com'),
('Andrés', 'Gómez', '555-567-8901', 'andres.gomez@example.com'),
('Sofía', 'López', '555-678-9012', 'sofia.lopez@example.com'),
('Miguel', 'Torres', '555-789-0123', 'miguel.torres@example.com');
INSERT INTO dormitorios (idtipohabitacion, disponibles, costonoche) VALUES (1, 5, 100.00),(2, 8, 150.00),(3, 4, 150.00),(4, 2, 140.00);  


CALL reserva(1, 2, CURDATE(), '2024-07-15', '2024-07-20');
CALL reserva(3,'1',CURDATE(), '2024-08-25','2024-08-30');

SELECT * FROM cliente WHERE idcliente =3;
SELECT * FROM dormitorios WHERE idtipohabitacion = '2 personas' AND disponibles > 0;

SELECT * FROM elhotel.cliente;
SELECT * FROM elhotel.dormitorios;
SELECT * FROM tipohabitacion;
SELECT * FROM elhotel.dormitoriodisponible;
SELECT * FROM elhotel.registro;
SELECT * FROM logs_reservas;
SELECT * FROM cliente WHERE idcliente = 1;

SELECT d.iddormitorio, t.descripcion, dd.disponibles
FROM dormitorios d
JOIN tipohabitacion t ON d.idtipohabitacion = t.idtipohabitacion
JOIN dormitoriodisponible dd ON d.iddormitorio = dd.iddormitorio;