/*
 * Sample showing SFTP upload
 */

#include "fileio.ch"
#include "hbssh2.ch"

FUNCTION Main( cAddr, cFileName )

   LOCAL pSess, nPort, cLogin, cPass, nPos, cPath
   LOCAL cBuff

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

   IF ( nPos := At( '/', cAddr ) ) > 0
      cPath := Substr( cAddr, nPos )
      cAddr := Left( cAddr,nPos-1 )
      IF Right( cPath,1 ) != '/'
         cPath += '/'
      ENDIF
   ELSE
      cPath := "/tmp/"
   ENDIF
   cPath += hb_fnameNameExt( cFileName )

   IF ( nPos := At( ':', cAddr ) ) > 0
      nPort := Val( Substr( cAddr,nPos+1 ) )
      cAddr := Left( cAddr,nPos-1 )
   ENDIF

   pSess := ssh2_Connect( cAddr, nPort )

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
      IF ssh2_Sftp_OpenFile( pSess, cPath, LIBSSH2_FXF_WRITE + LIBSSH2_FXF_CREAT, ;
               LIBSSH2_SFTP_S_IRUSR + LIBSSH2_SFTP_S_IWUSR + ;
               LIBSSH2_SFTP_S_IRGRP + LIBSSH2_SFTP_S_IROTH ) == 0
         ? cFileName + " created"
         cBuff := Memoread( cFileName )
         ssh2_SFtpWrite( pSess, cBuff )
         ? "Done!"
         ssh2_Sftp_Close( pSess )
      ELSE
         ? "Can't open " + cFileName
      ENDIF
   ELSE
      ? "ftpInit failed"
   ENDIF

   ssh2_Close( pSess )
   ssh2_Exit()

   RETURN Nil
