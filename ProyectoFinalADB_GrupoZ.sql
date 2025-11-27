-- =======================================================================================
-- JAIME: CREACION DE BASE DE DATOS Y TABLAS
-- =======================================================================================

CREATE DATABASE ClinicaDB;
GO

USE ClinicaDB;
GO

-- CREACION DE ESQUEMAS
CREATE SCHEMA Admision;
GO
CREATE SCHEMA Medica;
GO
CREATE SCHEMA Finanzas;
GO

-- TABLAS

CREATE TABLE Admision.Paciente (
    id_paciente INT IDENTITY(1,1) PRIMARY KEY, -- 4 bytes
    nombre VARCHAR(50) NOT NULL,				--52 bytes
    apellido VARCHAR(50) NOT NULL,				-- 52 bytes
    sexo CHAR(1) CHECK (sexo IN ('M','F')),		-- 1 byte
    fecha_nacimiento DATE NOT NULL,				-- 3 bytes
    telefono VARCHAR(20),						-- 22 bytes
    correo VARCHAR(100),						-- 102 bytes
    numero_expediente VARCHAR(20) UNIQUE		-- 22 bytes
	
	-- Fila total: 258 bytes + overhead fila 7 bytes = 265 bytes aproximadamente
	-- Registros estimados: 5000 
	-- Tamaño total tabla = Tamaño fila * Número de registros
    -- 265 * 5000 = 1,325,000 bytes = 1.26 MB aprox.
);

CREATE TABLE Medica.Medico (
    id_medico INT IDENTITY(1,1) PRIMARY KEY, -- 4 bytes
    nombre VARCHAR(50) NOT NULL,             -- 52 bytes
    apellido VARCHAR(50) NOT NULL,           -- 52 bytes
    telefono VARCHAR(20),                     -- 22 bytes
    correo VARCHAR(100)                       -- 102 bytes

    -- Fila total: 232 bytes + overhead fila 7 bytes = 239 bytes aproximadamente
    -- Registros estimados: 50
    -- Tamaño total tabla = Tamaño fila * Número de registros
    -- 239 * 50 = 11,950 bytes = 11.7 KB aprox.
);

CREATE TABLE Admision.Cita (
    id_cita INT IDENTITY(1,1) PRIMARY KEY,  -- 4 bytes
    id_paciente INT NOT NULL,               -- 4 bytes
    id_medico INT NOT NULL,                 -- 4 bytes
    fecha_cita DATE NOT NULL,               -- 3 bytes
    motivo VARCHAR(255),                    -- 257 bytes (255 + 2 overhead)
    FOREIGN KEY (id_paciente) REFERENCES Admision.Paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES Medica.Medico(id_medico)

    -- Fila total:272 bytes + overhead fila 7 bytes = 279 bytes
    -- Registros: 25,000
	-- Tamaño total tabla = Tamaño fila * Número de registros
    -- Tamaño total tabla = 279 * 25,000 = 6,975,000 bytes = 6.65 MB aprox.
);


CREATE TABLE Medica.Medicamento (
    id_medicamento INT IDENTITY(1,1) PRIMARY KEY,  -- 4 bytes
    nombre VARCHAR(100) NOT NULL,                   -- 102 bytes
    descripcion TEXT,                               -- 16 bytes (puntero) + 255 bytes promedio
    precio_unitario DECIMAL(10,2) NOT NULL,        -- 5 bytes
    dosis_unidad VARCHAR(50)                        -- 52 bytes

    -- Fila total: 434 bytes + overhead fila 7 bytes =441 bytes
    -- Registros estimados: 500
    -- Tamaño total tabla = Tamaño fila * Número de registros
    -- 441 * 500 = 220,500 bytes = 215 KB aprox.
);


CREATE TABLE Medica.Tratamiento (
    id_tratamiento INT IDENTITY(1,1) PRIMARY KEY, -- 4 bytes
    id_cita INT NOT NULL,                          -- 4 bytes
    id_medico INT NOT NULL,                        -- 4 bytes
    descripcion TEXT,                              -- 16 bytes (puntero) + 255 bytes promedio
    cantidad INT,                                  -- 4 bytes
    precio DECIMAL(10,2),                          -- 5 bytes
    FOREIGN KEY (id_cita) REFERENCES Admision.Cita(id_cita),
    FOREIGN KEY (id_medico) REFERENCES Medica.Medico(id_medico)

    -- Fila total:292 bytes + overhead fila 7 bytes = 299 bytes
    -- Registros estimados: 15,000
    -- Tamaño total tabla = Tamaño fila * Número de registros
    -- 299 * 15,000 = 4,485,000 bytes = 4.28 MB aprox.
);


CREATE TABLE Medica.Tratamiento_Medicamento (
    id_tratamiento INT NOT NULL,       -- 4 bytes
    id_medicamento INT NOT NULL,       -- 4 bytes
    dosis VARCHAR(50),                 -- 52 bytes
    cantidad INT,                      -- 4 bytes
    PRIMARY KEY (id_tratamiento, id_medicamento),
    FOREIGN KEY (id_tratamiento) REFERENCES Medica.Tratamiento(id_tratamiento),
    FOREIGN KEY (id_medicamento) REFERENCES Medica.Medicamento(id_medicamento)

    -- Fila total:  64 bytes + overhead fila 7 = 71 bytes
    -- Registros estimados: 5,000
    -- Tamaño total tabla = Tamaño fila * Número de registros
    -- 71 * 5,000 = 355,000 bytes = 346.7 KB aprox.
);


CREATE TABLE Finanzas.Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,   -- 4 bytes
    id_paciente INT NOT NULL,                    -- 4 bytes
    id_cita INT NOT NULL,                        -- 4 bytes
    fecha_factura DATE NOT NULL DEFAULT GETDATE(), -- 3 bytes
    subtotal DECIMAL(10,2) NOT NULL,            -- 5 bytes
    impuesto DECIMAL(10,2) NOT NULL,            -- 5 bytes
    monto_total AS (subtotal + impuesto) PERSISTED, -- 5 bytes
    metodo_pago VARCHAR(50),                     -- 52 bytes
    fecha_pago DATE,                             -- 3 bytes
    FOREIGN KEY (id_paciente) REFERENCES Admision.Paciente(id_paciente),
    FOREIGN KEY (id_cita) REFERENCES Admision.Cita(id_cita)

    -- Fila total: 85 bytes + overhead fila 7 = 92 bytes
    -- Registros estimados: 3,000
    -- Tamaño total tabla = Tamaño fila * Número de registros
    -- 92 * 3,000 = 276,000 bytes = 269.5 KB aprox.
);


CREATE TABLE Finanzas.Detalle_Factura (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,   -- 4 bytes
    id_factura INT NOT NULL,                     -- 4 bytes
    descripcion TEXT,                            -- 16 bytes (puntero) + 255 bytes promedio
    cantidad INT,                                -- 4 bytes
    precio_unitario DECIMAL(10,2),              -- 5 bytes
    total_item AS (cantidad * precio_unitario) PERSISTED, -- 5 bytes
    FOREIGN KEY (id_factura) REFERENCES Finanzas.Factura(id_factura)

    -- Fila total: 293 bytes + overhead fila 7 = 300 bytes
    -- Registros estimados: 4,000
    -- Tamaño total tabla = Tamaño fila * Número de registros
    -- 300 * 4,000 = 1,200,000 bytes = 1.14 MB aprox.
);



-- =======================================================================================
--  REYNALDO: INSERCION DE DATOS
-- =======================================================================================

-- 50 REGISTROS - Medica.Medico

/*
  BLOQUE 1: Insercion manual de 50 medicos
*/

INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Roberto', 'Garcia', '555-2001', 'roberto.garcia@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Laura', 'Martinez', '555-2002', 'laura.martinez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Andres', 'Lopez', '555-2003', 'andres.lopez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Sofia', 'Hernandez', '555-2004', 'sofia.hernandez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Daniel', 'Gonzalez', '555-2005', 'daniel.gonzalez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Patricia', 'Rodriguez', '555-2006', 'patricia.rodriguez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Emilio', 'Fernandez', '555-2007', 'emilio.fernandez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Claudia', 'Perez', '555-2008', 'claudia.perez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Alejandro', 'Sanchez', '555-2009', 'alejandro.sanchez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Mariana', 'Ramirez', '555-2010', 'mariana.ramirez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Francisco', 'Torres', '555-2011', 'francisco.torres@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Valeria', 'Diaz', '555-2012', 'valeria.diaz@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Ricardo', 'Vargas', '555-2013', 'ricardo.vargas@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Monica', 'Mendoza', '555-2014', 'monica.mendoza@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Fernando', 'Reyes', '555-2015', 'fernando.reyes@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Natalia', 'Castro', '555-2016', 'natalia.castro@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Guillermo', 'Jimenez', '555-2017', 'guillermo.jimenez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Ximena', 'Moreno', '555-2018', 'ximena.moreno@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Hector', 'Paz', '555-2019', 'hector.paz@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Jimena', 'Rojas', '555-2020', 'jimena.rojas@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Oscar', 'Bravo', '555-2021', 'oscar.bravo@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Elisa', 'Vidal', '555-2022', 'elisa.vidal@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Pablo', 'Silva', '555-2023', 'pablo.silva@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Irene', 'Molina', '555-2024', 'irene.molina@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Rafael', 'Cruz', '555-2025', 'rafael.cruz@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Andrea', 'Delgado', '555-2026', 'andrea.delgado@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Samuel', 'Morales', '555-2027', 'samuel.morales@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Viviana', 'Quintero', '555-2028', 'viviana.quintero@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Hugo', 'Herrera', '555-2029', 'hugo.herrera@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Veronica', 'Aguilar', '555-2030', 'veronica.aguilar@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Josue', 'Leon', '555-2031', 'josue.leon@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Brenda', 'Salazar', '555-2032', 'brenda.salazar@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Kevin', 'Rios', '555-2033', 'kevin.rios@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Cecilia', 'Montoya', '555-2034', 'cecilia.montoya@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Joel', 'Caceres', '555-2035', 'joel.caceres@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Gabriela', 'Nunez', '555-2036', 'gabriela.nunez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Ariel', 'Rubio', '555-2037', 'ariel.rubio@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Diana', 'Salgado', '555-2038', 'diana.salgado@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Blas', 'Mena', '555-2039', 'blas.mena@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Erika', 'Fuentes', '555-2040', 'erika.fuentes@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. German', 'Vega', '555-2041', 'german.vega@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Fatima', 'Pacheco', '555-2042', 'fatima.pacheco@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Israel', 'Sosa', '555-2043', 'israel.sosa@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Julieta', 'Ochoa', '555-2044', 'julieta.ochoa@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Lorenzo', 'Vazquez', '555-2045', 'lorenzo.vazquez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Nadia', 'Chavez', '555-2046', 'nadia.chavez@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Omar', 'Tapia', '555-2047', 'omar.tapia@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Pamela', 'Santos', '555-2048', 'pamela.santos@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dr. Ulises', 'Ramos', '555-2049', 'ulises.ramos@clinicadb.com');
INSERT INTO Medica.Medico (nombre, apellido, telefono, correo) VALUES ('Dra. Yaneth', 'Tovar', '555-2050', 'yaneth.tovar@clinicadb.com');

-- 5,000 REGISTROS - Admision.Paciente

/*
  BLOQUE 1: Creacion y Llenado de la Tabla Temporal de Nombres
*/

-- 1.1 Eliminar la tabla temporal si ya existe para asegurar un inicio limpio
IF OBJECT_ID('tempdb..#NombresBase') IS NOT NULL 
    DROP TABLE #NombresBase;

-- 1.2 Crear la tabla temporal para almacenar nombres de pila y su sexo
CREATE TABLE #NombresBase (
    nombre VARCHAR(50), 
    sexo CHAR(1) -- 'M' para Masculino, 'F' para Femenino
);

-- 1.3 Insertar 100 nombres base (50 hombres, 50 mujeres)
INSERT INTO #NombresBase (nombre, sexo) VALUES 
('Juan', 'M'), ('Maria', 'F'), ('Carlos', 'M'), ('Ana', 'F'), ('Pedro', 'M'), ('Sofia', 'F'), ('Luis', 'M'), ('Elena', 'F'), ('Miguel', 'M'), ('Laura', 'F'),
('Javier', 'M'), ('Andrea', 'F'), ('David', 'M'), ('Monica', 'F'), ('Fernando', 'M'), ('Natalia', 'F'), ('Ricardo', 'M'), ('Valeria', 'F'), ('Pablo', 'M'), ('Daniela', 'F'),
('Alejandro', 'M'), ('Jessica', 'F'), ('Gabriel', 'M'), ('Paula', 'F'), ('Hector', 'M'), ('Ximena', 'F'), ('Ivan', 'M'), ('Lucia', 'F'), ('Oscar', 'M'), ('Camila', 'F'),
('Raul', 'M'), ('Veronica', 'F'), ('Manuel', 'M'), ('Adriana', 'F'), ('Jorge', 'M'), ('Estela', 'F'), ('Felipe', 'M'), ('Silvia', 'F'), ('Benjamin', 'M'), ('Diana', 'F'),
('Guillermo', 'M'), ('Rosa', 'F'), ('Hugo', 'M'), ('Tania', 'F'), ('Sebastian', 'M'), ('Marisol', 'F'), ('Mario', 'M'), ('Irene', 'F'), ('Arturo', 'M'), ('Gloria', 'F'),
('Cesar', 'M'), ('Margarita', 'F'), ('Omar', 'M'), ('Beatriz', 'F'), ('Angel', 'M'), ('Julia', 'F'), ('Ruben', 'M'), ('Victoria', 'F'), ('Jose', 'M'), ('Karla', 'F'),
('Enrique', 'M'), ('Lourdes', 'F'), ('Gerardo', 'M'), ('Fabiola', 'F'), ('Eduardo', 'M'), ('Cecilia', 'F'), ('Gustavo', 'M'), ('Leticia', 'F'), ('Adolfo', 'M'), ('Marcia', 'F'),
('Israel', 'M'), ('Brenda', 'F'), ('Joaquin', 'M'), ('Gisela', 'F'), ('Marcos', 'M'), ('Patricio', 'F'), ('Nicolas', 'M'), ('Yolanda', 'F'), ('Simon', 'M'), ('Elisa', 'F'),
('Vicente', 'M'), ('Alma', 'F'), ('Alfredo', 'M'), ('Jimena', 'F'), ('Ernesto', 'M'), ('Doris', 'F'), ('Saul', 'M'), ('Graciela', 'F'), ('Roberto', 'M'), ('Judith', 'F'),
('Antonio', 'M'), ('Nadia', 'F'), ('Armando', 'M'), ('Clara', 'F'), ('Elias', 'M'), ('Eva', 'F'), ('Federico', 'M'), ('Alicia', 'F'), ('Gonzalo', 'M'), ('Sara', 'F');


/*
  BLOQUE 2: Creacion y Llenado de la Tabla Temporal de Apellidos
*/

-- 2.1 Eliminar la tabla temporal si ya existe
IF OBJECT_ID('tempdb..#ApellidosBase') IS NOT NULL 
    DROP TABLE #ApellidosBase;

-- 2.2 Crear la tabla temporal para almacenar apellidos
CREATE TABLE #ApellidosBase (
    apellido VARCHAR(50)
);

-- 2.3 Insertar 100 apellidos base
INSERT INTO #ApellidosBase (apellido) VALUES 
('Perez'), ('Gomez'), ('Rodriguez'), ('Lopez'), ('Martinez'), ('Sanchez'), ('Ramirez'), ('Flores'), ('Diaz'), ('Vasquez'),
('Ruiz'), ('Morales'), ('Jimenez'), ('Castro'), ('Ortiz'), ('Rojas'), ('Guerrero'), ('Mendoza'), ('Silva'), ('Acuna'),
('Torres'), ('Chavez'), ('Nunez'), ('Reyes'), ('Vargas'), ('Caceres'), ('Leon'), ('Mora'), ('Blanco'), ('Soto'),
('Cruz'), ('Rios'), ('Montoya'), ('Salgado'), ('Tapia'), ('Ochoa'), ('Ramos'), ('Delgado'), ('Miranda'), ('Herrera'),
('Paz'), ('Vidal'), ('Molina'), ('Cruz'), ('Aguilar'), ('Leon'), ('Salazar'), ('Mena'), ('Fuentes'), ('Vega'),
('Pacheco'), ('Sosa'), ('Chavez'), ('Toro'), ('Lara'), ('Solis'), ('Valdez'), ('Mendez'), ('Quintero'), ('Alvarado'),
('Navarro'), ('Zuniga'), ('Arias'), ('Bello'), ('Cano'), ('Duarte'), ('Estevez'), ('Fajardo'), ('Guzman'), ('Hidalgo'),
('Ibarra'), ('Jara'), ('Kreuz'), ('Lagos'), ('Nava'), ('Orozco'), ('Pardo'), ('Quiros'), ('Rueda'), ('Sanz'),
('Trujillo'), ('Urbina'), ('Viera'), ('Wong'), ('Ximenes'), ('Yanez'), ('Zamora'), ('Abarca'), ('Bolanos'), ('Cisneros'),
('Duran'), ('Elizondo'), ('Fonseca'), ('Godinez'), ('Hurtado'), ('Iglesias'), ('Jaen'), ('Kattan'), ('Nieto'), ('Orellana');

/*
  BLOQUE 3: Generacion de Datos Aleatorios e Insercion
*/

-- 3.1 Declarar una variable para definir el numero total de registros a insertar (5000)
DECLARE @total_a_insertar INT = 5000;

