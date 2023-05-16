FUNCTION Main( cAddr, cCmd )

   LOCAL pSess, nPort, cLogin, cPass, nPos
   LOCAL cRes

   IF cAddr == Nil
      ACCEPT "Address:" TO cAddr
   ENDIF
   IF cAddr == Nil
      RETURN Nil
   ENDIF

   IF cCmd == Nil
      ACCEPT "Command (default: uptime):" TO cCmd
   ENDIF
   IF Empty(cCmd)
      cCmd := "uptime"
   ENDIF

   ACCEPT "Login:" TO cLogin
   ACCEPT "Password:" TO cPass

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

   ssh2_Channel_Open( pSess )

   IF ssh2_LastRes( pSess ) == 0
      ? "> " + cCmd
      ssh2_Exec( pSess, cCmd )
      IF ssh2_LastRes( pSess ) == 0
         IF !Empty( cRes := ssh2_Channel_Read( pSess ) )
            ? cRes
         ENDIF
      ENDIF
   ELSE
      ? "OpenChannel failed"
   ENDIF

   ssh2_Close( pSess )
   ssh2_Exit()

   RETURN Nil
