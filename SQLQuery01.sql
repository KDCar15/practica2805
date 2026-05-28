/*Crear una base de datos llamada UniversidadDB la cual maneje dos módulos: Académico y seguridad.
Módulo académico: Carrera y Estudiante
Módulo seguridad: Cargo y Usuario
*/
USE MASTER
GO

IF(EXISTS(SELECT * FROM sys.databases where name = 'UniversidadDB'))
BEGIN
	DROP DATABASE UniversidadDB
END
GO

CREATE DATABASE UniversidadDB
GO

USE UniversidadDB
GO

-- Schema: Contenedor lógicoque sirve para organizar objetos dentro de una base de datos.
CREATE SCHEMA Academico
GO

CREATE SCHEMA Seguridad
GO

CREATE TABLE Academico.Carrera(
	id				INT IDENTITY(1,1)
	, nombre		NVARCHAR(100)	NOT NULL
	, precio		DECIMAL(10,2)
	, created_at	DATETIME		NOT NULL DEFAULT getdate()
	, update_at		DATETIME		NULL
	, delete_at		DATETIME		NULL -- Añadido NULL

	, CONSTRAINT pk_idcarrera		PRIMARY KEY(id) -- Primary key en constraint
	, CONSTRAINT ck_precio			CHECK(precio > 0) -- Revisión para el precio
)

CREATE TABLE Academico.Estudiante(
	id				INT				IDENTITY(1,1)
	, cif			VARCHAR(8)		NOT NULL
	, nombres		NVARCHAR(100)	NOT NULL
	, apellidos		NVARCHAR(100)	NOT NULL
	, fechaNac		DATETIME		NULL
	, email			NVARCHAR(120)	NULL
	, idCarrera		INT
	, created_at	DATETIME		DEFAULT getdate()
	, update_at		DATETIME		NULL
	, delete_at		DATETIME		NULL -- Añadido Null

	, CONSTRAINT pk_idestudiante	PRIMARY KEY(id) -- PK de la ID en constraint
	, CONSTRAINT fk_idcarrera		FOREIGN KEY(idCarrera)
		REFERENCES Academico.Carrera(id) -- FK de carrera en constraint
	, CONSTRAINT ck_email			CHECK(email like '%@%.%') -- Check del formato del email
	, CONSTRAINT ck_cif				CHECK(LEN(cif) = 8) -- Check de la longitud del cif
)

CREATE TABLE Seguridad.Cargo(
	id INT PRIMARY KEY IDENTITY(1,1)
	, nombre		NVARCHAR(100)	NOT NULL
	, created_at	DATETIME		DEFAULT getdate()
	, update_at		DATETIME		NULL
	, delete_at		DATETIME		NULL -- Añadido NULL
)
GO

CREATE TABLE Seguridad.Usuario(
	idUsuario INT IDENTITY(1,1)
	, idCargo		INT
	, cif			VARCHAR(16)		NOT NULL
	, nombres		NVARCHAR(100)	NOT NULL
	, apellidos		NVARCHAR(100)	NOT NULL
	, fechaNac		DATETIME		NULL
	, pw			NVARCHAR(100)	NOT NULL
	, email			NVARCHAR(120)	NULL
	, created_at	DATETIME		DEFAULT getdate()
	, update_at		DATETIME		NULL
	, delete_at		DATETIME		NULL -- Añadido NULL

	, CONSTRAINT pk_idusuario		PRIMARY KEY(idUsuario) -- PK en constraint
	, CONSTRAINT fk_idcargo			FOREIGN KEY(idCargo) -- FK en constraint
		REFERENCES Seguridad.Cargo(id)
	, CONSTRAINT ck_email			CHECK(email like '%@%.%') -- Check para el formato del correo
	, CONSTRAINT ck_cif				CHECK(LEN(cif) >= 8) -- Check para la longitud del cif mayor a 8
)
GO
---------------------------------------------
-- TRIGGER: Validar y hashear contraseña
---------------------------------------------
CREATE TRIGGER Seguridad.trg_validar_password
ON Seguridad.Usuario
INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON

	-- Validar longitud mínima
	IF EXISTS(
		SELECT 1
		FROM inserted
		WHERE LEN(pw) < 8
	)
	BEGIN
		RAISERROR('La contraseña debe tener al menos 8 caracteres.', 16, 1)
		RETURN
	END

	-- Insertar usuario con contraseña hasheada
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
		CONVERT(NVARCHAR(100),
			HASHBYTES('SHA2_256', pw), 1),
		email,
		GETDATE(),
		update_at,
		delete_at
	FROM inserted
END
GO