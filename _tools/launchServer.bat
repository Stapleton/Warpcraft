@ECHO OFF

rem User Variables
set MAXRAM=8G
set MINRAM=4G
set "JVMARGS="

rem Program Variables DO NOT TOUCH
set "REPO_URL=https://gitlab.com/Stapleton/smclt.git"
set "MinGitZipURL=https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/MinGit-2.45.2-64-bit.zip"
set "MinGitZip=MinGit.zip"
set "Git=%~dp0\.mingit\cmd"

set "FABRIC_URL=https://meta.fabricmc.net/v2/versions/loader/1.20.1/0.15.11/1.0.1/server/jar"
set "JAVA_URL=https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jre/hotspot/normal/eclipse"
set "JAVA_DIR=.Java21"

echo ****************************************
echo * Launching SMC Long Term Server
echo * Checking for OS Type

if exist "C:\Windows\" (
	echo * OS is Windows, continuing execution.
	goto GitCheck*-
) else (
	echo * OS is not Windows, exiting...
	pause 69
)

:GitCheck
"%Git%\git" -v >nul 2>&1 && (
	echo * Git is installed, continuing execution...
	goto GitRepoCheck
) || (
	echo * Git not found, downloading and installing Git.
	powershell -Command "Invoke-WebRequest %MinGitZipURL% -OutFile %MinGitZip%"
	powershell -command "Expand-Archive -Force '%~dp0%MinGitZip%' '%~dp0.mingit'"
	goto GitRepoCheck
)

:GitRepoCheck
if exist ".git\" (
	echo * Detected git repo. Updating Server!
	goto UpdateServer
) else (
	echo * No .git folder was found. Installing Server!
	goto InstallServer
)

:InstallServer
echo * Installing SMC Long Term Server from Gitlab 
echo * * Cloning repo into temp folder
"%Git%\git" clone %REPO_URL% .\repo.tmp
echo * * Copying repo out of temp and into current folder
robocopy .\repo.tmp\ . /E /MOV
echo * * Deleting empty temp folder
rmdir /S /Q .\repo.tmp
echo * * Downloading Fabric Server Jar
powershell -Command "Invoke-WebRequest %FABRIC_URL% -OutFile fabric.jar"
echo * * Downloading Java 21
powershell -Command "Invoke-WebRequest %JAVA_URL% -OutFile java.zip"
echo * * Extracting Java 21
tar -xf java.zip
FOR /d %%i IN (jdk-*) DO move %%i %JAVA_DIR%%
echo * Server Installation Complete!
echo ****************************************
goto RemoveNonServerFriendlyMods

:UpdateServer
echo * Updating SMC Long Term Server from Gitlab
echo * * Fetching changes from upstream
"%Git%\git" fetch
echo * * Hard resetting local to match upstream
"%Git%\git" reset --hard HEAD
echo * * Merging changes fetched from upstream
"%Git%\git" merge origin/main
echo * Server Update Complete!
echo ****************************************
goto RemoveNonServerFriendlyMods

:RemoveNonServerFriendlyMods
echo * Removing mods not friendly for servers
for /f "delims=" %%f in (NonServerFriendlyMods.txt) do del "mods\%%f"
echo * Removed problematic mods
echo ****************************************
goto :StartServer

:StartServer
echo * Starting SMC Long Term Server
echo ****************************************
%JAVA_DIR%\bin\java.exe -Xms%MINRAM% -Xmx%MAXRAM% "%JVMARGS%" -jar fabric.jar nogui
pause
