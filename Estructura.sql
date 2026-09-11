--Proyecto de base de datos para compras***********************
--Grupo Operador de Alimentos Emho
--Erick Genro Pi�a Arrieta Barbosa
--CDMX a 5 de diciembre de 2025
--Actualizado: 11/09/2026
--Estructura de la base de datos
--*************************************************************************************

--***************************Creación de base de datos*********************************
use master;
GO
--drop Database bdCompras; --¡¡¡¡¡Borra la base de datos si existe una con ese nombre!!!!!
--GO
create database bdCompras;
GO
use bdCompras;
GO 
create schema Proveedor;
GO
create schema Empresa;			
GO
create schema SAT;      
GO
create schema Factura;
GO -- 

--************************************ Esquema Proveedor **********************************
use bdCompras;
GO
create table Proveedor.Nombre(id_Proveedor int identity(1,1) not null,
							  RFC varchar(13) not null,
							  Razon_Social nvarchar(240) not null,
							  Nombre_Comercial nvarchar(128)
							  --Clave primaria
							  constraint pk_Proveedor_Nombre_id_Proveedor
							  primary key (id_Proveedor),
							  --Validación de RFC
							  constraint uq_Nombre_Proveedor_RFC
							  unique(RFC),
							  constraint chk_Nombre_Proveedor_RFC_len
							  check(len(RFC) in (12,13))
							 );
GO
create view Proveedor.vw_Proveedor_Nombre as
	select pn.id_Proveedor as [ID_PROVEEDOR],
		   pn.RFC,
		   pn.Razon_Social as [RAZON SOCIAL],
		   pn.Nombre_Comercial as [NOMBRE COMERCIAL]
		from Proveedor.Nombre pn; 
GO
select * from Proveedor.vw_Proveedor_Nombre
	order by [RAZON SOCIAL] asc; --  
								 --Ejecutar Datos_Proveedor_Nombre.sql,  
GO

-- ********************************* Esquema Empresa ***************************************************
create table Empresa.Nombre
							(id_Empresa int identity(1,1) not null,
							RFC varchar(13) not null,
							Razon_Social nvarchar(240) not null
							--Clave primaria
							constraint pk_Empresa_Nombre_id_Empresa
							primary key(id_Empresa),
							--Validación del RFC
							constraint uq_Empresa_Nombre_RFC
							unique(RFC),
							constraint chk_Empresa_Nombre_RFC
							check(len(RFC) in (12,13))
						   );
GO
create view Empresa.vw_Empresa_Nombre as
select em.id_Empresa as ID,
	   em.RFC,
	   em.Razon_Social as [RAZON SOCIAL]
	from Empresa.Nombre em;
GO
select * from Empresa.vw_Empresa_Nombre;   
								         -- Ejecutar Datos_Empresa_Nombre.sql,  

-----*************************** ESQUEMA SAT ***********************************************

--*************************Productos y servicios del SAT************************************
create table SAT.Catalogo_Producto_Servicio(
id_Producto_Servicio int NOT NULL,
nombre nvarchar(160) NOT NULL,
constraint pk_SAT_Producto_Servicio_id_Producto_Servicio
primary key(id_Producto_servicio) 
);
GO 
create view SAT.vw_Catalogo_Producto_Servicio as
select id_Producto_Servicio as [Clave SAT Prod Serv],
	   nombre as [Producto o servicio]
from SAT.Catalogo_Producto_Servicio;
GO
select * from SAT.vw_Catalogo_Producto_Servicio
order by [Producto o servicio] asc;
GO -- Ejecutar Datos_SAT_Catalogo_Producto_Servicio.sql.
 
--Crear una tabla virtual en la cual se enlisten todas las clases de productos,

create view SAT.vw_Clase_Catalogo_Producto_Servicio
as
SELECT *
FROM SAT.Catalogo_Producto_Servicio AS cps
WHERE cps.id_Producto_Servicio % 100 = 0;
GO
select * from SAT.vw_Clase_Catalogo_Producto_Servicio vccps 
order by vccps.id_Producto_Servicio asc;
GO

drop table SAT.Catalogo_Producto_Servicio;
--**************************Tabla de unidades de medida del SAT****************************
use bdCompras;
GO
create table SAT.Catalogo_Unidad_Medida(id_Unidad smallint not null,
								 Clave_Unidad varchar(8) not null,
								 Nombre nvarchar(160) not null,
								 
								 constraint pk_SAT_Catalogo_Unidad_Medidas_id_Unidad
								 primary key(id_Unidad),

								 constraint uq_SAT_Catalogo_Unidad_Medida_Clave_Unidad
								 unique(Clave_Unidad)
								 ); 
