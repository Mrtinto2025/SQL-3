CREATE DEFINER=`root`@`localhost` PROCEDURE `reserva`(
  in p_idcliente int,
  in p_tipo enum('1 persona', '2 personas', '3 personas', '4 personas'),
  in p_fechareserva date,
  in p_fechacheckin date,
  in p_fechacheckout date
)
BEGIN
/*Aqui lo que se realiza es la (declaracion) de las variables */
declare v_iddormitorio int;
declare v_costonoche decimal(10,2);
declare v_dias int;
declare v_costototal decimal(10,2);

/*Una aclaracion d.tipo y p_tipo son distintos*/ /*el alias 'd' es de la tabla dormitorio y la 'p' es de parametro*/
select  d.iddormitorio, d.costonoche into v_iddormitorio, v_costonoche
from dormitorios d
where d.tipo = p_tipo and d.disponibles > 0  -- 
limit 1;

/*Este bloque rectifica que haya disponibilidad de dormitorios de lo contrario arrojara el mensaje de que no, y el alias de 'v' es variable*/
if v_iddormitorio is null then
signal sqlstate '45000' 
set message_text = 'No hay dormitorios disponibles';
end if;

 set v_dias = DATEDIFF(p_fechacheckout, p_fechacheckin);
 
/* Y este bloque de scripts aplica lo que es la logica del negocio es decir aplicar el descuentodel 10%*/
if DATEDIFF(p_fechacheckin, p_fechareserva) >= 15 then
set v_costototal = v_dias * v_costonoche * 0.9;
else
set v_costototal = v_dias * v_costonoche;
end if;

INSERT INTO reservas (idcliente, iddormitorio, fechareserva, fechacheckin, fechacheckout, costofinal)
VALUES (p_idcliente, v_iddormitorio, p_fechareserva, p_fechacheckin, p_fechacheckout, v_costototal);

/*El update lo que hace es que actualiza cada que ocupa un dormitorio*/
update dormitorios set disponibles = disponibles - 1 
where iddormitorio = v_iddormitorio;
END