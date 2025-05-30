create database  elhotel;
use elhotel;

create table cliente(
idcliente int primary key auto_increment,
nombre varchar(50),
apellido varchar(50),
telefono varchar (50),
correo varchar(60)
);

create table dormitorios(
iddormitorio int primary key auto_increment,
tipo enum('1 persona', '2 personas', '3 personas', '4 personas'),
disponibles int not null default 0,
costonoche decimal(10,2)not null
);

create table reservas(
idreserva int primary key auto_increment,
iddormitorio int not null,
fechareserva  date,
fechacheckin date,
fechacheckout date,
costofinal decimal(10,2)
);

alter table reservas
add constraint fk_dormitorio
foreign key (iddormitorio) references dormitorios(iddormitorio);

alter table reservas
add column idcliente int;

ALTER TABLE reservas
ADD CONSTRAINT fk_cliente
FOREIGN KEY (idcliente)  REFERENCES cliente(idcliente);