-- 3.2 Crear una Expresion de Tabla Comun (CTE) para combinar nombres y apellidos
WITH NombresCompletos AS (
    SELECT 
        N.nombre, 
        N.sexo,
        A.apellido,
        -- Asignar un ID de fila aleatorio para poder seleccionar una muestra aleatoria
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS FilaID 
    FROM 
        #NombresBase N
    -- Genera el producto cartesiano (100 nombres * 100 apellidos = 10,000 combinaciones)
    CROSS JOIN 
        #ApellidosBase A
)
-- 3.3 Insertar los datos generados en la tabla de destino 'Paciente'
INSERT INTO Admision.Paciente (nombre, apellido, sexo, fecha_nacimiento, telefono, correo, numero_expediente)
-- Selecciona la cantidad de filas definida en la variable @total_a_insertar
SELECT TOP (@total_a_insertar)
    NC.nombre,
    NC.apellido,
    NC.sexo,
    -- Generar una fecha de nacimiento aleatoria entre 1950 y 2005 (aprox. 55 anos de rango)
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % (365 * 55), '1950-01-01') AS fecha_nacimiento,
    -- Generar un numero de telefono ficticio con prefijo '555-'
    '555-' + RIGHT('0000' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR(4)), 4) AS telefono,
    -- Generar una direccion de correo electronico aleatoria unica
    LOWER(REPLACE(NC.nombre, '.', '') + '.' + NC.apellido + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS VARCHAR(4)) + '@clinica.com') AS correo,
    -- Generar un numero de expediente formateado (ej: EXP00001)
    'EXP' + RIGHT('00000' + CAST(NC.FilaID AS VARCHAR(5)), 5) AS numero_expediente
FROM 
    NombresCompletos NC
-- Asegura que las 5000 filas seleccionadas sean una muestra completamente aleatoria de las 10,000 combinaciones
ORDER BY 
    NEWID();

/*
  BLOQUE 4: Limpieza y Confirmacion
*/

-- 4.1 Limpiar tablas temporales para liberar recursos
DROP TABLE #NombresBase;
DROP TABLE #ApellidosBase;

-- 4.2 Consulta de verificacion: confirmar cuantos registros fueron insertados
SELECT COUNT(*) AS TotalPacientesInsertados 
FROM Admision.Paciente;


-- 500 REGISTROS - Medica.Medicamento

/*
  BLOQUE 1: Preparacion: Creacion y Llenado de una Tabla de Numeros (Tally Table)
*/

-- 1.1. Eliminar la tabla temporal de numeros si ya existe.
IF OBJECT_ID('tempdb..#MedicamentosNums') IS NOT NULL 
    DROP TABLE #MedicamentosNums;

-- 1.2. Crear la tabla temporal que almacenara una secuencia de numeros enteros.
CREATE TABLE #MedicamentosNums (
    N INT PRIMARY KEY -- La columna 'N' almacenara la secuencia de numeros (1, 2, 3, ...)
);

-- 1.3. Declarar variables para controlar el bucle y la cantidad de registros.
DECLARE @i INT = 1; -- Variable contador, comienza en 1.
DECLARE @total_a_insertar_med INT = 500; -- Define cuantos registros (medicamentos) se crearan.

-- 1.4. Bucle para llenar la tabla #MedicamentosNums con numeros del 1 al 500.
WHILE @i <= @total_a_insertar_med
BEGIN
    -- Insertar el valor actual de @i en la tabla.
    INSERT INTO #MedicamentosNums (N) VALUES (@i); 
    -- Incrementar el contador.
    SET @i = @i + 1; 
END;

/*
  BLOQUE 2: Insercion de Datos Generados en la Tabla 'Medicamento'
*/

-- 2.1. Iniciar la instruccion de insercion en la tabla de destino 'Medicamento'.
INSERT INTO Medica.Medicamento (nombre, descripcion, precio_unitario, dosis_unidad)
SELECT 
    -- 2.2. Generacion del campo NOMBRE (Combinacion de Prefijo + Dosis + Sufijo)

    -- Seleccion del Prefijo (se basa en el numero de fila 'N' para una distribucion semi-aleatoria)
    CASE (N * 3) % 10 
        WHEN 0 THEN 'AnalgeX' WHEN 1 THEN 'NeuroCalm' WHEN 2 THEN 'Vitamax' 
        WHEN 3 THEN 'Cefalex' WHEN 4 THEN 'GastroFast' WHEN 5 THEN 'BroncoRex' 
        WHEN 6 THEN 'Cardio' WHEN 7 THEN 'Hemo' WHEN 8 THEN 'DermiSol' 
        ELSE 'Fluvi'
    END 
    
    -- Insercion de Dosis (ej: 10 + N*5, crea dosis incrementales)
    + CAST(10 + (N * 5) AS VARCHAR(4)) + 'mg' 
    
    + ' ' +
    -- Seleccion del Sufijo (aleatorio usando CHECKSUM(NEWID()) )
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Forte' WHEN 1 THEN 'Plus' WHEN 2 THEN 'Rx' WHEN 3 THEN 'Duo' ELSE 'Simple'
    END AS nombre,
    
    -- 2.3. Generacion del campo DESCRIPCION (aleatoria)
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Alivio eficaz del dolor y la fiebre.'
        WHEN 1 THEN 'Formula avanzada para el control de la presion arterial.'
        WHEN 2 THEN 'Tratamiento de amplio espectro contra infecciones.'
        WHEN 3 THEN 'Suplemento esencial para el sistema inmunologico.'
        ELSE 'Accion rapida para problemas gastrointestinales.'
    END AS descripcion,
    
    -- 2.4. Generacion del campo PRECIO_UNITARIO (aleatorio entre 1.00 y 50.00)
    -- Genera un numero aleatorio entre 0 y 4900, lo divide por 100.0 y le suma 1.00.
    CAST(1.00 + (ABS(CHECKSUM(NEWID())) % 4900) / 100.0 AS DECIMAL(10, 2)) AS precio_unitario,
    
    -- 2.5. Generacion del campo DOSIS_UNIDAD (aleatoria)
    CASE ABS(CHECKSUM(NEWID())) % 4
        WHEN 0 THEN 'Tableta'
        WHEN 1 THEN 'Capsula'
        WHEN 2 THEN 'Inyeccion'
        ELSE 'Gotas'
    END AS dosis_unidad
FROM 
    #MedicamentosNums; -- Se utiliza la tabla de numeros como fuente de datos.

/*
  BLOQUE 3: Limpieza y Confirmacion
*/

-- 3.1. Eliminar la tabla de numeros temporal para liberar recursos.
DROP TABLE #MedicamentosNums;

-- 3.2. Consulta de verificacion: confirmar cuantos registros fueron insertados.
SELECT COUNT(*) AS TotalMedicamentosInsertados 
FROM Medica.Medicamento;


-- 25,000 REGISTROS - Admision.Cita

/*
  BLOQUE 1: Declaracion de Variables
*/

-- Define la cantidad total de citas a insertar (25,000 registros).
DECLARE @total_a_insertar_citas INT = 25000; 
-- Define el rango maximo de IDs de Pacientes existentes (ej: 1 a 5000).
DECLARE @max_pacientes INT = 5000;      
-- Define el rango maximo de IDs de Medicos existentes (ej: 1 a 50).
DECLARE @max_medicos INT = 50;          
-- Define el rango de dias para la fecha de la cita (1825 dias = 5 anos).
DECLARE @rango_dias INT = 1825;

/*
  BLOQUE 2: Creacion y Llenado de una Tabla de Numeros (Tally Table)
*/

-- 2.1. Eliminar la tabla temporal de numeros si ya existe para un inicio limpio.
IF OBJECT_ID('tempdb..#CitasNums') IS NOT NULL 
    DROP TABLE #CitasNums;

-- 2.2. Crear la tabla temporal que almacenara una secuencia de numeros enteros (1 a 25000).
CREATE TABLE #CitasNums (
    N INT PRIMARY KEY 
);

-- 2.3. Inicializar el contador para el bucle.
DECLARE @i_citas INT = 1;

-- 2.4. Bucle para llenar la tabla #CitasNums con numeros hasta alcanzar @total_a_insertar_citas.
WHILE @i_citas <= @total_a_insertar_citas
BEGIN
    INSERT INTO #CitasNums (N) VALUES (@i_citas); 
    SET @i_citas = @i_citas + 1; 
END;

/*
  BLOQUE 3: Insercion Masiva en la Tabla 'Cita'
*/

