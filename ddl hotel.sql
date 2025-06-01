DROP DATABASE IF EXISTS elhotel;
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
disponibles int not null default 0,
costonoche decimal(10,2)not null
);

create table tipohabitacion(
idtipohabitacion int primary key auto_increment,
descripcion varchar(40)
);

create table reservas(
idreserva int primary key auto_increment,
iddormitorio int not null,
fechareserva  date,
fechacheckin date,
fechacheckout date,
costofinal decimal(10,2)
);

alter table dormitorios
add column idtipohabitacion int;

alter table reservas
add constraint fk_dormitorio
foreign key (iddormitorio) references dormitorios(iddormitorio);

alter table reservas
add column idcliente int;

alter table  reservas
add constraint fk_cliente
foreign key (idcliente)  references cliente(idcliente);

alter table  dormitorios 
add constraint fk_tipohabitacion
foreign key (idtipohabitacion)  references tipohabitacion(idtipohabitacion);

/*Esta tabla lo que hace es registrar las reservas*/
create table if not exists logs_reservas(
idlog int primary key auto_increment,
idreserva int not null,
mensaje varchar(100) not null,
fecha timestamp default current_timestamp
);

alter table logs_reservas
add constraint fk_reserva
foreign key (idreserva) references reservas(idreserva); 

alter table cliente
add column ultimareserva datetime null default null;