@ECHO OFF
set "REPO_URL=https://gitlab.com/Stapleton/smclt.git"
set "MinGitZipURL=https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/MinGit-2.45.2-64-bit.zip"
set "MinGitZip=MinGit.zip"
set "Git=%~dp0\.mingit\cmd"

echo ****************************************
echo * Launching SMC Long Term
echo * Checking for OS Type

if exist "C:\Windows\" (
	echo * OS is Windows, continuing execution.
	goto GitCheck
) else (
	echo * OS is not Windows, exiting...
	exit 69
)

:GitCheck
git -v >nul 2>&1 && (
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
	echo * Detected git repo. Updating Pack!
	goto UpdatePack
) else (
	echo * No .git folder was found. Installing Pack!
	goto InstallPack
)

:InstallPack
echo * Installing SMC Long Term from Gitlab 
echo * * Cloning repo into temp folder
"%Git%\git" clone %REPO_URL% .\repo.tmp
echo * * Copying repo out of temp and into current folder
robocopy .\repo.tmp\ . /E /MOV
echo * * Deleting empty temp folder
rmdir /S /Q .\repo.tmp
echo * Pack Installation Complete!
echo * Exiting in 3 seconds
echo ****************************************
timeout 3
exit 0

:UpdatePack
echo * Updating SMC Long Term from Gitlab
echo * * Fetching changes from upstream
"%Git%\git" fetch
echo * * Hard resetting local to match upstream
"%Git%\git" reset --hard HEAD
echo * * Merging changes fetched from upstream
"%Git%\git" merge origin/main
echo * Pack Update Complete!
echo * Exiting in 3 seconds
echo ****************************************
timeout 3
exit 0
