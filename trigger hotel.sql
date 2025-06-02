USE `elhotel`;
DROP procedure IF EXISTS `reserva`;

USE `elhotel`;
DROP procedure IF EXISTS `elhotel`.`reserva`;
;

DELIMITER $$
USE `elhotel`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `reserva`(
  IN p_idcliente INT,
  IN p_idtipohabitacion INT,
  IN p_fechareserva DATE,
  IN p_fechacheckin DATE,
  IN p_fechacheckout DATE
)
BEGIN
  DECLARE v_iddormitorio INT;
  DECLARE v_costonoche DECIMAL(10,2);
  DECLARE v_dias INT;
  DECLARE v_costototal DECIMAL(10,2);
  DECLARE v_disponibles INT;
  DECLARE v_precio_sin_descuento DECIMAL(10,2);
  DECLARE v_descuento_aplicado BOOLEAN DEFAULT FALSE;

  /* 1. Aqui validamos las fechas*/
  IF p_fechacheckin >= p_fechacheckout THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Error: La fecha de checkin debe ser anterior al checkout';
  END IF;
  
  IF p_fechareserva > p_fechacheckin THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Error: La fecha de reserva no puede ser posterior al checkin';
  END IF;

  /* 2. Por aca se verifica la disponibilidad */
  SELECT d.iddormitorio, dd.disponibles INTO v_iddormitorio, v_disponibles
  FROM dormitorios d
  JOIN dormitoriodisponible dd ON d.iddormitorio = dd.iddormitorio
  WHERE d.idtipohabitacion = p_idtipohabitacion AND dd.disponibles > 0
  LIMIT 1;

  IF v_iddormitorio IS NULL THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No hay dormitorios disponibles de este tipo';
  END IF;

  /* 3.Estos son los costo por noche */
  SELECT d.costonoche INTO v_costonoche
  FROM dormitorios d
  WHERE d.iddormitorio = v_iddormitorio;

  /* 4. Aqui se hace el calculo de dias y descuento */
  SET v_dias = DATEDIFF(p_fechacheckout, p_fechacheckin);
  SET v_precio_sin_descuento = ROUND(v_dias * v_costonoche, 2);
  
  IF DATEDIFF(p_fechacheckin, p_fechareserva) >= 15 THEN
    SET v_costototal = ROUND(v_precio_sin_descuento * 0.9, 2);
    SET v_descuento_aplicado = TRUE;
  ELSE
    SET v_costototal = v_precio_sin_descuento;
  END IF;

  /*5. Aca insertamos la reserva*/
  INSERT INTO reservas (idcliente, iddormitorio, fechareserva, fechacheckin, fechacheckout, costofinal)
  VALUES (p_idcliente, v_iddormitorio, p_fechareserva, p_fechacheckin, p_fechacheckout, v_costototal);

  /* 6. esta parte actualiza la disponibilidad*/
  UPDATE dormitoriodisponible SET disponibles = disponibles - 1 
  WHERE iddormitorio = v_iddormitorio;

/* 7. Y esto lo que hace es que registra en la tabla logs */
INSERT INTO logs_reservas (idreserva, mensaje)
VALUES (LAST_INSERT_ID(), 
 CONCAT('Reserva creada. ',
 IF(v_descuento_aplicado, CONCAT('Descuento 10% aplicado. Precio original: ', v_precio_sin_descuento),'Sin descuento aplicado'),'. Total: ', v_costototal));
END;$$

DELIMITER ;



DELIMITER //
CREATE TRIGGER tr_gestion_reservas AFTER INSERT ON reservas FOR EACH ROW
BEGIN
    /*Registra en la tabla registro*/
    INSERT INTO registro (tipoevento, idafectado, tablaafectada, descripcion, usuario)
    VALUES (
        'RESERVA', 
        NEW.idreserva, 
        'reservas', 
        CONCAT('Reserva #', NEW.idreserva, ' - Cliente: ', NEW.idcliente),
        USER()
    );
    
    /*Hace la actualizacion la última reserva del cliente*/
    UPDATE cliente SET ultimareserva = NOW() WHERE idcliente = NEW.idcliente;
END //
DELIMITER ;


