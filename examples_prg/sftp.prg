/*
 * Sample showing SFTP download
 */

#include "fileio.ch"

STATIC nOut := 0

FUNCTION Main( cAddr, cFileName )

   LOCAL pSess, pHandle, nPort, cLogin, cPass, nPos
   LOCAL handle, cBuff

   IF cAddr == Nil
      ACCEPT "Address:" TO cAddr
   ENDIF
   IF cAddr == Nil
      RETURN Nil
   ENDIF

   IF cFileName == Nil
      ACCEPT "File to download:" TO cFileName
   ENDIF
   IF Empty(cFileName)
      RETURN Nil
   ENDIF

   ACCEPT "Login:" TO cLogin
   ACCEPT "Password:" TO cPass

   IF ( nPos := At( ':', cAddr ) ) > 0
      nPort := Val( Substr( cAddr,nPos+1 ) )
      cAddr := Left( cAddr,nPos-1 )
   ENDIF

   // Testing non blocking mode
   ssh2_SetCallback( "TEST_CLB" )
   pSess := ssh2_Connect( cAddr, nPort, .T. )

   IF ssh2_LastRes( pSess ) != 0
      ? "Connection error"
      ssh2_Close( pSess )
      RETURN Nil
   ELSE
      ? "Connected"
   ENDIF

   IF ssh2_Login( pSess, cLogin, cPass )
      ? "Login - Ok"
   ELSE
      ? "Can't login..."
      ssh2_Close( pSess )
      RETURN Nil
   ENDIF

   IF ssh2_Sftp_Init( pSess ) == 0
      IF !Empty( pHandle := ssh2_Sftp_OpenFile( pSess, cFileName ) )
         ? cFileName + " opened"
         ?
         handle := fOpen( hb_fnameNameExt(cFileName), FO_WRITE+FO_CREAT+FO_TRUNC )
         DO WHILE !Empty( cBuff := ssh2_Sftp_Read( pHandle ) )
            fWrite( handle, cBuff )
            ?? "."
         ENDDO
         fClose( handle )
         ? "Done!"
         ssh2_Sftp_Close( pHandle )
      ELSE
         ? "Can't open " + cFileName
      ENDIF
   ELSE
      ? "ftpInit failed"
   ENDIF

   ssh2_Close( pSess )
   ssh2_Exit()
   ? nOut

   RETURN Nil

FUNCTION Test_CLB

   nOut ++

   RETURN 1