-- 3.1. Iniciar la insercion de las 25,000 citas.
INSERT INTO Admision.Cita (id_paciente, id_medico, fecha_cita, motivo)
SELECT 
    -- 3.2. Generar id_paciente aleatorio: 
    -- (Numero aleatorio % 5000) + 1. Asegura un ID entre 1 y 5000.
    (ABS(CHECKSUM(NEWID())) % @max_pacientes) + 1 AS id_paciente,
    
    -- 3.3. Generar id_medico aleatorio: 
    -- (Numero aleatorio % 50) + 1. Asegura un ID entre 1 y 50.
    (ABS(CHECKSUM(NEWID())) % @max_medicos) + 1 AS id_medico,
    
    -- 3.4. Generar fecha_cita aleatoria: 
    DATEADD(DAY, 
            -- Anade un numero aleatorio de dias (entre 0 y 1824)
            (ABS(CHECKSUM(NEWID())) % @rango_dias), 
            -- a una fecha base que es 5 anos antes de hoy.
            DATEADD(YEAR, -5, GETDATE())
    ) AS fecha_cita,
    
    -- 3.5. Generar motivo de la cita: 
    -- Utiliza el modulo del numero de fila (N) para distribuir los motivos de forma ciclica.
    CASE (N % 8)
        WHEN 0 THEN 'Consulta General' 
        WHEN 1 THEN 'Revision Periodica' 
        WHEN 2 THEN 'Control de Enfermedad Cronica' 
        WHEN 3 THEN 'Examen de Laboratorio' 
        WHEN 4 THEN 'Cita de Especialidad'
        WHEN 5 THEN 'Vacunacion'
        WHEN 6 THEN 'Control Post-operatorio'
        ELSE 'Chequeo Preventivo'
    END AS motivo
FROM 
    #CitasNums
ORDER BY N; 

/*
  BLOQUE 4: Limpieza y Confirmacion
*/

-- 4.1. Eliminar la tabla de numeros temporal.
DROP TABLE #CitasNums;

-- 4.2. Consulta de verificacion: confirmar cuantos registros fueron insertados.
SELECT COUNT(*) AS TotalCitasInsertadas 
FROM Admision.Cita;


-- 15,000 REGISTROS - Medica.Tratamiento

/*
  BLOQUE 1: Declaracion de Variables y Obtencion de Rangos
*/

-- Define la cantidad total de tratamientos a insertar (15,000 registros).
DECLARE @total_a_insertar_trat INT = 15000;

-- Obtiene el ID mas alto de la tabla 'Cita' para definir el rango aleatorio.
DECLARE @max_citas_trat INT = (SELECT MAX(id_cita) FROM Admision.Cita);      
-- Obtiene el ID mas alto de la tabla 'Medico' para definir el rango aleatorio.
DECLARE @max_medicos_trat INT = (SELECT MAX(id_medico) FROM Medica.Medico);     

/*
  BLOQUE 2: Validacion de la Dependencia
*/

IF @max_citas_trat IS NULL OR @max_citas_trat = 0
BEGIN
    PRINT 'ERROR: La tabla Cita esta vacia. Por favor, inserte las 25,000 citas primero.';
END
ELSE
BEGIN
    /*
      BLOQUE 3: Creacion y Llenado de una Tabla de Numeros
    */

    IF OBJECT_ID('tempdb..#TratamientoNums') IS NOT NULL 
        DROP TABLE #TratamientoNums;

    CREATE TABLE #TratamientoNums (N INT PRIMARY KEY);
    DECLARE @i_trat INT = 1;

    WHILE @i_trat <= @total_a_insertar_trat
    BEGIN
        INSERT INTO #TratamientoNums (N) VALUES (@i_trat); 
        SET @i_trat = @i_trat + 1; 
    END;

    /*
      BLOQUE 4: Insercion Masiva en la Tabla 'Tratamiento'
    */

    INSERT INTO Medica.Tratamiento (id_cita, id_medico, descripcion, cantidad, precio)
    SELECT 
        (ABS(CHECKSUM(NEWID())) % @max_citas_trat) + 1 AS id_cita,
        (ABS(CHECKSUM(NEWID())) % @max_medicos_trat) + 1 AS id_medico,
        CASE (N % 10)
            WHEN 0 THEN 'Prescripcion de antibioticos y seguimiento en 7 dias.' 
            WHEN 1 THEN 'Terapia fisica semanal, duracion 6 semanas.' 
            WHEN 2 THEN 'Intervencion quirurgica menor ambulatoria.' 
            WHEN 3 THEN 'Dieta y programa de ejercicios personalizado.' 
            WHEN 4 THEN 'Analisis de sangre completo y perfil hormonal.'
            WHEN 5 THEN 'Sesion de acupuntura para manejo del dolor cronico.'
            WHEN 6 THEN 'Sutura de herida superficial y curacion diaria.'
            WHEN 7 THEN 'Tratamiento con nebulizaciones y control respiratorio.'
            WHEN 8 THEN 'Administracion de vacuna especifica.'
            ELSE 'Consulta de reevaluacion y ajuste de medicacion.'
        END AS descripcion,
        (ABS(CHECKSUM(NEWID())) % 10) + 1 AS cantidad,
        CAST(50.00 + (ABS(CHECKSUM(NEWID())) % 45000) / 100.0 AS DECIMAL(10, 2)) AS precio
    FROM 
        #TratamientoNums
    ORDER BY N; 

    /*
      BLOQUE 5: Limpieza y Confirmacion
    */
    DROP TABLE #TratamientoNums;
    SELECT COUNT(*) AS TotalTratamientosInsertados FROM Medica.Tratamiento;
END


-- 3,000 REGISTROS - Finanzas.Factura

/*
  BLOQUE 1: Declaracion de Variables y Obtencion de Rangos
*/

DECLARE @total_a_insertar_fact INT = 3000;
DECLARE @max_citas_fact INT = (SELECT MAX(id_cita) FROM Admision.Cita);           
DECLARE @max_pacientes_fact INT = (SELECT MAX(id_paciente) FROM Admision.Paciente);  
DECLARE @tasa_impuesto DECIMAL(4, 2) = 0.15; 

/*
  BLOQUE 2: Validacion de Dependencias
*/

IF @max_citas_fact IS NULL OR @max_citas_fact = 0 OR @max_pacientes_fact IS NULL OR @max_pacientes_fact = 0
BEGIN
    PRINT 'ERROR: Las tablas Cita o Paciente estan vacias. Por favor, inserte datos validos primero.';
END
ELSE
BEGIN
    /*
      BLOQUE 3: Creacion y Llenado de una Tabla de Numeros
    */
    IF OBJECT_ID('tempdb..#FacturaNums') IS NOT NULL 
        DROP TABLE #FacturaNums;

    CREATE TABLE #FacturaNums (N INT PRIMARY KEY);
    DECLARE @i_fact INT = 1;

    WHILE @i_fact <= @total_a_insertar_fact
    BEGIN
        INSERT INTO #FacturaNums (N) VALUES (@i_fact); 
        SET @i_fact = @i_fact + 1; 
    END;

    /*
      BLOQUE 4: Insercion Masiva en la Tabla 'Factura'
    */
    INSERT INTO Finanzas.Factura (id_paciente, id_cita, fecha_factura, subtotal, impuesto, metodo_pago, fecha_pago)
    SELECT 
        (ABS(CHECKSUM(NEWID())) % @max_pacientes_fact) + 1 AS id_paciente,
        (ABS(CHECKSUM(NEWID())) % @max_citas_fact) + 1 AS id_cita,
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 730), GETDATE()) AS fecha_factura,
        CAST(50.00 + (ABS(CHECKSUM(NEWID())) % 95000) / 100.0 AS DECIMAL(10, 2)) AS subtotal,
        CAST((50.00 + (ABS(CHECKSUM(NEWID())) % 95000) / 100.0) * @tasa_impuesto AS DECIMAL(10, 2)) AS impuesto,
        CASE ABS(CHECKSUM(NEWID())) % 10
            WHEN 0 THEN NULL -- 10% de probabilidad de ser NULL (pendiente)
            ELSE CASE (N % 4)
                WHEN 0 THEN 'Tarjeta de Credito' 
                WHEN 1 THEN 'Transferencia Bancaria' 
                WHEN 2 THEN 'Efectivo' 
                ELSE 'Seguro Medico'
            END
        END AS metodo_pago,
        CASE ABS(CHECKSUM(NEWID())) % 10
            WHEN 0 THEN NULL -- 10% de probabilidad de ser NULL (no pagada)
            ELSE DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 30), GETDATE()) 
        END AS fecha_pago
    FROM 
        #FacturaNums
    ORDER BY N; 

    /*
      BLOQUE 5: Limpieza y Confirmacion
    */
    DROP TABLE #FacturaNums;
    SELECT COUNT(*) AS TotalFacturasInsertadas FROM Finanzas.Factura;
END


-- 5,000 REGISTROS - Medica.Tratamiento.Medicamento

/*
  BLOQUE 1: Declaracion de Variables y Obtencion de Rangos
*/

DECLARE @total_a_insertar_tm INT = 5000;
DECLARE @max_tratamientos INT = (SELECT MAX(id_tratamiento) FROM Medica.Tratamiento);
DECLARE @max_medicamentos INT = (SELECT MAX(id_medicamento) FROM Medica.Medicamento);

