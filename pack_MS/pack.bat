@echo off

REM =====================================================================
REM create <outDir>\gCAD3D-<version>.exe

REM active directory: gcad3d\pack_MS
REM Zielverzeichnis (wird vorher geloescht !!)
REM bin & doc & icons (SrcDir in gCAD3D.nsi)
REM set outDirP=H:\gCAD3D\Prg
set outDirP=%TEMP%\gCAD3D\Prg

REM dat & tmp
REM set outDirD=H:\gCAD3D\Dat\gCAD3D
set outDirD=%TEMP%\gCAD3D\Dat\gCAD3D

REM source of programs (binDirIn)
REM set srcDir=C:\Devel\gCAD3D\
set srcDir=..\src\

REM binDir = subdir of outDirP and of %srcDir%
set binDir=binMS32
set binDirIn=..\%binDir%
set datDirIn=..\gCAD3D

REM del %srcDir%%binDir%\tst*

REM Version
set /p swVers= < ..\src\gcad_version
set osVer=win32

set packer=%ProgramFiles%\NSIS\MakeNSIS.exe

if not exist %packer% (
  echo File %packer% does not exist; install and fix path.
  goto Fertig
)


set packNam=gCAD3D-%swVers%-%osVer%
echo Create Package %packNam%
echo outDirP=%outDirP%
echo outDirD=%outDirD%



if exist %outDirP% (
  echo Dir %outDirP% existiert bereits - wird geloescht.
)

if exist %outDirD% (
  echo Dir %outDirD% existiert bereits - wird geloescht.
)



rmdir/s /q %outDirP%
rmdir/s /q %outDirD%



mkdir %outDirP%
mkdir %outDirP%\%binDir%
mkdir %outDirP%\%binDir%\plugins
mkdir %outDirP%\%binDir%\plugins\cut1
mkdir %outDirP%\doc
mkdir %outDirP%\doc\html
mkdir %outDirP%\doc\msg
mkdir %outDirP%\icons

mkdir %outDirD%

mkdir %outDirD%\tmp
mkdir %outDirD%\dat
mkdir %outDirD%\prg
mkdir %outDirD%\cfg
mkdir %outDirD%\ctlg
mkdir %outDirD%\Schrau
mkdir %outDirD%\Profile
mkdir %outDirD%\symEl1



REM copy -> baseDir
copy gCAD3D.ico                  %outDirP%\.
copy unInstall.ico               %outDirP%\.
copy ..\doc\gCAD3D_MS-Win.txt    %outDirP%\doc\.




REM GTK_runtime, gcad-exe, gcad-dll's, plugins
echo xcopy /s %binDirIn%        %outDirP%\%binDir%
xcopy /s %binDirIn%        %outDirP%\%binDir%



REM copy doc
copy ..\doc\html\*.htm           %outDirP%\doc\html\.
copy ..\doc\html\*.png           %outDirP%\doc\html\.
copy ..\doc\html\*.js            %outDirP%\doc\html\.
copy ..\doc\msg\*.txt            %outDirP%\doc\msg\.


REM copy icons
copy ..\icons\*                  %outDirP%\icons\.



REM copy -> cfg
copy %datDirIn%\cfg\*                    %outDirD%\cfg\.


REM this files must be created:
del %outDirD%\cfg\xa.rc
del %outDirD%\cfg\dir.lst


REM copy progs, catalog ..
copy %datDirIn%\prg\*                    %outDirD%\prg\.
copy %datDirIn%\ctlg\*                   %outDirD%\ctlg\.
copy %datDirIn%\Schrau\*                 %outDirD%\Schrau\.
copy %datDirIn%\Profile\*                %outDirD%\Profile\.
copy %datDirIn%\symEl1\*                 %outDirD%\symEl1\.


REM copy Demomodelle -> dat
copy %datDirIn%\dat\Renault1.gcad        %outDirD%\dat\.
copy %datDirIn%\dat\Haus*.*              %outDirD%\dat\.
copy %datDirIn%\dat\DachWS4.jpg          %outDirD%\dat\.
copy %datDirIn%\dat\SteinMarmor1.jpg     %outDirD%\dat\.
copy %datDirIn%\dat\samp*.*              %outDirD%\dat\.
copy %datDirIn%\dat\Niet1.gcad           %outDirD%\dat\.
copy %datDirIn%\dat\Schrau1.gcad         %outDirD%\dat\.


REM Startmodell 
copy %datDirIn%\dat\sample_activity_modval_1.gcad     %outDirD%\tmp\Model


REM if %1 == free goto L_packStart
REM copy ..\pp\FanucA.exe %outDirP%\pp\.
REM copy ..\pp\AgiEvo.exe %outDirP%\pp\.



REM -----------------------------------------------------
:L_packStart
echo ========================================
echo ALLE FILES nach %outDirP% %outDirD% kopiert
echo ========================================


REM create package with NSIS-Installer
%packer% gCAD3D.nsi

REM echo "copy/y %packNam%.exe X:\."
REM copy/y %packNam%.exe X:\.

goto :Fertig






REM ======================================================
REM save active dir und goto outDir; retour m popd
set outDir=d:\gCAD3D
pushd  %outDir%
cd ..
REM mit cabarc ein package gCAD3D.cab machen
echo cabarc -r n gCAD.cab -r %outDir%\*
cabarc -r -p n gCAD.cab %outDir%\*
move gCAD.cab  %outDir%\.




REM Datei inst_files generieren
REM Datenzeileformat: Level Typ; Level=gehoert zum gleichen Installationslauf;
REM   Typ 0=Info, 1=Size in byte, 2=Filename
cd  %outDir%
echo %packNam%.exe> inst_files
echo inst_inst.exe>> inst_files
echo   1  0 Install gCAD3D>> inst_files
echo   1  1 3000000>> inst_files
echo   1  2 gCAD.cab>> inst_files
echo   1  2 xa_inst.exe>> inst_files
echo   1  2 Install.bat>> inst_files
echo   2  0 Uninstall gCAD3D>> inst_files
echo   2  1 10000>> inst_files
echo   2  2 Uninstall.bat>> inst_files
echo   3  0 Enter to exit>> inst_files
echo   3  3 exit>> inst_files



REM Installpackage generieren
popd
copy ..\inst\inst_inst.exe   %outDir%\.
copy ..\inst\inst_pack.exe   %outDir%\.
pushd  %outDir%
inst_pack.exe



REM zurueck ..
popd
echo .
echo "===============>>>>>" %outDir%\%packNam%.exe created "<<<<<<<<========"
goto :Fertig




REM ============= Errors ======================
:inperr
echo free (keine PP's) oder all (mit allen PP's)
goto Fertig

:noinpfilerr
echo Dateiliste %TMP%\srcfiles.txt nicht gefunden.
goto Fertig



:Fertig
REM EOF
