@set HB_INS=c:\harbour
@rem 
@rem Uncomment two following lines to create libssh.a for the first time
@rem gendef libssh2.dll 2>dummy
@rem dlltool -v --dllname libssh2.dll --def libssh2.def --output-lib libssh2.a 2>dummy
@rem 
@set SDIR=..\source
@set HB_LIBS=-lhbvm -lhbrdd -lhbmacro -lhbpp -lhbrtl -lhbcpage -lhblang -lhbcommon -lrddntx  -lrddcdx -lrddfpt -lhbsix -lgtgui -lgtwin -lhbcplr

%HB_INS%\bin\harbour %1.prg /n /q -I%HB_INS%\include

gcc -I%HB_INS%\include -D_USE_HB -c %1.c %SDIR%\hb_ssh2.c
gcc -Wall -o%1.exe %1.o hb_ssh2.o -L. -L%HB_INS%\lib\win\mingw -Wl,--allow-multiple-definition -Wl,--start-group %HB_LIBS% -luser32 -lwinspool -lcomctl32 -lcomdlg32 -lgdi32 -lole32 -loleaut32 -luuid -lwinmm -lwsock32 -lssh2 -Wl,--end-group

@del *.o
@del %1.c