/*
  BLOQUE 2: Validacion de Dependencias
*/

IF @max_tratamientos IS NULL OR @max_tratamientos = 0 OR @max_medicamentos IS NULL OR @max_medicamentos = 0
BEGIN
    PRINT 'ERROR: Las tablas Tratamiento o Medicamento estan vacias. Por favor, asegurese de que tengan datos validos.';
END
ELSE
BEGIN
    /*
      BLOQUE 3: Generacion en Tabla Temporal (Staging)
    */
    IF OBJECT_ID('tempdb..#TempTratamientoMed') IS NOT NULL 
        DROP TABLE #TempTratamientoMed;

    -- Creamos una tabla temporal para guardar los datos "brutos"
    CREATE TABLE #TempTratamientoMed (
        id_tratamiento INT,
        id_medicamento INT,
        dosis VARCHAR(50),
        cantidad INT
    );

    -- Usamos una tabla de numeros al vuelo para generar 6000 candidatos (un poco mas de lo necesario para compensar duplicados)
    ;WITH Tally AS (
        SELECT TOP (6000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
        FROM sys.all_columns a CROSS JOIN sys.all_columns b
    )
    INSERT INTO #TempTratamientoMed (id_tratamiento, id_medicamento, dosis, cantidad)
    SELECT 
        (ABS(CHECKSUM(NEWID())) % @max_tratamientos) + 1,
        (ABS(CHECKSUM(NEWID())) % @max_medicamentos) + 1,
        CASE (N % 5)
            WHEN 0 THEN '1 tableta cada 8 horas' 
            WHEN 1 THEN '1 capsula por la noche' 
            WHEN 2 THEN '20 mg al dia' 
            WHEN 3 THEN 'Aplicacion topica' 
            ELSE 'Segun criterio medico'
        END,
        (ABS(CHECKSUM(NEWID())) % 5) + 1
    FROM Tally;

    /*
      BLOQUE 4: Insercion Masiva SIN DUPLICADOS
    */
    -- Usamos DISTINCT o GROUP BY para asegurar que el par (id_tratamiento, id_medicamento) sea unico
    INSERT INTO Medica.Tratamiento_Medicamento (id_tratamiento, id_medicamento, dosis, cantidad)
    SELECT DISTINCT TOP (@total_a_insertar_tm) -- Seleccionamos solo los unicos hasta llegar a 5000
        id_tratamiento,
        id_medicamento,
        MAX(dosis) as dosis, -- Si hay duplicados, tomamos cualquiera (el maximo)
        MAX(cantidad) as cantidad
    FROM 
        #TempTratamientoMed
    GROUP BY 
        id_tratamiento, id_medicamento
    ORDER BY 
        id_tratamiento, id_medicamento;

    /*
      BLOQUE 5: Limpieza y Confirmacion
    */
    DROP TABLE #TempTratamientoMed;
    SELECT COUNT(*) AS TotalTratamientoMedicamentoInsertados FROM Medica.Tratamiento_Medicamento;
END
GO


-- 4,000 REGISTROS - Finanzas.Detalle_Factura

/*
  BLOQUE 1: Declaracion de Variables y Obtencion de Rangos
*/

DECLARE @total_a_insertar_det INT = 4000;
DECLARE @max_facturas_det INT = (SELECT MAX(id_factura) FROM Finanzas.Factura);

/*
  BLOQUE 2: Validacion de Dependencia
*/

IF @max_facturas_det IS NULL OR @max_facturas_det = 0
BEGIN
    PRINT 'ERROR: La tabla Factura esta vacia. Por favor, asegurese de que tenga datos validos primero.';
END
ELSE
BEGIN
    /*
      BLOQUE 3: Creacion y Llenado de una Tabla de Numeros
    */
    IF OBJECT_ID('tempdb..#DetalleNums') IS NOT NULL 
        DROP TABLE #DetalleNums;

    CREATE TABLE #DetalleNums (N INT PRIMARY KEY);
    DECLARE @i_det INT = 1;

    WHILE @i_det <= @total_a_insertar_det
    BEGIN
        INSERT INTO #DetalleNums (N) VALUES (@i_det); 
        SET @i_det = @i_det + 1; 
    END;

    /*
      BLOQUE 4: Insercion Masiva en la Tabla 'Detalle_Factura'
    */
    INSERT INTO Finanzas.Detalle_Factura (id_factura, descripcion, cantidad, precio_unitario)
    SELECT 
        (ABS(CHECKSUM(NEWID())) % @max_facturas_det) + 1 AS id_factura,
        CASE (N % 5)
            WHEN 0 THEN 'Consulta medica general - Servicio ID: ' + CAST(N AS VARCHAR(5))
            WHEN 1 THEN 'Analisis de laboratorio completo - Estudio ID: ' + CAST(N AS VARCHAR(5))
            WHEN 2 THEN 'Dosis de medicamento (segun prescripcion) - Item ID: ' + CAST(N AS VARCHAR(5))
            WHEN 3 THEN 'Servicios de curacion y enfermeria - Paquete ID: ' + CAST(N AS VARCHAR(5))
            ELSE 'Costo por uso de sala de procedimientos - Uso ID: ' + CAST(N AS VARCHAR(5))
        END AS descripcion,
        (ABS(CHECKSUM(NEWID())) % 5) + 1 AS cantidad,
        CAST(10.00 + (ABS(CHECKSUM(NEWID())) % 49000) / 100.0 AS DECIMAL(10, 2)) AS precio_unitario
    FROM 
        #DetalleNums
    ORDER BY N; 

    /*
      BLOQUE 5: Limpieza y Confirmacion
    */
    DROP TABLE #DetalleNums;
    SELECT COUNT(*) AS TotalDetalleFacturaInsertado FROM Finanzas.Detalle_Factura;
END


-- =======================================================================================
--  JULISSA: LOGIN, USUARIOS Y ROLES
-- =======================================================================================

USE master;
GO

-- Logins
CREATE LOGIN admin_clinica WITH PASSWORD = 'Admin#2025', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
CREATE LOGIN medico_user WITH PASSWORD = 'Medico#2025', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
CREATE LOGIN recepcion_user WITH PASSWORD = 'Recep#2025', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
CREATE LOGIN facturacion_user WITH PASSWORD = 'Factura#2025', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
CREATE LOGIN consulta_user WITH PASSWORD = 'Consulta#2025', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
CREATE LOGIN catedratico_clinica WITH PASSWORD = 'Catedra#2025', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
GO

USE ClinicaDB;
GO

-- Usuarios
CREATE USER admin_clinica FOR LOGIN admin_clinica;
CREATE USER medico_user FOR LOGIN medico_user;
CREATE USER recepcion_user FOR LOGIN recepcion_user;
CREATE USER facturacion_user FOR LOGIN facturacion_user;
CREATE USER consulta_user FOR LOGIN consulta_user;
CREATE USER catedratico_clinica FOR LOGIN catedratico_clinica;
GO

-- Roles
CREATE ROLE AdministradorDB AUTHORIZATION dbo;
CREATE ROLE MedicoRole;
CREATE ROLE RecepcionistaRole;
CREATE ROLE FacturacionRole;
CREATE ROLE ConsultaRole;
CREATE ROLE CatedraticoRole;
GO

-- Asignacion de Roles
ALTER ROLE AdministradorDB ADD MEMBER admin_clinica;
ALTER ROLE MedicoRole ADD MEMBER medico_user;
ALTER ROLE RecepcionistaRole ADD MEMBER recepcion_user;
ALTER ROLE FacturacionRole ADD MEMBER facturacion_user;
ALTER ROLE ConsultaRole ADD MEMBER consulta_user;
ALTER ROLE CatedraticoRole ADD MEMBER catedratico_clinica;
GO

-- Permisos
-- ADMINISTRADOR
GRANT CONTROL ON DATABASE::ClinicaDB TO AdministradorDB;
GO
-- MEDICO
GRANT SELECT, INSERT, UPDATE ON Admision.Paciente TO MedicoRole;
GRANT SELECT, INSERT, UPDATE ON Admision.Cita TO MedicoRole;
GRANT SELECT, INSERT, UPDATE ON Medica.Tratamiento TO MedicoRole;
GRANT SELECT ON Medica.Medicamento TO MedicoRole;
GO
-- RECEPCIONISTA
GRANT SELECT, INSERT ON Admision.Paciente TO RecepcionistaRole;
GRANT SELECT, INSERT ON Admision.Cita TO RecepcionistaRole;
GO
-- FACTURACION
GRANT SELECT, INSERT, UPDATE ON Finanzas.Factura TO FacturacionRole;
GRANT SELECT, INSERT, UPDATE ON Finanzas.Detalle_Factura TO FacturacionRole;
GO
-- CONSULTA
GRANT SELECT ON DATABASE::ClinicaDB TO ConsultaRole;
GO
-- CATEDRATICO
GRANT SELECT ON DATABASE::ClinicaDB TO CatedraticoRole;
GRANT VIEW DEFINITION ON DATABASE::ClinicaDB TO CatedraticoRole;
GRANT EXECUTE TO CatedraticoRole;
GO

-- Verificacion
SELECT 
    dp.name AS Usuario, 
    dp.type_desc AS Tipo, 
    rl.name AS Rol
FROM sys.database_role_members drm
JOIN sys.database_principals rl ON drm.role_principal_id = rl.principal_id
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
ORDER BY rl.name;
GO


-- =======================================================================================
--  XOCHIL: FUNCIONES VENTANA E INDICES
-- =======================================================================================

-- INDICES

USE ClinicaDB;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- 1 Citas por medico
CREATE NONCLUSTERED INDEX IX_Cita_Medico ON Admision.Cita(id_medico);

-- 2 Citas por paciente y fecha
CREATE NONCLUSTERED INDEX IX_Cita_Paciente_Fecha ON Admision.Cita(id_paciente, fecha_cita);

-- 3 Filtro de citas por fecha
CREATE NONCLUSTERED INDEX IX_Cita_Fecha ON Admision.Cita(fecha_cita);

-- 4 Facturas por fecha y paciente
CREATE NONCLUSTERED INDEX IX_Factura_Fecha_Pac ON Finanzas.Factura(fecha_factura, id_paciente);

-- 5 Medicamentos mas usados
CREATE NONCLUSTERED INDEX IX_TM_Medicamento ON Medica.Tratamiento_Medicamento(id_medicamento);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

EXEC sp_helpindex 'Admision.Cita';
EXEC sp_helpindex 'Finanzas.Factura';
EXEC sp_helpindex 'Medica.Tratamiento_Medicamento';
EXEC sp_helpindex 'Admision.Paciente';
EXEC sp_helpindex 'Medica.Medico';
GO

--FUNCIONES VENTANA

USE ClinicaDB;
GO

-- 1 Ranking de medicos / Obtener los 5 medicos con mas citas 
WITH RankingMedicos AS (
  SELECT 
      m.id_medico AS ID,
      m.nombre AS Nombre,
      COUNT(c.id_cita) AS [Total de Citas],
      RANK() OVER (ORDER BY COUNT(c.id_cita) DESC) AS Ranking_Medicos
  FROM Medica.Medico m
  JOIN Admision.Cita c ON m.id_medico = c.id_medico
  GROUP BY m.id_medico, m.nombre
)
SELECT *
FROM RankingMedicos
WHERE Ranking_Medicos <= 5;

-- 2 Diferencia entre citas por paciente 
WITH DiferenciaCitas AS (
    SELECT 
        id_paciente AS [ID Paciente],
        fecha_cita AS [Fecha de Cita],
        LAG(fecha_cita) OVER (PARTITION BY id_paciente ORDER BY fecha_cita) AS Cita_Anterior,
        DATEDIFF(DAY, LAG(fecha_cita) OVER (PARTITION BY id_paciente ORDER BY fecha_cita), fecha_cita) AS [Dias entre citas]
    FROM Admision.Cita
)
SELECT *
FROM DiferenciaCitas
WHERE Cita_Anterior IS NOT NULL
ORDER BY [ID Paciente], [Fecha de Cita];

-- 3 Top 5 medicamentos mas usados
WITH MedicamentosUso AS (
    SELECT 
        m.id_medicamento AS [ID Medicamento],
        m.nombre AS [Nombre],
        COUNT(tm.id_tratamiento) AS [Veces Usado]
    FROM Medica.Medicamento m
    JOIN Medica.Tratamiento_Medicamento tm ON m.id_medicamento = tm.id_medicamento
    GROUP BY m.id_medicamento, m.nombre
)
SELECT TOP 5
    [ID Medicamento],
    [Nombre],
    [Veces Usado],
    ROW_NUMBER() OVER (ORDER BY [Veces Usado] DESC) AS [Ranking Medicamentos]
FROM MedicamentosUso
ORDER BY [Veces Usado] DESC;

-- 4 Top 3 pacientes con mayor num de citas
WITH CitasPaciente AS (
    SELECT
        c.id_paciente AS [ID Paciente],
        p.nombre AS [Nombre Paciente],
        COUNT(*) OVER (PARTITION BY c.id_paciente) AS [Total Citas],
        ROW_NUMBER() OVER (PARTITION BY c.id_paciente ORDER BY c.fecha_cita DESC) AS rn_fecha
    FROM Admision.Cita c
    JOIN Admision.Paciente p ON c.id_paciente = p.id_paciente
)
, RankingPacientes AS (
    SELECT DISTINCT
        [ID Paciente],
        [Nombre Paciente],
        [Total Citas]
    FROM CitasPaciente
)
, TopPacientes AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY [Total Citas] DESC) AS Ranking
    FROM RankingPacientes
)
SELECT [ID Paciente], [Nombre Paciente], [Total Citas], Ranking
FROM TopPacientes
WHERE Ranking <= 3
ORDER BY Ranking;


