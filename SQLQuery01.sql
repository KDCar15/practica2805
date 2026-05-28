/*Crear una base de datos llamada UniversidadDB la cual maneja dos módulos:
académico y seguridad.

Módulo académico: Carrera y estudiante

Módulo seguridad: Cargo y usuario*/

USE master
GO

IF EXISTS(SELECT * FROM sys.databases WHERE NAME = 'UniversidadDB')
	BEGIN
		ALTER DATABASE UniversidadDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE UniversidadDB
	END
GO

CREATE DATABASE UniversidadDB
GO

USE UniversidadDB
GO

--Schema: es un contenedor que sirve para organizar objetos dentro de una tabla
CREATE SCHEMA Academico
GO

CREATE SCHEMA Seguridad
GO

CREATE TABLE Academico.Carrera (
	id INT PRIMARY KEY IDENTITY(1,1)
	, nombre NVARCHAR(100) NOT NULL
	, precio DECIMAL(10,2) NOT NULL
	, created_at DATETIME DEFAULT GETDATE()
	, updated_at DATETIME NULL
	, deleted_at DATETIME NULL	
)
GO

CREATE TABLE Academico.Estudiante (
	id INT IDENTITY(1,1) PRIMARY KEY
	, cif VARCHAR(8) UNIQUE NOT NULL
	, nombres NVARCHAR(60) NOT NULL
	, apellidos NVARCHAR(60) NOT NULL
	, fecha_nac DATETIME NULL
	, email NVARCHAR(120) NULL
	, telefono NVARCHAR(60) NULL
	, id_carrera INT FOREIGN KEY REFERENCES Academico.Carrera(id)
)
GO

CREATE TABLE Seguridad.Cargo (
	id INT IDENTITY(1,1) PRIMARY KEY
	, nombre NVARCHAR(60)
	, created_at DATETIME DEFAULT GETDATE()
	, updated_at DATETIME NULL
	, deleted_at DATETIME NULL	
)
GO

CREATE TABLE Seguridad.Usuario(
	id int identity(1, 1) primary key
	, cif varchar(16) unique not null
	, nombres nvarchar(60) not null
	, apellidos nvarchar(60) not null
	, fechaNac datetime null
	, pw varbinary(64) not null
	, email nvarchar(120) null
	, created_at DATETIME DEFAULT GETDATE()
	, updated_at DATETIME NULL
	, deleted_at DATETIME NULL
	)
GO

------------------------------------------
--Academico.carrera
------------------------------------------

-- Revisión para el precio
ALTER TABLE Academico.Carrera
ADD CONSTRAINT ck_precio
CHECK(precio > 0)
GO

------------------------------------------
--Academico.estudiante
------------------------------------------

-- Añadido NULL y campos de auditoría
ALTER TABLE Academico.Estudiante
ADD created_at DATETIME DEFAULT GETDATE()
	, update_at DATETIME NULL
	, delete_at DATETIME NULL
GO

-- Check del formato del email
ALTER TABLE Academico.Estudiante
ADD CONSTRAINT ck_email_estudiante
CHECK(email LIKE '%@%.%')
GO

-- Check de la longitud del cif
ALTER TABLE Academico.Estudiante
ADD CONSTRAINT ck_cif_estudiante
CHECK(LEN(cif) = 8)
GO

------------------------------------------
--Seguridad.Cargo
------------------------------------------

-- Añadido NULL
ALTER TABLE Seguridad.Cargo
ADD update_at DATETIME NULL
	, delete_at DATETIME NULL
GO

-- Cambio de longitud y NOT NULL
ALTER TABLE Seguridad.Cargo
ALTER COLUMN nombre NVARCHAR(100) NOT NULL
GO

------------------------------------------
--Seguridad.Usuario
------------------------------------------

-- FK añadida para Cargo
ALTER TABLE Seguridad.Usuario
ADD idCargo INT NULL
GO

-- Añadido NULL
ALTER TABLE Seguridad.Usuario
ADD update_at DATETIME NULL
	, delete_at DATETIME NULL
GO

-- FK en constraint
ALTER TABLE Seguridad.Usuario
ADD CONSTRAINT fk_idcargo
FOREIGN KEY(idCargo)
REFERENCES Seguridad.Cargo(id)
GO

-- Check para el formato del correo
ALTER TABLE Seguridad.Usuario
ADD CONSTRAINT ck_email_usuario
CHECK(email LIKE '%@%.%')
GO

-- Check para la longitud del cif mayor a 8
ALTER TABLE Seguridad.Usuario
ADD CONSTRAINT ck_cif_usuario
CHECK(LEN(cif) >= 8)
GO

-- Cambio de los nombres
ALTER TABLE Seguridad.Usuario
ALTER COLUMN nombres NVARCHAR(100) NOT NULL
GO

-- Cambio de longitud de los apellidos
ALTER TABLE Seguridad.Usuario
ALTER COLUMN apellidos NVARCHAR(100) NOT NULL
GO

-- Cambio temporal para validar contraseña

ALTER TABLE Seguridad.Usuario
ALTER COLUMN pw NVARCHAR(100) NOT NULL
GO

-- Longitud mínima de contraseña

CREATE TRIGGER Seguridad.trg_validar_password
ON Seguridad.Usuario
INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON

	-- Longitud mínima
	IF EXISTS(
		SELECT 1
		FROM inserted
		WHERE LEN(pw) < 8
	)
	BEGIN
		RAISERROR('La contraseña debe tener al menos 8 caracteres.', 16, 1)
		RETURN
	END

	INSERT INTO Seguridad.Usuario(
		idCargo,
		cif,
		nombres,
		apellidos,
		fechaNac,
		pw,
		email,
		created_at,
		update_at,
		delete_at
	)
	SELECT
		idCargo,
		cif,
		nombres,
		apellidos,
		fechaNac,
		CONVERT(
			NVARCHAR(100),
			HASHBYTES('SHA2_256', pw),
			1
		),
		email,
		GETDATE(),
		update_at,
		delete_at
	FROM inserted
END
GO