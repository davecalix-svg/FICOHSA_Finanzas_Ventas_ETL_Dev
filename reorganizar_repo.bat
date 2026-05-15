@echo off
:: Navegar a la carpeta donde esta el .bat
cd /d "%~dp0"

echo ==============================================
echo  FICOHSA - Reorganizacion del Repositorio
echo ==============================================
echo.

:: Verificar que estamos en la raiz del repositorio
IF NOT EXIST "Finanzas_Ventas_CargaCSV_Dev.dtsx" (
    echo ERROR: Ejecuta este script desde la raiz del repositorio.
    echo Asegurate de estar en la carpeta FICOHSA_Finanzas_Ventas_ETL_Dev
    pause
    exit /b 1
)

echo [1/7] Creando estructura de carpetas...
mkdir ssis        2>nul
mkdir sql         2>nul
mkdir data\DEV    2>nul
mkdir data\QA     2>nul
mkdir data\PROD   2>nul
mkdir docker      2>nul
echo      OK

echo [2/7] Moviendo archivos del proyecto SSIS...
move /Y "Finanzas_Ventas_CargaCSV_Dev.dtsx"                 ssis\ >nul
move /Y "FICOHSA_Finanzas_Ventas_ETL_Dev.dtproj"            ssis\ >nul
move /Y "FICOHSA_Finanzas_Ventas_ETL_Dev.database"          ssis\ >nul
move /Y "FICOHSA_Finanzas_Ventas_ETL_Dev.slnx"              ssis\ >nul
move /Y "Project.params"                                     ssis\ >nul
echo      OK

echo [3/7] Moviendo archivos CSV a sus ambientes...
:: DEV
IF EXIST "ventas.csv"               move /Y "ventas.csv"              data\DEV\ >nul
IF EXIST "pagos.csv"                move /Y "pagos.csv"               data\DEV\ >nul

:: QA
IF EXIST "QA\Ventas\ventas.csv"     move /Y "QA\Ventas\ventas.csv"    data\QA\  >nul
IF EXIST "QA\Ventas\pagos.csv"      move /Y "QA\Ventas\pagos.csv"     data\QA\  >nul

:: PROD
IF EXIST "PROD\Ventas\ventas.csv"   move /Y "PROD\Ventas\ventas.csv"  data\PROD\ >nul
IF EXIST "PROD\Ventas\pagos.csv"    move /Y "PROD\Ventas\pagos.csv"   data\PROD\ >nul
echo      OK

echo [4/7] Moviendo scripts SQL...
IF EXIST "01_Crear_BD_Tablas.sql"   move /Y "01_Crear_BD_Tablas.sql"  sql\ >nul
echo      OK

echo [5/7] Moviendo infraestructura Docker...
IF EXIST "docker-compose.yml"       move /Y "docker-compose.yml"      docker\ >nul
echo      OK

echo [6/7] Eliminando carpetas y archivos innecesarios...
IF EXIST "PROD\Ventas"      rmdir /S /Q "PROD\Ventas"    >nul
IF EXIST "PROD"             rmdir /S /Q "PROD"           >nul
IF EXIST "QA\Ventas"        rmdir /S /Q "QA\Ventas"      >nul
IF EXIST "QA"               rmdir /S /Q "QA"             >nul
IF EXIST "UpgradeLog.htm"   del   /Q    "UpgradeLog.htm" >nul
IF EXIST "*.dtproj.user"    del   /Q    "*.dtproj.user"  >nul
echo      OK

echo [7/7] Ejecutando Git...
git add .
git commit -m "refactor: reorganizacion estructura repositorio enterprise"
git push
echo      OK

echo.
echo ==============================================
echo  Estructura final del repositorio:
echo ==============================================
tree /F
echo.
echo ==============================================
echo  Reorganizacion completada exitosamente!
echo ==============================================
pause