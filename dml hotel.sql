/*este bloque que va de aqui hasta la parte de insrt into dormitorio son los datos que van en cada tabla*/

/*este inser es para los tipos de habitacion*/
INSERT INTO tipohabitacion (descripcion) VALUES('1 persona'),('2 personas'),('3 personas'),('4 personas');

/*este*/
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

INSERT INTO dormitorios (idtipohabitacion,costonoche) VALUES (1, 100.00),(2, 150.00),(3, 150.00),(4, 140.00);  
/*Hata aqui va el bloque para insertar los datos en cada una de las tablas*/

/*estos aplican descuento*/
CALL reserva(3, 2, '2024-06-01', '2024-06-21', '2024-06-25');
CALL reserva(5, 3, '2024-05-15', '2024-06-15', '2024-06-18');
CALL reserva(1, 2, '2024-06-01', '2024-07-15', '2024-07-20');
/*estos no*/
CALL reserva(1, 2, '2024-07-10', '2024-07-15', '2024-07-20');
CALL reserva(2, 1, '2024-06-05', '2024-06-15', '2024-06-17');
CALL reserva(4, 4, '2024-07-12', '2024-07-15', '2024-07-20');


/*esta parte rectifica los datos de cada tabla*/
SELECT * FROM elhotel.cliente;
SELECT * FROM elhotel.dormitorios;
SELECT * FROM tipohabitacion;
SELECT * FROM elhotel.dormitoriodisponible;
/*En estas slection puedes observar si aplicaste con descuento*/
SELECT * FROM elhotel.registro;
SELECT * FROM elhotel.reservas;
SELECT * FROM logs_reservas; /*en especial esta tabla*/


/*este join busca la tabla iddormitorio con la columna descripcion y disponible*/
SELECT d.iddormitorio, t.descripcion, dd.disponibles
FROM dormitorios d
JOIN tipohabitacion t ON d.idtipohabitacion = t.idtipohabitacion
JOIN dormitoriodisponible dd ON d.iddormitorio = dd.iddormitorio;