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

  /* Verificar disponibilidad exacta según tus tablas */
  SELECT d.iddormitorio, dd.disponibles INTO v_iddormitorio, v_disponibles
  FROM dormitorios d
  JOIN dormitoriodisponible dd ON d.iddormitorio = dd.iddormitorio
  WHERE d.idtipohabitacion = p_idtipohabitacion AND dd.disponibles > 0
  LIMIT 1;

  IF v_iddormitorio IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay dormitorios disponibles de este tipo';
  END IF;

  /* aqui se obtiene costo exacto de dormitorios*/
  SELECT d.costonoche INTO v_costonoche
  FROM dormitorios d
  WHERE d.iddormitorio = v_iddormitorio;

  /* Esta es la funcion para Cálculo exacto de días y costos */
  SET v_dias = DATEDIFF(p_fechacheckout, p_fechacheckin);
  
  IF v_dias <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de checkout debe ser posterior al checkin';
  END IF;
  
  /* Aplica descuento por reserva anticipada */
  IF DATEDIFF(p_fechacheckin, p_fechareserva) >= 15 THEN
    SET v_costototal = ROUND(v_dias * v_costonoche * 0.9, 2);
  ELSE
    SET v_costototal = ROUND(v_dias * v_costonoche, 2);
  END IF;

  /* Inserta en reservas con los nombres exactos de columnas */
  INSERT INTO reservas (idcliente, iddormitorio, fechareserva, fechacheckin, fechacheckout, costofinal)
  VALUES (p_idcliente, v_iddormitorio, p_fechareserva, p_fechacheckin, p_fechacheckout, v_costototal);

  /* Actualiza la disponibilidad exacta */
  UPDATE dormitoriodisponible SET disponibles = disponibles - 1 
  WHERE iddormitorio = v_iddormitorio;
END;$$

DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_gestion_reservas AFTER INSERT ON reservas FOR EACH ROW
BEGIN
    /*Registro en tu tabla registro*/
    INSERT INTO registro (tipoevento, idafectado, tablaafectada, descripcion, usuario)
    VALUES (
        'RESERVA', 
        NEW.idreserva, 
        'reservas', 
        CONCAT('Reserva #', NEW.idreserva, ' - Cliente: ', NEW.idcliente),
        USER()
    );
    
    /*Actualización de última reserva del cliente*/
    UPDATE cliente SET ultimareserva = NOW() WHERE idcliente = NEW.idcliente;
END //
DELIMITER ;


