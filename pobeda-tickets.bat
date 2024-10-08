@echo off
setlocal enabledelayedexpansion

:: Check for Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not installed. Please install Python 3.10 or higher and try again.
    pause
    exit /b 1
) else (
    echo Python is already installed.
)

:: Check for Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed. Installing Git...

    :: Download Git installer
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe', 'git-installer.exe')"

    :: Install Git
    start /wait git-installer.exe /VERYSILENT /NORESTART

    :: Delete installer
    del git-installer.exe

    :: Add Git to PATH
    setx PATH "%PATH%;C:\Program Files\Git\cmd" /M

    echo Git has been successfully installed.
) else (
    echo Git is already installed.
)

TODO
:: Clone repository
set "repo_url=https://github.com/your-username/ticket-search-app.git"
set "project_folder=ticket-search-app"

if not exist "%project_folder%" (
    echo Cloning repository...
    git clone %repo_url% %project_folder%
) else (
    echo Project folder already exists. Skipping cloning.
)

:: Change to project folder
cd %project_folder%

:: Create and activate virtual environment
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)
call venv\Scripts\activate

:: Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

:: Install Chrome and ChromeDriver
echo Installing Chrome and ChromeDriver...
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://dl.google.com/chrome/install/latest/chrome_installer.exe', 'chrome_installer.exe')"
start /wait chrome_installer.exe /silent /install
del chrome_installer.exe

for /f "tokens=*" %%a in ('powershell -Command "(Invoke-WebRequest -Uri 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE').Content.Trim()"') do set "CHROME_DRIVER_VERSION=%%a"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://chromedriver.storage.googleapis.com/%CHROME_DRIVER_VERSION%/chromedriver_win32.zip', 'chromedriver.zip')"
powershell Expand-Archive chromedriver.zip -DestinationPath .
del chromedriver.zip

:: Start server
echo Starting server...
start cmd /k python app.py

echo Server is running. Open your browser and navigate to http://localhost:5000

endlocal
