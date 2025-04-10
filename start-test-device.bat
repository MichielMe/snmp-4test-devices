@echo off
rem Start the test SNMP devices

setlocal EnableDelayedExpansion

rem Change to the script directory
cd /d "%~dp0"

rem Define the containers and their host ports
set "DEVICE[0]=snmp-device-01:10161:router-01"
set "DEVICE[1]=snmp-device-02:10162:router-02"
set "DEVICE[2]=snmp-device-03:10163:switch-01"
set "DEVICE[3]=snmp-device-04:10164:switch-02"

rem Initialize running count
set RUNNING_COUNT=0

rem Check if the containers are already running
for /L %%i in (0,1,3) do (
    for /F "tokens=1-3 delims=:" %%a in ("!DEVICE[%%i]!") do (
        set "CONTAINER_NAME=%%a"
        set "PORT=%%b"
        set "DEVICE_NAME=%%c"
        
        docker ps | findstr /C:"!CONTAINER_NAME!" > nul
        if !errorlevel! equ 0 (
            set /a RUNNING_COUNT+=1
            for /F "tokens=*" %%i in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" !CONTAINER_NAME!') do set "CONTAINER_IP=%%i"
            
            echo !DEVICE_NAME! is already running!
            echo Container: !CONTAINER_NAME!
            echo IP Address: !CONTAINER_IP!
            echo SNMP Port: 161 (mapped to host port !PORT!)
            echo.
            echo To test connectivity:
            echo   snmpwalk -v2c -c public localhost:!PORT! system
            echo.
            echo To add to your SNMP-Prometheus Automation system:
            echo   scripts\add-device.bat --ip !CONTAINER_IP! --community public --name "!DEVICE_NAME!"
            echo.
        )
    )
)

rem If all containers are running, exit
if !RUNNING_COUNT! equ 4 (
    echo All SNMP test devices are running!
    goto :end
)

rem Create the containers
echo Starting SNMP test devices...
docker-compose up -d

rem Wait for the containers to start
timeout /t 2 /nobreak > nul

echo SNMP test devices started successfully!
echo.

rem Display information for each container
for /L %%i in (0,1,3) do (
    for /F "tokens=1-3 delims=:" %%a in ("!DEVICE[%%i]!") do (
        set "CONTAINER_NAME=%%a"
        set "PORT=%%b"
        set "DEVICE_NAME=%%c"
        
        for /F "tokens=*" %%i in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" !CONTAINER_NAME!') do set "CONTAINER_IP=%%i"
        
        echo !DEVICE_NAME! information:
        echo Container: !CONTAINER_NAME!
        echo IP Address: !CONTAINER_IP!
        echo SNMP Port: 161 (mapped to host port !PORT!)
        echo.
        echo To test connectivity:
        echo   snmpwalk -v2c -c public localhost:!PORT! system
        echo.
        echo To add to your SNMP-Prometheus Automation system:
        echo   scripts\add-device.bat --ip !CONTAINER_IP! --community public --name "!DEVICE_NAME!"
        echo --------------------------------------------
        echo.
    )
)

:end
endlocal 