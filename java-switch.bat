@echo off
setlocal enabledelayedexpansion

:: @echo off keeps the automatic logs from clogging up the terminal
:: setlocal enabledelayedexpansion is required for variables to work in loops

:: Welcome to Brando's Java switcher, a quick batch script to change between versions of Java in the blink of an eye (or a couple blinks anyway)
:: This handles 7,8,11,12,17,21,22, and if you need others, simply add them to the following two blocks of code
SET "JAVA_HOME_7=C:\Program Files\Java\jdk1.7.0_80"
SET "JAVA_HOME_8=C:\Program Files\Java\jdk1.8.0_202"
SET "JAVA_HOME_11=C:\Program Files\Java\jdk-11"
SET "JAVA_HOME_12=C:\Program Files\Java\jdk-12.0.1"
SET "JAVA_HOME_17=C:\Program Files\Java\jdk-17"
SET "JAVA_HOME_21=C:\Program Files\Java\jdk-21"
SET "JAVA_HOME_22=C:\Program Files\Java\jdk-22"

:: Select the appropriate JAVA_HOME based on input
IF "%1" == "7" (
    SET "JAVA_HOME=%JAVA_HOME_7%"
    SET "JAVA_VERSION=1.7"
) ELSE IF "%1" == "8" (
    SET "JAVA_HOME=%JAVA_HOME_8%"
    SET "JAVA_VERSION=1.8"
) ELSE IF "%1" == "11" (
    SET "JAVA_HOME=%JAVA_HOME_11%"
    SET "JAVA_VERSION=11"
) ELSE IF "%1" == "12" (
    SET "JAVA_HOME=%JAVA_HOME_12%"
    SET "JAVA_VERSION=12"
) ELSE IF "%1" == "17" (
    SET "JAVA_HOME=%JAVA_HOME_17%"
    SET "JAVA_VERSION=17"
) ELSE IF "%1" == "21" (
    SET "JAVA_HOME=%JAVA_HOME_21%"
    SET "JAVA_VERSION=21"
) ELSE IF "%1" == "22" (
    SET "JAVA_HOME=%JAVA_HOME_22%"
    SET "JAVA_VERSION=22"
) ELSE (
    echo "Usage: switch-java <7|8|11|12|17|21|22>"
    EXIT /B 1
)

:: Update PATH environment variable
:: Get the current user PATH
set "currentUserPath=%PATH%"

:: Windows %PATH% brings in both the User PATH and System PATH, so we need to log and skip duplicates

:: Initialize a new PATH variable and a seen list to avoid duplicates
set "newPath="
set "seen="

set "newJavaPath=%JAVA_HOME%\bin"

echo.
echo Setting new JDK PATH variable to %newJavaPath%

echo.
echo User PATH variable before modification:
echo %currentUserPath%

echo.
echo Getting System PATH variable:
for %%a in ("%SystemRoot%") do set SYSTEMROOT=%%a

echo.

:: Loop through each element in the PATH
for %%a in ("%currentUserPath:;=" "%") do (
    set "item=%%~a"
    @REM echo Processing item: !item!
    if "!item:~0,21!"=="C:\Program Files\Java" (
        echo Replacing !item! with %newJavaPath%
        set "item=%newJavaPath%"
    )

    :: Check if the item is already in the seen list
    :: Brando's spicy touch, as the find command triggers on partial strings
    :: By adding a 'y' before and after the item, it will only look for exact matches
    call :CheckDuplicate "y!item!y"

    :: If the item is not a duplicate, add it to the new PATH
    if !duplicate! equ 0 (
        if defined newPath (
            set "newPath=!newPath!;!item!"
        ) else (
            set "newPath=!item!"
        )
        :: Added 'y' before and after seen item, to avoid partial matches
        set "seen=!seen!y!item!y;"
    ) else (
        echo Skipping duplicate item: !item!
    )
)

echo.
echo New User PATH generated. Now creating System PATH.
echo.

:: Now we gotta do the same for the System PATH, using the Registry
:: First, backup the system PATH. Uncomment this if you want to, but it might leave files wherever you run this
:: reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH > backup_path.txt

:: Then, read the System PATH
for /f "tokens=2* delims= " %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set SYSTEMPATH=%%b