-- =======================================================================================
--  XOCHILL: DICCIONARIO DE DATOS 
-- =======================================================================================

--Las siguientes sentencias permiten consultar los metadatos de la base y con ello poder generar el diccionario de datos:

-- Listar todos los esquemas de la base de datos
SELECT 
    name AS NombreEsquema,
    schema_id AS ID,
    principal_id AS OwnerID
FROM sys.schemas
ORDER BY name;

--Listar todas las tablas 
SELECT 
    name AS NombreTabla,
    object_id AS ID,
    create_date AS FechaCreacion
FROM sys.tables
ORDER BY name;

--Ver todas las columnas de todas las tablas
SELECT 
    t.name AS NombreTabla,
    c.name AS NombreColumna,
    ty.name AS TipoDato,
    c.max_length AS Longitud,
    c.is_nullable AS PermiteNulo,
    c.is_identity AS EsIdentity
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
ORDER BY t.name, c.column_id;

-- Listar todos los índices con sus columnas en una sola fila
SELECT 
    s.name AS Esquema,
    t.name AS Tabla,
    i.name AS NombreIndice,
    i.type_desc AS TipoIndice,
    i.is_unique AS EsUnico,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Columnas
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.index_id > 0
GROUP BY s.name, t.name, i.name, i.type_desc, i.is_unique
ORDER BY s.name, t.name, i.name;


--Ver el listado de los usuarios y roles
SELECT 
    name AS NombreUsuario,
    type_desc AS Tipo,
    create_date AS FechaCreacion
FROM sys.database_principals
WHERE type IN ('S','U','R')  -- S=SQL user, U=Windows user, R=Role
ORDER BY name;


--Listar restricciones (PK, FK, CHECK)
-- Claves primarias y únicas
SELECT 
    t.name AS Tabla,
    i.name AS Restriccion,
    i.type_desc AS TipoRestriccion
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.is_primary_key = 1 OR i.is_unique_constraint = 1
ORDER BY t.name;

--Claves foráneas
SELECT 
    f.name AS NombreFK,
    OBJECT_NAME(f.parent_object_id) AS TablaHija,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnaHija,
    OBJECT_NAME(f.referenced_object_id) AS TablaPadre,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ColumnaPadre
FROM sys.foreign_keys AS f
JOIN sys.foreign_key_columns AS fc ON f.object_id = fc.constraint_object_id
ORDER BY TablaHija, NombreFK;


-- =======================================================================================
--  JAIME: ESTRATEGIA DE BACKUP
-- =======================================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ClinicaDB')
BEGIN
    PRINT 'ERROR: La base de datos ClinicaDB no existe.';
    RETURN;
END

IF (SELECT recovery_model_desc FROM sys.databases WHERE name = 'ClinicaDB') != 'FULL'
BEGIN
    PRINT 'Configurando modelo de recuperacion a FULL...';
    ALTER DATABASE ClinicaDB SET RECOVERY FULL;
END
GO

-- 1. BACKUP FULL
BACKUP DATABASE ClinicaDB 
TO DISK = 'C:\Backups\ClinicaDB_Full.bak'
WITH 
    FORMAT,
    INIT,
    NAME = 'Backup Completo ClinicaDB',
    DESCRIPTION = 'Copia completa de seguridad de ClinicaDB - Proyecto Final',
    STATS = 10,
    CHECKSUM;

PRINT ' BACKUP COMPLETO EXITOSO: C:\Backups\ClinicaDB_Full.bak';
GO

-- 2. SIMULAR CAMBIOS
USE ClinicaDB;
GO

INSERT INTO Admision.Paciente (nombre, apellido, sexo, fecha_nacimiento, telefono, correo, numero_expediente)
VALUES (
    'Juan', 
    'BackupTest', 
    'M', 
    '1990-01-01', 
    '555-TEST', 
    'backup.test@clinica.com', 
    'EXPTEST001'
);

