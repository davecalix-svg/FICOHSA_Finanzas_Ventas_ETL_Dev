# FICOHSA Finanzas - ETL de Ventas y Pagos

## Descripción
Paquete SSIS para la carga y validación de archivos CSV de Ventas y Pagos hacia SQL Server 2022, con manejo de errores, auditoría de ejecución y despliegue en el catálogo SSISDB.

---

## Arquitectura del Proyecto

```
FICOHSA_Finanzas_Ventas_ETL_Dev/
│
├── 📁 sql/
│   └── 01_Crear_BD_Tablas.sql            # Creación de BD y tablas
│
├── 📁 data/
│   ├── ventas.csv                        # Archivo de prueba Ventas
│
├── 📁 deployment/
│   ├── FICOHSA_Finanzas_Ventas_Pagos_ETL_Dev.ispac # Archivo de deployment
│
├── 📁 docker/
│   ├── docker-compose.yml                # Archivo de composicion de docker
│
├── 📁 ssis/
│   └── Finanzas_Ventas_CargaCSV_Dev.dtsx  # Paquete SSIS principal
│
└── README.md
```

---

## Base de Datos: DemoETL

### Tablas

| Tabla | Descripción |
|---|---|
| `Ventas` | Registros válidos del CSV de ventas |
| `ErroresVentas` | Registros inválidos del CSV de ventas |
| `Pagos` | Registros válidos del CSV de pagos |
| `ErroresPagos` | Registros inválidos del CSV de pagos |
| `LogEjecucion` | Auditoría de cada ejecución del paquete |

---

## Flujo de Datos SSIS

### Data Flow 1 — CargaVentasCSV
```
SRC_FF_Ventas
    ├── (error) → CNT_ErroresConversion → DER_ErroresConversion → DST_OLE_ErroresConversion
    └── CNV_Ventas
            ├── (error) → ruta error técnico
            └── DER_PreparacionVentas
                    └── SPL_ValidacionVentas
                            ├── RegistrosValidos   → CNT_RegistrosValidos   → DST_OLE_Ventas
                            └── RegistrosInvalidos → CNT_RegistrosInvalidos → DER_ErroresNegocio → DST_OLE_ErroresNegocio
```

### Data Flow 2 — CargaPagosCSV
```
SRC_FF_Pagos
    └── CNV_Pagos
            ├── (error) → CNT_ErroresConversionPagos → DER_ErroresConversionPagos → DST_OLE_ErroresPagos
            └── SPL_ValidacionPagos
                    ├── PagosValidos   → CNT_PagosValidos   → DST_OLE_Pagos
                    └── PagosInvalidos → CNT_PagosInvalidos → DER_ErroresPagos → DST_OLE_ErroresPagos
```

---

## Validaciones implementadas

### Ventas
| Validación | Tipo |
|---|---|
| Cantidad no numérica | Error de conversión |
| Cantidad <= 0 | Error de negocio |

### Pagos
| Validación | Tipo |
|---|---|
| Monto no numérico | Error de conversión |
| ClienteId vacío | Error de negocio |
| Monto <= 0 | Error de negocio |
| Estado fuera de catálogo | Error de negocio |

---

## Tabla de Auditoría: LogEjecucion

| Columna | Descripción |
|---|---|
| `FechaEjecucion` | Cuándo corrió el paquete |
| `FilasValidas` | Ventas insertadas |
| `FilasInvalidas` | Ventas rechazadas |
| `FilasErrorConversion` | Errores técnicos Ventas |
| `FilasPagosValidas` | Pagos insertados |
| `FilasPagosInvalidas` | Pagos rechazados |
| `FilasErrorConvPagos` | Errores técnicos Pagos |
| `Estado` | EXITOSO / CON_ERRORES / FALLIDO |
| `NombrePaquete` | Nombre del paquete SSIS |
| `NombreArchivo` | Ruta del archivo procesado |
| `MensajeError` | Detalle del error si falló |
| `DuracionSegundos` | Tiempo de ejecución |

---

## Deployment

### Prerequisitos
- SQL Server 2022 Developer Edition
- SQL Server Integration Services 16.0
- Visual Studio 2022 con extensión SSIS Projects
- SSMS 19+

### Pasos de instalación

**1. Crear la base de datos y tablas**
```sql
-- Ejecutar en SSMS
01_Crear_BD_Tablas.sql
```

**2. Crear el catálogo SSISDB**
```
SSMS → Integration Services Catalogs → Clic derecho → Crear catálogo
```

**3. Crear la carpeta en SSISDB**
```
SSISDB → Clic derecho → Crear carpeta → FICOHSA
```

**4. Desplegar el proyecto**
```
Visual Studio → Clic derecho en proyecto → Implementar
Servidor: localhost
Ruta: /SSISDB/FICOHSA/FICOHSA_Finanzas_Ventas_ETL_Dev
```

**5. Configurar Environments**
```
SSISDB → FICOHSA → Environments → Crear:
  - ENV_DEV  → RutaArchivos = C:\Cursos\SSIS\
  - ENV_QA   → RutaArchivos = C:\QA\Ventas\
  - ENV_PROD → RutaArchivos = D:\Produccion\Ventas\
```

**6. Crear el SQL Agent Job**
```
SQL Server Agent → Jobs → Nuevo trabajo
Nombre: JOB_FICOHSA_CargaVentas_Diaria
Step:   STEP_CargaVentasCSV → SSIS Package → ENV_PROD
Schedule: Diaria a las 06:00 AM
```

---

## Archivos CSV de prueba

### ventas.csv
```
Fecha,Producto,Cantidad,PrecioUnitario
```

### pagos.csv
```
PagoId,ClienteId,NumeroTransaccion,Monto,Moneda,FechaPago,
HoraPago,MetodoPago,Canal,Estado,CuentaOrigen,CuentaDestino,
Descripcion,Referencia,UsuarioCreacion,FechaCreacion
```

---

## Autor
David Guzman 
Fecha: Mayo 2026
