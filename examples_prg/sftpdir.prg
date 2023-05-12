FUNCTION Main( cAddr, cDir )

   LOCAL pSess, nPort, cLogin, cPass, nPos
   LOCAL cName, nAttr, nSize, dDate

   IF cAddr == Nil
      ACCEPT "Address:" TO cAddr
   ENDIF
   IF cAddr == Nil
      RETURN Nil
   ENDIF

   IF cDir == Nil
      ACCEPT "Directory (default: /home):" TO cDir
   ENDIF
   IF Empty(cDir)
      cDir := "/home"
   ENDIF

   ACCEPT "Login:" TO cLogin
   ACCEPT "Password:" TO cPass

   IF ( nPos := At( ':', cAddr ) ) > 0
      nPort := Val( Substr( cAddr,nPos+1 ) )
      cAddr := Left( cAddr,nPos-1 )
   ENDIF

   pSess := ssh2_Init( cAddr, nPort )

   IF ssh2_LastErr( pSess ) != 0
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

   IF ssh2_Sftp_Init( pSess ) == 0 .AND. ;
      ssh2_Sftp_OpenDir( pSess, cDir ) == 0
      ? cDir + " opened"
      ? "-----"
      DO WHILE !Empty( cName := ssh2_Sftp_ReadDir( pSess, @nSize, @dDate, @nAttr ) )
         ? nSize, hb_strShrink( hb_ttoc(dDate),4 ), nAttr, cName
      ENDDO
      ? "-----"
   ELSE
      ? "ftpInit failed"
   ENDIF

   ssh2_Close( pSess )

   RETURN Nil