INSERT INTO Admision.Cita (id_paciente, id_medico, fecha_cita, motivo)
VALUES (
    (SELECT MAX(id_paciente) FROM Admision.Paciente),
    1,
    GETDATE(),
    'Consulta de prueba - Backup'
);
PRINT ' Datos de prueba insertados correctamente';
GO

-- 3. BACKUP DIFERENCIAL
USE master;
GO

BACKUP DATABASE ClinicaDB 
TO DISK = 'C:\Backups\ClinicaDB_Diff.bak'
WITH 
    DIFFERENTIAL,
    INIT,
    NAME = 'Backup Diferencial ClinicaDB',
    DESCRIPTION = 'Copia diferencial de ClinicaDB - Cambios desde ultimo completo',
    STATS = 10,
    CHECKSUM;

PRINT ' BACKUP DIFERENCIAL EXITOSO: C:\Backups\ClinicaDB_Diff.bak';
GO

-- 4. MAS CAMBIOS PARA BACKUP DE LOG
USE ClinicaDB;
GO

UPDATE Admision.Paciente 
SET telefono = '555-UPDATED' 
WHERE numero_expediente = 'EXPTEST001';

DELETE FROM Admision.Cita 
WHERE motivo = 'Consulta de prueba - Backup';

PRINT ' Operaciones adicionales completadas';
GO

-- 5. BACKUP DE LOG DE TRANSACCIONES
USE master;
GO

BACKUP LOG ClinicaDB 
TO DISK = 'C:\Backups\ClinicaDB_Log.trn'
WITH 
    INIT,
    NAME = 'Backup del Log ClinicaDB',
    DESCRIPTION = 'Backup del log de transacciones de ClinicaDB',
    STATS = 10,
    CHECKSUM;

PRINT ' BACKUP DE LOG EXITOSO: C:\Backups\ClinicaDB_Log.trn';
GO

-- 6. VERIFICACION
SELECT 
    database_name AS 'Base de Datos',
    CASE type
        WHEN 'D' THEN 'Completo'
        WHEN 'I' THEN 'Diferencial' 
        WHEN 'L' THEN 'Log'
        ELSE type
    END AS 'Tipo Backup',
    backup_start_date AS 'Inicio',
    backup_finish_date AS 'Fin',
    CAST(backup_size/1048576.0 AS DECIMAL(10,2)) AS 'Tamano (MB)',
    name AS 'Nombre',
    description AS 'Descripcion'
FROM msdb.dbo.backupset 
WHERE database_name = 'ClinicaDB'
    AND backup_start_date >= DATEADD(HOUR, -1, GETDATE())
ORDER BY backup_start_date DESC;
GO

PRINT '=== 10. COMPROBANDO ARCHIVOS CREADOS ===';
EXEC xp_cmdshell 'dir C:\Backups\*.*';
GO


-- =======================================================================================
--  LUIS: JOBS (TAREAS PROGRAMADAS)
-- =======================================================================================

-- JOB: BACKUP DIARIO
USE msdb;
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Backup_Diario_ClinicaDB')
BEGIN
    EXEC sp_delete_job @job_name=N'Backup_Diario_ClinicaDB', @delete_unused_schedule=1;
    PRINT 'Job anterior eliminado correctamente.';
END
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup_Diario_ClinicaDB', 
        @enabled=1, 
        @notify_level_eventlog=0, 
        @notify_level_email=0, 
        @notify_level_netsend=0, 
        @notify_level_page=0, 
        @delete_level=0, 
        @description=N'Realiza un backup completo de la base de datos ClinicaDB automaticamente todos los dias a las 00:00.', 
        @category_name=N'[Uncategorized (Local)]', 
        @owner_login_name=N'sa', 
        @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Ejecutar Backup Full', 
        @step_id=1, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, 
        @subsystem=N'TSQL', 
        @command=N'BACKUP DATABASE [ClinicaDB] 
TO DISK = N''C:\Backups\ClinicaDB_Full_'' + REPLACE(CONVERT(VARCHAR, GETDATE(), 112), '''', '''') + ''.bak'' 
WITH FORMAT, INIT,  
NAME = N''ClinicaDB-Full Database Backup'', 
SKIP, NOREWIND, NOUNLOAD, STATS = 10;
PRINT ''Backup completo ejecutado exitosamente: '' + CONVERT(VARCHAR, GETDATE(), 120);', 
        @database_name=N'master', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verificar Backup', 
        @step_id=2, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, 
        @subsystem=N'TSQL', 
        @command=N'RESTORE VERIFYONLY FROM DISK = N''C:\Backups\ClinicaDB_Full_'' + REPLACE(CONVERT(VARCHAR, GETDATE(), 112), '''', '''') + ''.bak'';
PRINT ''Verificacion de backup completada exitosamente.'';', 
        @database_name=N'master', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_schedule @schedule_name=N'Horario_Medianoche_Diario', 
        @enabled=1, 
        @freq_type=4, 
        @freq_interval=1, 
        @freq_subday_type=1, 
        @freq_subday_interval=0, 
        @freq_relative_interval=0, 
        @freq_recurrence_factor=0, 
        @active_start_date=20250101, 
        @active_end_date=99991231, 
        @active_start_time=0, 
        @active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_attach_schedule @job_id=@jobId, @schedule_name=N'Horario_Medianoche_Diario'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION
GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
PRINT 'Job de Backup Diario creado exitosamente: Backup_Diario_ClinicaDB';
GO

-- JOB: BACKUP DIFERENCIAL CADA 6 HORAS
USE msdb;
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Backup_Diferencial_6Horas')
BEGIN
    EXEC sp_delete_job @job_name=N'Backup_Diferencial_6Horas', @delete_unused_schedule=1;
    PRINT 'Job anterior eliminado correctamente.';
END
GO

BEGIN TRANSACTION
DECLARE @ReturnCode2 INT
SELECT @ReturnCode2 = 0

DECLARE @jobId2 BINARY(16)
EXEC @ReturnCode2 =  msdb.dbo.sp_add_job @job_name=N'Backup_Diferencial_6Horas', 
        @enabled=1, 
        @notify_level_eventlog=0, 
        @notify_level_email=0, 
        @notify_level_netsend=0, 
        @notify_level_page=0, 
        @delete_level=0, 
        @description=N'Realiza backup diferencial de ClinicaDB cada 6 horas para cumplir RPO de 1 hora.', 
        @category_name=N'[Uncategorized (Local)]', 
        @owner_login_name=N'sa', 
        @job_id = @jobId2 OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode2 <> 0) GOTO QuitWithRollback2

EXEC @ReturnCode2 = msdb.dbo.sp_add_jobstep @job_id=@jobId2, @step_name=N'Ejecutar Backup Diferencial', 
        @step_id=1, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, 
        @subsystem=N'TSQL', 
        @command=N'BACKUP DATABASE [ClinicaDB] 
TO DISK = N''C:\Backups\ClinicaDB_Diff_'' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 120), '':'', ''''), ''-'', ''''), '' '', ''_'') + ''.bak''
WITH DIFFERENTIAL, NOFORMAT, NOINIT,  
NAME = N''ClinicaDB-Differential Backup'', 
SKIP, NOREWIND, NOUNLOAD, STATS = 10;
PRINT ''Backup diferencial ejecutado exitosamente: '' + CONVERT(VARCHAR, GETDATE(), 120);', 
        @database_name=N'master', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode2 <> 0) GOTO QuitWithRollback2

EXEC @ReturnCode2 = msdb.dbo.sp_add_schedule @schedule_name=N'Cada_6_Horas', 
        @enabled=1, 
        @freq_type=4, 
        @freq_interval=1, 
        @freq_subday_type=8, 
        @freq_subday_interval=6, 
        @freq_relative_interval=0, 
        @freq_recurrence_factor=0, 
        @active_start_date=20250101, 
        @active_end_date=99991231, 
        @active_start_time=0, 
        @active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode2 <> 0) GOTO QuitWithRollback2

EXEC @ReturnCode2 = msdb.dbo.sp_attach_schedule @job_id=@jobId2, @schedule_name=N'Cada_6_Horas'
IF (@@ERROR <> 0 OR @ReturnCode2 <> 0) GOTO QuitWithRollback2

EXEC @ReturnCode2 = msdb.dbo.sp_add_jobserver @job_id = @jobId2, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode2 <> 0) GOTO QuitWithRollback2

COMMIT TRANSACTION
GOTO EndSave2

QuitWithRollback2:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave2:
GO
PRINT 'Job de Backup Diferencial creado exitosamente: Backup_Diferencial_6Horas';
GO

-- JOB: LIMPIEZA DE BACKUPS
USE msdb;
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Limpieza_Backups_Antiguos')
BEGIN
    EXEC sp_delete_job @job_name=N'Limpieza_Backups_Antiguos', @delete_unused_schedule=1;
    PRINT 'Job anterior eliminado correctamente.';