GO
 create view SAT.vw_SAT_Catalogo_Unidad_Medida as
	 select id_Unidad as ID,
			Clave_Unidad as [CLAVE UNIDAD],
			Nombre as NOMBRE
		 from SAT.Catalogo_Unidad_Medida; 
GO -- 
   --Ejecutar Datos_SAT_Unidad_Medida.sql,  

--***************************Tabla de catálogo de monedas del SAT***************************
use bdCompras;
GO
create table SAT.Catalogo_Moneda(id_Moneda smallint not null,
								  Clave_Moneda char(3) not null,
								  Nombre nvarchar(120) not null,

								  constraint pk_SAT_Catalogo_Moneda_id_Moneda
								  primary key(id_Moneda),

								  constraint uq_SAT_Catalogo_Moneda_Clave_Moneda
								  unique(Clave_Moneda)  
								 );
GO
 create view SAT.vw_SAT_Catalogo_Moneda as
	 select id_Moneda as ID,
			Clave_Moneda as [CLAVE MONEDA],
			Nombre as NOMBRE
		 from SAT.Catalogo_Moneda;
GO  
   --Ejecutar Datos_SAT_Catalogo_Moneda.sql

----************************************ Esquema Factura ********************************
----Tabla de encabezados de facturas emitidas por proveedores  
use bdCompras;
GO
create table Factura.Encabezado(
id_Factura int identity(1,1) not null,
UUID uniqueidentifier not null,
CFDI_Nombre_Archivo nvarchar(120) not null,
CFDI_Version nvarchar(3) not null,
CFDI_Serie nvarchar(32),
CFDI_Folio nvarchar(32),
CFDI_Fecha datetime2(0) not null,
CFDI_Subtotal decimal(18,2) not null,
CFDI_Descuento decimal(18,2),
CFDI_Total_Impuestos_Trasladadados decimal(18,2),
CFDI_Total decimal(18,2) not null,
Clave_Moneda char(3) not null,  
CFDI_Tipo_Comprobante char(1) not null,
CFDI_Metodo_Pago char(3) not null,
CFDI_Forma_Pago char(2) not null,
Emisor_RFC varchar(13) not null, 
Emisor_Regimen_Fiscal smallint not null,
Receptor_RFC varchar(13) not null,
Receptor_Uso_CFDI char(3) not null,
Link_CFDI nvarchar(192),
--Clave primaria
constraint pk_Proveedor_Factura_id_Factura
primary key(id_Factura),							   							   
--Claves foráneas
constraint fk_Factura_Encabezado_Clave_Moneda
foreign key(Clave_Moneda)
references SAT.Catalogo_Moneda(Clave_Moneda),
--
constraint fk_Factura_Encabezado_Emisor_RFC
foreign key(Emisor_RFC)
references Proveedor.Nombre(RFC),
--
constraint fk_Factura_Encabezado_Receptor_RFC
foreign key(Receptor_RFC)
references Empresa.Nombre(RFC),
-- Índices
index ix_Factura_Encabezado_Emisor_RFC_CFDI_Fecha(Emisor_RFC,CFDI_Fecha),
--Validación de datos 
constraint uq_Factura_Encabezado_UUID
unique(UUID),
--
constraint chk_Factura_Encabezado_CFDI_Tipo_Comprobante
check(CFDI_Tipo_Comprobante in ('I','i')),
--
constraint chk_Factura_Encabezado_CFDI_Metodo_Pago
check(CFDI_Metodo_Pago in ('PUE','PPD')),
--
constraint chk_Factura_Encabezado_CFDI_Forma_Pago
check(CFDI_Forma_Pago like '[0-9][0-9]'),
--
constraint chk_Factura_Encabezado_Emisor_Regimen_Fiscal
check(Emisor_Regimen_Fiscal in (601,603,605,606,607,608,610,611,612,614,615,616,620,621,622,623,624,625,626)),
--
constraint chk_Factura_Encabezado_Receptor_Uso_CFDI
check(Receptor_Uso_CFDI in ('G01','G02','G03','I01','I02','I03','I04','I05','I06','I07','I08','D01','D02','D03','D04','D05','D06','D07','D08','D09','D10','S01','CP01','CN01'))
);
GO
--Crear la vista
create view Factura.vw_Factura_Encabezado as
select 
fe.id_Factura,
fe.UUID,
fe.CFDI_Nombre_Archivo,
fe.CFDI_Version,
fe.CFDI_Serie,
fe.CFDI_Folio,
fe.CFDI_Fecha,
fe.CFDI_Subtotal,
fe.CFDI_Descuento,
fe.CFDI_Total_Impuestos_Trasladadados,
fe.CFDI_Total,
fe.Clave_Moneda,  
fe.CFDI_Tipo_Comprobante,
fe.CFDI_Metodo_Pago,
fe.CFDI_Forma_Pago,
fe.Emisor_RFC,
pn.Razon_Social as Emisor_Razon_Social,
fe.Emisor_Regimen_Fiscal,
fe.Receptor_RFC,
fe.Receptor_Uso_CFDI,
fe.Link_CFDI
from Factura.Encabezado fe
join Proveedor.Nombre pn
on fe.Emisor_RFC = pn.RFC; 
GO 
--Vista, consulta el importe total de compras por proveedor
create view Factura.vw_Importe_Total_Facturado_Proveedor AS
select pn.Razon_social,fe.Emisor_RFC, sum(fe.CFDI_Total) as Importe_total_facturado
from Factura.Encabezado fe
join Proveedor.Nombre pn
on fe.Emisor_RFC = pn.RFC
group by pn.Razon_Social, fe.Emisor_RFC;