:: Create new System PATH variable, and clear the seen list
:: I tried making this a subroutine but windows laughed in my face when it saw the PATH variable contained '(' and ')' characters.
:: If you wanna tidy this up, look for those characters in the PATH and replace them with something valid, then swap them back when you set the PATH
set "newSysPath="
set "seen="

:: Then, same deal. Loop through it, swap the jdk, and beware of duplicates (Though I've usually only seen the duplicate thing with the User PATH)
:: This could probably be a subroutine (function), but idk bash that well man
for %%a in ("%SYSTEMPATH:;=" "%") do (
    set "item=%%~a"
    if "!item:~0,21!"=="C:\Program Files\Java" (
        echo Replacing !item! with %newJavaPath%
        set "item=%newJavaPath%"
    )

    call :CheckDuplicate "y!item!y"

    if !duplicate! equ 0 (
        if defined newSysPath (
            set "newSysPath=!newSysPath!;!item!"
        ) else (
            set "newSysPath=!item!"
        )
        set "seen=!seen!y!item!y;"
    ) else (
        echo Skipping duplicate item: !item!
    )
)

echo.
echo System PATH Generated. Next, updating JAVA_HOME
echo.

:: Update the JAVA_HOME env variable
echo "Setting JAVA_HOME to %JAVA_HOME%"
echo "Updating PATH to %newPath%"
SETX JAVA_HOME "%JAVA_HOME%"
SETX -m JAVA_HOME "%JAVA_HOME%"

:: Set the User PATH
SETX PATH "%newPath%"

:: Set the System PATH
SETX PATH "%newSysPath%" /M
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "%newSysPath%" /f

:: Aside from updating the User/System PATH and the JAVA_HOME env variables, Java needs specific files in its javapath folders
:: It requires symbolic links to java.exe , javaw.exe , and javaws.exe pointing to the version of Java you want, which live in C:/Program Files/Java/jdk-21 or jdk-8 etc.
:: It also needs javac.exe and jshell.exe copied from the jdk into those javapath directories from the version of Java you want

:: Define the path to javapath directory
SET "JAVAPATH=C:\Program Files (x86)\Common Files\Oracle\Java\javapath"
SET "_JAVAPATH=C:\Program Files\Common Files\Oracle\Java\javapath"

echo.
echo Removing existing Java symbolic links

:: Remove existing symbolic links
DEL "%JAVAPATH%\java.exe"
DEL "%JAVAPATH%\javaw.exe"
DEL "%JAVAPATH%\javaws.exe"
DEL "%_JAVAPATH%\java.exe"
DEL "%_JAVAPATH%\javaw.exe"
DEL "%_JAVAPATH%\javaws.exe"

echo.
echo Creating new Java symbolic links

:: Create new symbolic links
MKLINK "%JAVAPATH%\java.exe" "%JAVA_HOME%\bin\java.exe"
MKLINK "%JAVAPATH%\javaw.exe" "%JAVA_HOME%\bin\javaw.exe"
MKLINK "%JAVAPATH%\javaws.exe" "%JAVA_HOME%\bin\javaws.exe"
MKLINK "%_JAVAPATH%\java.exe" "%JAVA_HOME%\bin\java.exe"
MKLINK "%_JAVAPATH%\javaw.exe" "%JAVA_HOME%\bin\javaw.exe"
MKLINK "%_JAVAPATH%\javaws.exe" "%JAVA_HOME%\bin\javaws.exe"

:: Copy javac.exe and jshell.exe
copy "%JAVA_HOME%\bin\javac.exe" "%JAVAPATH%\javac.exe"
copy "%JAVA_HOME%\bin\javac.exe" "%_JAVAPATH%\javac.exe"
copy "%JAVA_HOME%\bin\jshell.exe" "%JAVAPATH%\jshell.exe"
copy "%JAVA_HOME%\bin\jshell.exe" "%_JAVAPATH%\jshell.exe"

:: Update the registry keys
REG ADD "HKLM\Software\JavaSoft\Java Runtime Environment" /v CurrentVersion /d "%JAVA_VERSION%" /f
REG ADD "HKLM\Software\JavaSoft\Java Development Kit" /v CurrentVersion /d "%JAVA_VERSION%" /f

:: Show the path to the java executable
where java

echo.
echo.
echo "Switched to Java %1. Please restart the command prompt to apply changes."
ENDLOCAL
pause
goto :EOF

:CheckDuplicate
set "duplicate=0"
echo !seen! | find "!%~1!" >nul && set "duplicate=1"
goto :EOF