END
GO

BEGIN TRANSACTION
DECLARE @ReturnCode3 INT
SELECT @ReturnCode3 = 0

DECLARE @jobId3 BINARY(16)
EXEC @ReturnCode3 =  msdb.dbo.sp_add_job @job_name=N'Limpieza_Backups_Antiguos', 
        @enabled=1, 
        @notify_level_eventlog=0, 
        @notify_level_email=0, 
        @notify_level_netsend=0, 
        @notify_level_page=0, 
        @delete_level=0, 
        @description=N'Elimina backups antiguos (mas de 30 dias) para liberar espacio en disco.', 
        @category_name=N'[Uncategorized (Local)]', 
        @owner_login_name=N'sa', 
        @job_id = @jobId3 OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode3 <> 0) GOTO QuitWithRollback3

EXEC @ReturnCode3 = msdb.dbo.sp_add_jobstep @job_id=@jobId3, @step_name=N'Eliminar Backups Antiguos', 
        @step_id=1, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, 
        @subsystem=N'TSQL', 
        @command=N'DECLARE @FechaEliminacion DATE = DATEADD(DAY, -30, GETDATE());
DECLARE @Archivo VARCHAR(500);

-- Eliminar del historial de msdb
DELETE FROM msdb.dbo.backupset 
WHERE backup_start_date < @FechaEliminacion 
AND database_name = ''ClinicaDB'';

-- Notificar archivos a eliminar
PRINT ''Backups anteriores a '' + CONVERT(VARCHAR, @FechaEliminacion, 103) + '' marcados para eliminacion.'';', 
        @database_name=N'master', 
        @flags=0
IF (@@ERROR <> 0 OR @ReturnCode3 <> 0) GOTO QuitWithRollback3

EXEC @ReturnCode3 = msdb.dbo.sp_add_schedule @schedule_name=N'Limpieza_Semanal', 
        @enabled=1, 
        @freq_type=8, 
        @freq_interval=1, 
        @freq_subday_type=1, 
        @freq_subday_interval=0, 
        @freq_relative_interval=0, 
        @freq_recurrence_factor=1, 
        @active_start_date=20250101, 
        @active_end_date=99991231, 
        @active_start_time=10000, 
        @active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode3 <> 0) GOTO QuitWithRollback3

EXEC @ReturnCode3 = msdb.dbo.sp_attach_schedule @job_id=@jobId3, @schedule_name=N'Limpieza_Semanal'
IF (@@ERROR <> 0 OR @ReturnCode3 <> 0) GOTO QuitWithRollback3

EXEC @ReturnCode3 = msdb.dbo.sp_add_jobserver @job_id = @jobId3, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode3 <> 0) GOTO QuitWithRollback3

COMMIT TRANSACTION
GOTO EndSave3

QuitWithRollback3:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave3:
GO
PRINT 'Job de Limpieza creado exitosamente: Limpieza_Backups_Antiguos';
GO

-- SCRIPT EJECUCION Y VERIFICACION JOBS
PRINT '=== EJECUCION Y VERIFICACION DE JOBS ===';

EXEC msdb.dbo.sp_start_job @job_name = N'Backup_Diario_ClinicaDB';
WAITFOR DELAY '00:00:05';

EXEC msdb.dbo.sp_start_job @job_name = N'Backup_Diferencial_6Horas';
WAITFOR DELAY '00:00:05';

EXEC msdb.dbo.sp_start_job @job_name = N'Limpieza_Backups_Antiguos';
WAITFOR DELAY '00:00:05';

-- Verificar jobs creados
SELECT 
    name AS NombreJob,
    enabled AS Activado,
    description AS Descripcion,
    date_created AS FechaCreacion,
    CASE 
        WHEN date_modified = date_created THEN 'Nunca modificado'
        ELSE CONVERT(VARCHAR, date_modified, 120)
    END AS UltimaModificacion
FROM msdb.dbo.sysjobs
WHERE name LIKE '%ClinicaDB%' OR name LIKE '%Backup%' OR name LIKE '%Limpieza%'
ORDER BY date_created DESC;

-- Verificar historial de ejecucion
SELECT 
    j.name AS JobName,
    CASE h.run_status 
        WHEN 1 THEN ' Exito'
        WHEN 0 THEN ' Fallo'
        WHEN 2 THEN ' Reintento'
        WHEN 3 THEN ' Cancelado'
        ELSE ' Desconocido'
    END AS Estado,
    CAST(h.run_date AS VARCHAR(8)) AS Fecha,
    STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS Hora,
    h.run_duration AS DuracionSeg,
    LEFT(h.message, 50) + '...' AS Mensaje
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE j.name IN ('Backup_Diario_ClinicaDB', 'Backup_Diferencial_6Horas', 'Limpieza_Backups_Antiguos')
    AND h.step_id = 0
    AND h.run_date >= CONVERT(VARCHAR, GETDATE(), 112)
ORDER BY h.run_date DESC, h.run_time DESC;

PRINT '=== VERIFICACION COMPLETADA ===';


-- =======================================================================================
--  JULISSA: AUDITORIA
-- =======================================================================================

-- 1. CREACION DE AUDITORIA A NIVEL SERVIDOR
USE master;
GO

CREATE SERVER AUDIT AuditoriaClinica
TO FILE (
    FILEPATH = 'C:\auditsclinica\',  
    MAXSIZE = 50 MB,
    MAX_ROLLOVER_FILES = 20,
    RESERVE_DISK_SPACE = OFF
)
WITH (
    ON_FAILURE = CONTINUE
);
GO

-- Habilitar la auditoria
ALTER SERVER AUDIT AuditoriaClinica WITH (STATE = ON);
GO

-- 2. CREACION DE ESPECIFICACION DE AUDITORIA A NIVEL BASE DE DATOS
USE ClinicaDB;
GO

CREATE DATABASE AUDIT SPECIFICATION AuditoriaClinicaDB
FOR SERVER AUDIT AuditoriaClinica
ADD (SELECT ON OBJECT::Admision.Paciente BY PUBLIC),
ADD (INSERT ON OBJECT::Admision.Paciente BY PUBLIC),
ADD (UPDATE ON OBJECT::Admision.Paciente BY PUBLIC),

ADD (SELECT ON OBJECT::Admision.Cita BY PUBLIC),
ADD (INSERT ON OBJECT::Admision.Cita BY PUBLIC),
ADD (UPDATE ON OBJECT::Admision.Cita BY PUBLIC),

ADD (SELECT ON OBJECT::Medica.Tratamiento BY PUBLIC),
ADD (INSERT ON OBJECT::Medica.Tratamiento BY PUBLIC),
ADD (UPDATE ON OBJECT::Medica.Tratamiento BY PUBLIC),

ADD (SELECT ON OBJECT::Finanzas.Factura BY PUBLIC),
ADD (INSERT ON OBJECT::Finanzas.Factura BY PUBLIC),
ADD (UPDATE ON OBJECT::Finanzas.Factura BY PUBLIC),

ADD (SELECT ON OBJECT::Finanzas.Detalle_Factura BY PUBLIC),
ADD (INSERT ON OBJECT::Finanzas.Detalle_Factura BY PUBLIC),
ADD (UPDATE ON OBJECT::Finanzas.Detalle_Factura BY PUBLIC) 
WITH (STATE = ON);
GO

-- 3. PRUEBAS DE AUDITORIA
INSERT INTO Admision.Paciente (Nombre, Apellido, Telefono, Fecha_Nacimiento)
VALUES ('MARIA', 'GOMEZ', '23432123', '1990-01-01');

UPDATE Admision.Paciente SET Apellido = 'Wong' WHERE Nombre = 'Irene';

-- 4. CONSULTA DE LOGS DE AUDITORIA
SELECT *
FROM sys.fn_get_audit_file('C:\auditsclinica\*', DEFAULT, DEFAULT);
GO

-- Filtrar SELECT
SELECT event_time, server_principal_name, database_principal_name,
       object_name, statement, action_id
FROM sys.fn_get_audit_file('C:\auditsclinica\*', DEFAULT, DEFAULT)
WHERE action_id = 'SL';
GO

-- Filtrar INSERT
SELECT event_time, server_principal_name, database_principal_name,
       object_name, statement
FROM sys.fn_get_audit_file('C:\auditsclinica\*', DEFAULT, DEFAULT)
WHERE action_id = 'IN';
GO

-- Filtrar UPDATE
SELECT event_time, server_principal_name, database_principal_name,
       object_name, statement
FROM sys.fn_get_audit_file('C:\auditsclinica\*', DEFAULT, DEFAULT)
WHERE action_id = 'UP';
GO

-- Filtrar DELETE
SELECT event_time, server_principal_name, database_principal_name,
       object_name, statement
FROM sys.fn_get_audit_file('C:\auditsclinica\*', DEFAULT, DEFAULT)
WHERE action_id = 'DL';
GO

