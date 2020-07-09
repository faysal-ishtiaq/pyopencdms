ECHO OFF
IF "%1" == "" GOTO BADCMD
MASM /C /L /V /W2 /Z %1;
IF ERRORLEVEL 1 GOTO ERROR
echo on
CREF %1.CRF;
LIB C:\CLICOM\LIB\ASM -+%1;
GOTO DONE
:BADCMD
ECHO Please specify the assembler routine name...
SOUND B
GOTO DONE
:ERROR
ECHO *** Compile error ***
SOUND B
SOUND B
GOTO EXIT
:DONE
REM PRINT %1.LST
REM PRINT %1.REF
:EXIT
