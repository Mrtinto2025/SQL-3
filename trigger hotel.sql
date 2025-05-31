DELIMITER //
CREATE TRIGGER tr_after_insert_reserva AFTER INSERT ON reservas FOR EACH ROW
BEGIN
INSERT INTO logs_reservas (idreserva, mensaje)
VALUES (NEW.idreserva, CONCAT('Reserva creada para cliente ID: ', NEW.idcliente));
  

UPDATE cliente SET ultima_reserva = NOW() 
WHERE idcliente = NEW.idcliente;
END //
DELIMITER ;

