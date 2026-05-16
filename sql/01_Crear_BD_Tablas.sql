/*
=============================================================
  FICOHSA Finanzas - ETL de Ventas y Pagos
  Script: Creacion de Base de Datos y Tablas
  Version: 1.0
  Fecha: 2026-05-15
  Autor: David Guzman
=============================================================
*/

-- ============================================================
-- 1. CREAR BASE DE DATOS
-- ============================================================
USE master
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DemoETL')
BEGIN
    CREATE DATABASE DemoETL
    PRINT 'Base de datos DemoETL creada exitosamente.'
END
ELSE
    PRINT 'La base de datos DemoETL ya existe.'
GO

USE DemoETL
GO

-- ============================================================
-- 2. TABLA: Ventas
-- Almacena registros validos del archivo ventas.csv
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Ventas')
BEGIN
    CREATE TABLE dbo.Ventas (
        Id              INT             IDENTITY(1,1)   NOT NULL PRIMARY KEY,
        Fecha           DATE                            NULL,
        Producto        NVARCHAR(100)                   NULL,
        Cantidad        INT                             NULL,
        PrecioUnitario  DECIMAL(10,2)                   NULL,
        Total           DECIMAL(10,2)                   NULL
    )
    PRINT 'Tabla Ventas creada exitosamente.'
END
ELSE
    PRINT 'La tabla Ventas ya existe.'
GO

-- ============================================================
-- 3. TABLA: ErroresVentas
-- Almacena registros invalidos del archivo ventas.csv
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ErroresVentas')
BEGIN
    CREATE TABLE dbo.ErroresVentas (
        Id              INT             IDENTITY(1,1)   NOT NULL PRIMARY KEY,
        Fecha           DATE                            NULL,
        Producto        NVARCHAR(100)                   NULL,
        Cantidad        VARCHAR(100)                    NULL,
        PrecioUnitario  DECIMAL(10,2)                   NULL,
        Total           DECIMAL(10,2)                   NULL,
        ErrorDescripcion NVARCHAR(200)                  NULL
    )
    PRINT 'Tabla ErroresVentas creada exitosamente.'
END
ELSE
    PRINT 'La tabla ErroresVentas ya existe.'
GO

-- ============================================================
-- 4. TABLA: Pagos
-- Almacena registros validos del archivo pagos.csv
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Pagos')
BEGIN
    CREATE TABLE dbo.Pagos (
        PagoId              INT             IDENTITY(1,1)   NOT NULL PRIMARY KEY,
        ClienteId           INT                             NULL,
        Monto               DECIMAL(18,2)                   NULL,
        FechaPago           DATE                            NULL,
        MetodoPago          VARCHAR(50)                     NULL,
        Estado              VARCHAR(20)                     NULL,
        FechaCarga          DATETIME                        NULL DEFAULT GETDATE(),
        NumeroTransaccion   VARCHAR(50)                     NULL,
        Moneda              VARCHAR(10)                     NULL,
        HoraPago            VARCHAR(10)                     NULL,
        Canal               VARCHAR(50)                     NULL,
        CuentaOrigen        VARCHAR(20)                     NULL,
        CuentaDestino       VARCHAR(20)                     NULL,
        Descripcion         VARCHAR(200)                    NULL,
        Referencia          VARCHAR(20)                     NULL,
        UsuarioCreacion     VARCHAR(50)                     NULL
    )
    PRINT 'Tabla Pagos creada exitosamente.'
END
ELSE
    PRINT 'La tabla Pagos ya existe.'
GO

-- ============================================================
-- 5. TABLA: ErroresPagos
-- Almacena registros invalidos del archivo pagos.csv
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ErroresPagos')
BEGIN
    CREATE TABLE dbo.ErroresPagos (
        Id                  INT             IDENTITY(1,1)   NOT NULL PRIMARY KEY,
        ClienteId           VARCHAR(100)                    NULL,
        Monto               VARCHAR(100)                    NULL,
        FechaPago           VARCHAR(100)                    NULL,
        MetodoPago          VARCHAR(100)                    NULL,
        Estado              VARCHAR(100)                    NULL,
        ErrorDescripcion    NVARCHAR(100)                   NULL,
        FechaCarga          DATETIME                        NULL DEFAULT GETDATE(),
        NumeroTransaccion   VARCHAR(100)                    NULL,
        Moneda              VARCHAR(100)                    NULL,
        HoraPago            VARCHAR(100)                    NULL,
        Canal               VARCHAR(100)                    NULL,
        CuentaOrigen        VARCHAR(100)                    NULL,
        CuentaDestino       VARCHAR(100)                    NULL,
        Descripcion         VARCHAR(200)                    NULL,
        Referencia          VARCHAR(100)                    NULL,
        UsuarioCreacion     VARCHAR(100)                    NULL
    )
    PRINT 'Tabla ErroresPagos creada exitosamente.'
END
ELSE
    PRINT 'La tabla ErroresPagos ya existe.'
GO

-- ============================================================
-- 6. TABLA: LogEjecucion
-- Auditoria de cada ejecucion del paquete SSIS
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LogEjecucion')
BEGIN
    CREATE TABLE dbo.LogEjecucion (
        Id                      INT             IDENTITY(1,1)   NOT NULL PRIMARY KEY,
        FechaEjecucion          DATETIME                        NULL,
        FilasValidas            INT                             NULL,
        FilasInvalidas          INT                             NULL,
        Estado                  NVARCHAR(50)                    NULL,
        FilasErrorConversion    INT                             NULL,
        NombrePaquete           VARCHAR(200)                    NULL,
        NombreArchivo           VARCHAR(500)                    NULL,
        MensajeError            VARCHAR(1000)                   NULL,
        DuracionSegundos        INT                             NULL,
        FilasPagosValidas       INT                             NULL,
        FilasPagosInvalidas     INT                             NULL,
        FilasErrorConvPagos     INT                             NULL
    )
    PRINT 'Tabla LogEjecucion creada exitosamente.'
END
ELSE
    PRINT 'La tabla LogEjecucion ya existe.'
GO

-- ============================================================
-- VERIFICACION FINAL
-- ============================================================
SELECT 
    t.name          AS Tabla,
    p.rows          AS TotalRegistros,
    t.create_date   AS FechaCreacion
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
AND t.name IN ('Ventas','ErroresVentas','Pagos','ErroresPagos','LogEjecucion')
ORDER BY t.name
GO

PRINT '=============================================='
PRINT 'Script ejecutado exitosamente en DemoETL'
PRINT '=============================================='
