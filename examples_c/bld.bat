@rem Uncomment two following lines to create libssh.a for the first time
@rem gendef libssh2.dll
@rem dlltool -v --dllname libssh2.dll --def libssh2.def --output-lib libssh2.a
@rem 
@set SDIR=..\source

gcc -I %SDIR% -Wall -c %1.c %SDIR%\hb_ssh2.c
gcc -Wall -o%1.exe %1.o hb_ssh2.o -L. -Wl,--allow-multiple-definition -Wl,--start-group -luser32 -lwinspool -lcomctl32 -lcomdlg32 -lgdi32 -lole32 -loleaut32 -luuid -lwinmm -lwsock32 -lssh2 -Wl,--end-group

@del *.o