GO

select * from Factura.vw_Importe_Total_Facturado_Proveedor

   --Ejecutar Datos_Factura_Encabezado.sql
--Se modiico el tipo de datos de CFDI_Version char(3) por CFDI_Version nvarchar(3)
-- Ya esta el tipo correcto en el script anterior
--alter table Factura.Encabezado
--alter column CFDI_Version nvarchar(3) not null;

--*************************************Tabla conceptos de facturas*****************************
use bdCompras;
GO
create table Factura.Transaccion(
id_Transaccion int identity(1,1) not null,
UUID uniqueidentifier not null,
Partida smallint not null,
Concepto_No_Identificacion nvarchar(128),
Concepto_Descripcion nvarchar(240) not null,
id_Producto_Servicio int not null,
Concepto_Cantidad decimal(18,2) not null,
Clave_Unidad varchar(8) not null,
Concepto_Unidad nvarchar(128),
Concepto_Valor_Unitario decimal(18,2) not null,
Concepto_Importe decimal(18,2) not null,
Concepto_Descuento decimal(18,2),
Impuesto_IVA_Base decimal(18,2) not null,
Impuesto_IVA_Tasa_Cuota decimal(6,4) not null,
Impuesto_IVA_Importe decimal(18,2) not null,
Impuesto_IEPS_Base decimal(18,2) not null,
Impuesto_IEPS_Tasa_Cuota decimal(6,4) not null,
Impuesto_IEPS_Importe decimal(18,2) not null,
--Clave primaria
constraint pk_Factura_Transaccion_id_Transaccion
primary key(id_Transaccion),
--Claves foráneas
constraint fk_Factura_Transaccion_UUID
foreign key(UUID)
references Factura.Encabezado(UUID),
--
constraint fk_Factura_Transaccion_id_Producto_Servicio
foreign key(id_Producto_Servicio)
references SAT.Catalogo_Producto_Servicio(id_Producto_Servicio),
--
constraint fk_Factura_Transaccion_Clave_Unidad
foreign key(Clave_Unidad)
references SAT.Catalogo_Unidad_Medida(Clave_Unidad),
--Validacíón de datos
constraint uq_Transaccion_Factura_UUID_Partida
unique(UUID, Partida)
);
GO
--Indices de la tabla Factura.Transaccion
CREATE NONCLUSTERED INDEX ix_Factura_Transaccion_UUID
ON Factura.Transaccion(UUID); 
GO
CREATE NONCLUSTERED INDEX IX_Factura_Transaccion_Producto
ON Factura.Transaccion(id_Producto_Servicio); 
GO
--Vista Factura.Transaccion
create view vw_Factura_Transaccion as
select 
ft.id_Transaccion, 
ft.UUID,
ft.Partida, 
ft.Concepto_No_Identificacion,
ft.Concepto_Descripcion,
ft.id_Producto_Servicio,
ft.Concepto_Cantidad,
ft.Clave_Unidad,
ft.Concepto_Unidad, 
ft.Concepto_Valor_Unitario, 
ft.Concepto_Importe,
ft.Concepto_Descuento, 
ft.Impuesto_IVA_Base,
ft.Impuesto_IVA_Tasa_Cuota, 
ft.Impuesto_IVA_Importe, 
ft.Impuesto_IEPS_Base,
ft.Impuesto_IEPS_Tasa_Cuota, 
ft.Impuesto_IEPS_Importe
from Factura.Transaccion ft;
GO 
--Vista Factura con encabezado y transaccion
create view Factura.vw_Factura_Encabezado_Transaccion as
select
fe.id_Factura,
fe.UUID as CFDI_UUID,
fe.CFDI_Nombre_Archivo,
fe.CFDI_Version,
fe.CFDI_Serie,
fe.CFDI_Folio,
fe.CFDI_Fecha,
fe.CFDI_Subtotal,
fe.CFDI_Descuento,
fe.CFDI_Total_Impuestos_Trasladadados,
fe.CFDI_Total,
fe.Clave_Moneda,  
fe.CFDI_Tipo_Comprobante,
fe.CFDI_Metodo_Pago,
fe.CFDI_Forma_Pago,
fe.Emisor_RFC, 
fe.Emisor_Regimen_Fiscal,
fe.Receptor_RFC,
fe.Receptor_Uso_CFDI,
fe.Link_CFDI,
ft.id_Transaccion, 
ft.UUID as Concepto_UUID,
ft.Partida, 
ft.Concepto_No_Identificacion,
ft.Concepto_Descripcion,
ft.id_Producto_Servicio,
ft.Concepto_Cantidad,
ft.Clave_Unidad,
ft.Concepto_Unidad, 
ft.Concepto_Valor_Unitario, 
ft.Concepto_Importe,
ft.Concepto_Descuento, 
ft.Impuesto_IVA_Base,
ft.Impuesto_IVA_Tasa_Cuota, 
ft.Impuesto_IVA_Importe, 
ft.Impuesto_IEPS_Base,
ft.Impuesto_IEPS_Tasa_Cuota, 
ft.Impuesto_IEPS_Importe
from Factura.Encabezado fe
join Factura.Transaccion ft
on fe.UUID = ft.UUID;
GO   --  Ejecutar Datos_Factura_Transaccion.sql

