@echo off
SET CGO_ENABLED=0
REM --- 如果要编译64位 需要把下面的 386 改为 amd64
SET GOARCH=386
SET GO111MODULE=on
SET GOPROXY=https://goproxy.cn
SET PROJECT_NAME=billing
SET appVersion=1.3.5
SET gitCommitHash=
FOR /F %%a IN ('git rev-parse HEAD') DO SET "gitCommitHash=%%a"
SET SERVICES_PKG=github.com/liuguangw/billing_go/services
SET buildLdFlags=-X %SERVICES_PKG%.appVersion=%appVersion%
SET buildLdFlags=%buildLdFlags% -X '%SERVICES_PKG%.appBuildTime=%date% %time%'
SET buildLdFlags=%buildLdFlags% -X %SERVICES_PKG%.gitCommitHash=%gitCommitHash%
SET buildLdFlags=%buildLdFlags% -X %SERVICES_PKG%.builderMachine=Windows

FOR %%a IN (linux,windows) DO (
  call :buildCommand %%a
)
echo build complete
pause
exit

REM --------------
REM ------编译命令
REM --------------
:buildCommand
SET GOOS=%1
SET TARGET_FILE=%PROJECT_NAME%
echo build for ^<%GOOS%/%GOARCH%^>
if "%GOOS%" == "windows" (
    SET TARGET_FILE=%TARGET_FILE%.exe
) else if not "%GOOS%" == "linux" (
    SET TARGET_FILE=%TARGET_FILE%_%GOOS%
)
go build -ldflags "-s -w %buildLdFlags%" -a -o %TARGET_FILE% .
if %ERRORLEVEL% NEQ 0 (
	pause
	exit
)
goto :eof