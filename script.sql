#funcion para ver si hay espacios disponibles
DELIMITER //

CREATE FUNCTION espaciodisponible(categoria_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE espacios_disponibles INT;
    DECLARE plaza_id INT;
    # elegi segun la categoria del vehiculo la plaza
    IF categoria_id = 3 THEN
        SET plaza_id = 3;
    ELSEIF categoria_id = 4 THEN
        SET plaza_id = 1;
    ELSE 
        SET plaza_id = 1;
    END IF;
    # cuenta espacios disponibles
    SELECT COUNT(*) INTO espacios_disponibles
    FROM espacios e
    WHERE e.estado = 0 AND e.ID_plaza = plaza_id;
    
    RETURN espacios_disponibles;
END//

DELIMITER ;
# procedimiento para registrar un nuevo vehiculo
DELIMITER //

CREATE PROCEDURE registrarvehiculo(
    IN p_placa VARCHAR(255),
    IN p_id_cliente INT,
    IN p_id_color INT,
    IN p_id_modelo INT,
    IN p_id_marca INT,
    IN p_id_categoria INT,
    OUT p_mensaje VARCHAR(100)
    )
BEGIN
    DECLARE espacios_disp INT;
    DECLARE espacio_asignado INT;
    DECLARE v_id_vehiculo INT;
# verifica si hay espacios disponibles 
    SET espacios_disp = espaciodisponible(p_id_categoria);
    # registra el nuevo vehiculo
    IF espacios_disp > 0 THEN
        INSERT INTO vehiculos (placa, ID_clientes, ID_color, ID_modelo, ID_marca, ID_categoria)
        VALUES (p_placa, p_id_cliente, p_id_color, p_id_modelo, p_id_marca, p_id_categoria);
        
        SET v_id_vehiculo = LAST_INSERT_ID();
# el asigna un espacio libre y segun la plaza 
        SELECT MIN(ID_espacios) INTO espacio_asignado
        FROM espacios 
        WHERE estado = 0 AND ID_plaza = 
            CASE 
                WHEN p_id_categoria = 3 THEN 3
                ELSE 1
            END;
# actualiza el estado del espacio
        UPDATE espacios SET estado = 1 WHERE ID_espacios = espacio_asignado;
# relacion vehiculo-espacio
        INSERT INTO vehiculos_espacios VALUES (v_id_vehiculo, espacio_asignado);
        
        SET p_mensaje = CONCAT('Vehículo ID:', v_id_vehiculo, ' asignado a espacio:', espacio_asignado);
    ELSE
        SET p_mensaje = 'No hay espacios disponibles';
    END IF;
END//

DELIMITER ;
# este trigger evita duplicados de placa
DELIMITER //

CREATE TRIGGER placaunica
BEFORE INSERT ON vehiculos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM vehiculos WHERE placa = NEW.placa) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Placa ya registrada';
    END IF;
END//

DELIMITER ;
#####2
#calcula el monto a pagar
DELIMITER //

CREATE FUNCTION calcularmonto(
    p_fecha_inicio DATETIME, 
    p_fecha_fin DATETIME, 
    p_id_categoria INT
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE horas_total INT;
    DECLARE dias_completos INT;
    DECLARE horas_restantes INT;
    DECLARE monto_total DECIMAL(10,2);
    DECLARE tarifa_hora DECIMAL(10,2);
    DECLARE tarifa_dia DECIMAL(10,2);
    #...
    SET horas_total = TIMESTAMPDIFF(HOUR, p_fecha_inicio, p_fecha_fin);
  
	IF horas_total <1 THEN
    set horas_total=1;
    END IF ;
    # tarifa segun  la categoria 
    #moto 
    IF p_id_categoria = 3 THEN
        SET tarifa_hora = 2000.00;
        SET tarifa_dia = 15000.00;
        #camion
    ELSEIF p_id_categoria = 4 THEN
        SET tarifa_hora = 5000.00;
        SET tarifa_dia = 40000.00;
    ELSE
    #carro
        SET tarifa_hora = 3000.00;
        SET tarifa_dia = 25000.00;
    END IF;
    #monto total
SET dias_completos= FLOOR(horas_total/24);
SET horas_restantes=horas_total%24;

IF(horas_restantes*tarifa_hora) > tarifa_dia THEN
SET dias_completos = dias_completos +1;
SET horas_restantes=0;
END IF ;
SET monto_total = (dias_completos * tarifa_dia) + (horas_restantes * tarifa_hora);

RETURN monto_total;
END//

DELIMITER ;

# generar factura al finalizar reserva
DELIMITER //

CREATE PROCEDURE generarfactura(
    IN p_id_reserva INT,
    OUT p_id_factura INT,
    OUT p_minutos_estadia INT
)
BEGIN
    DECLARE v_id_cliente INT;
    DECLARE v_id_vehiculo INT;
    DECLARE v_id_categoria INT;
    DECLARE v_fecha_inicio DATETIME;
    DECLARE v_fecha_fin DATETIME;
    DECLARE v_monto DECIMAL(10,2);
    # datos de la reserva
    SELECT r.ID_clientes, v.ID_vehiculo, v.ID_categoria, r.fechainicio, r.fechafin
    INTO v_id_cliente, v_id_vehiculo, v_id_categoria, v_fecha_inicio, v_fecha_fin
    FROM reservas r
    JOIN clientes c ON r.ID_clientes = c.ID_clientes
    JOIN vehiculos v ON c.ID_clientes = v.ID_clientes
    WHERE r.ID_reserva = p_id_reserva
    LIMIT 1;
    # calcula monto 
    SET v_monto = calcularmonto(v_fecha_inicio, v_fecha_fin, v_id_categoria);
	SET p_minutos_estadia = minutos(v_fecha_inicio);
    #crea la factura
    INSERT INTO factura (montopagar, ID_clientes,fechahora_generacion) 
    VALUES (v_monto, v_id_cliente,NOW());
    
    SET p_id_factura = LAST_INSERT_ID();
    #actualiza la factura 
    UPDATE reservas SET ID_factura = p_id_factura WHERE ID_reserva = p_id_reserva;
    #registra la tarifa
    INSERT INTO tarifas (costohora, costodia, ID_factura, ID_vehiculo)
    VALUES (
        CASE 
            WHEN v_id_categoria = 3 THEN 2000.00 
            WHEN v_id_categoria = 4 THEN 5000.00
            ELSE 3000.00
        END,
        CASE 
            WHEN v_id_categoria = 3 THEN 15000.00
            WHEN v_id_categoria = 4 THEN 40000.00
            ELSE 25000.00
        END,
        p_id_factura,
        v_id_vehiculo
    );
END//

DELIMITER ;
#dejar disponible al finalizar una reserva
DELIMITER //

CREATE TRIGGER liberarespacio
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
# da a verificar si se asigna una factura y en dado caso si termino
    IF NEW.ID_factura IS NOT NULL AND OLD.ID_factura IS NULL THEN
        #espacio libre
        UPDATE espacios SET estado = 0 
        WHERE ID_espacios = NEW.ID_espacios;
        #elimina la relacion vehiculo-espacio
        DELETE FROM vehiculos_espacios 
        WHERE espacio_ID_espacios = NEW.ID_espacios;
    END IF;
END//

DELIMITER ;
#p_ : parametros
#v_ : variables 
DELIMITER //

CREATE FUNCTION minutos(
    fech_ini TIMESTAMP
) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE min INT;
    SET min = TIMESTAMPDIFF(MINUTE, fech_ini, NOW());
    RETURN min;
END//

DELIMITER ;