--************************** Usuario Catalogos ****************************

--Login al servidor
use master;
GO
create login Usuario_Catalogos
--with password = 'Usuario_Catalogos_12345'
with password = 'Usr_Cat_2026$'; --Para cumplir con la política de contraseñas de Azure SQL Database
GO
--Usuario en la base de datos
use bdCompras;
GO
create user Usuario_Catalogos
for login Usuario_Catalogos;
GO
--Rol para el usuario Catalogos
create role Rol_Catalogos;
GO
--Permisos para el rol Catalogos en el esquema Empresa
grant select, insert, update, delete 
on Schema::Empresa to Rol_Catalogos;
GO
--Permisos para el rol Catalogos en el esquema Proveedor
grant select, insert, update, delete 
on Schema::Proveedor to Rol_Catalogos;
GO
--Permisos para el rol Catalogos en el esquema SAT
grant select, insert, update, delete 
on Schema::SAT to Rol_Catalogos;
GO
--Añadir al usuario Catalogos al rol Catalogos
alter role Rol_Catalogos 
add member Usuario_Catalogos;
GO
--Añadir permisos de lectura para el rol Catalogos
alter role db_datareader
add member Usuario_Catalogos; -- 
GO

--************************** Usuario Facturas ****************************
--Login al servidor
use master;
go
create login Usuario_Facturas
--with password = 'Usuario_Facturas_12345';
with password = 'Usr_Fac_2026$'; --Para cumplir con la política de contraseñas de Azure SQL Database
go
--Usuario en la base de datos
use bdCompras;
go
create user Usuario_Facturas
for login Usuario_Facturas;
go
--Rol para el usuario Facturas
create role Rol_Facturas;
go
--Permisos para el rol Facturas en el esquema Factura
grant select, insert, update, delete
on Schema::Factura to Rol_Facturas;
go
--Añadir al usuario Facturas al rol Facturas
alter role Rol_Facturas
add member Usuario_Facturas;
go
--Añadir permisos de lectura para el rol Facturas
alter role db_datareader
add member Usuario_Facturas;
go



