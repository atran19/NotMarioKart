set VSWHERE="%ProgramFiles(x86)%/Microsoft Visual Studio/Installer/vswhere.exe"
for /f "usebackq tokens=*" %i in (`%VSWHERE% -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
    set InstallDir=%i
) 
%InstallDir%/VC/Auxiliary/Build/vcvarsall.bat x86
ml.exe /nologo /Zi /Zd /I C:\Irvine /Fe C:\Users\atran19\Desktop\NotMarioKart/bin/main.exe /W3 /errorReport:prompt /Ta C:\Users\atran19\Desktop\NotMarioKart\source\Main.asm /link /ENTRY:"main" /SUBSYSTEM:CONSOLE /LARGEADDRESSAWARE:NO C:/Irvine/Lib32/Irvine32.lib kernel32.lib User32.lib gdi32.lib
