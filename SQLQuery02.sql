USE UniversidadDB
GO

INSERT INTO Academico.Carrera(nombre, precio)  values(N'Ingeniería de sistemas', 1500)
GO
UPDATE Academico.Carrera set precio = 2000, update_at = getdate() where id = 1
GO
--------------------------------------
--	Comprobación de constraints
--------------------------------------

-- Precio mayor a cero
INSERT INTO Academico.Carrera(nombre, precio)  values(N'Medicina', 0)
GO
-- CIF con exactamente 8 carácteres
INSERT INTO Academico.Estudiante(cif, nombres, apellidos) values
(N'2506', N'Juan', N'López')
GO
-- Fecha correcta
INSERT INTO Academico.Estudiante(cif, nombres, apellidos, fechaNac, email) values
(N'25012736', N'Charly', N'Aguirre', '9999x99t99', 'Temp2026*')
GO
-- Verificación de Email
INSERT INTO Academico.Estudiante(cif, nombres, apellidos, fechaNac, email) values
(N'25012736', N'Charly', N'Aguirre', '2008-15-04', 'lafruchiguachipunchirequeteguay')
GO
-- CIF con 8 carácteres o más en Usuario
INSERT INTO Seguridad.Usuario(cif, nombres, apellidos, pw) values
(N'W01', N'Juan', N'López', 'Temp2026*')
GO
-- Contraseña con más de 8 carácteres
INSERT INTO Seguridad.Usuario(cif, nombres, apellidos, pw) values
(N'15234590', N'Juan', N'López', 'T')
GO

INSERT INTO Seguridad.Usuario(cif, nombres, apellidos, pw) values
(N'15234590', N'Juan', N'López', 'Temp2026*')
GO
-------------------------------
-- Prueba de relaciones
-------------------------------

INSERT INTO Academico.Estudiante (cif, nombres, apellidos, fechaNac, email, idCarrera) VALUES
	('25012736', 'Charlotte', 'Aguirre', '2008-15-04', 'charlottea1548@gmail.com', 1)
INSERT INTO Seguridad.Cargo(nombre) VALUES
	('Gerente')

UPDATE Seguridad.Usuario set idCargo = 2 -- Asignando una FK incorrecta del cargo
UPDATE Seguridad.Usuario set idCargo = 1

SELECT * FROM Academico.Carrera
SELECT * FROM Academico.Estudiante
SELECT * FROM Seguridad.Cargo
SELECT * FROM Seguridad.Usuario

