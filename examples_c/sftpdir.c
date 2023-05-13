/*
 * Sample doing an SFTP directory listing.
 *
 * "sftpdir /tmp/secretdir"
 */

#include "hb_ssh2.h"

int main( int argc, char *argv[] )
{
   HB_SSH2_SESSION *pSess;
   char username[64];
   char password[64];
   char sftppath[128];
   char hostname[128];
   int iPort = 22;
   int iLen;
   int rc;

   if( argc > 1 )
   {
      iLen = ( (iLen = strlen(argv[1]))>128 )? 128 : iLen;
      memcpy( hostname, argv[1], iLen );
   }
   else
   {
      printf( "Hostname: " );
      fgets( hostname, 128, stdin );
      iLen = strlen( hostname ) - 1;
   }
   hostname[iLen] = '\0';
   if( !iLen )
      return 1;

   if( argc > 2 )
   {
      iLen = ( (iLen = strlen(argv[1]))>128 )? 128 : iLen;
      memcpy( hostname, argv[2], iLen );
   }
   else
   {
      printf( "Path: " );
      fgets( sftppath, 128, stdin );
      iLen = strlen( sftppath ) - 1;
   }
   sftppath[iLen] = '\0';
   if( !iLen )
   {
      memcpy( sftppath, "/home", 5 );
      sftppath[5] = '\0';
   }

   printf( "Login: " );
   fgets( username, 64, stdin );
   username[strlen( username ) - 1] = '\0';
   printf( "Password: " );
   fgets( password, 64, stdin );
   password[strlen( password ) - 1] = '\0';

   pSess = hb_ssh2_Connect( hostname, iPort, 0 );
   if( pSess->iRes != 0 )
   {
      fprintf( stderr, "Error: %d\n", pSess->iRes );
      hb_ssh2_Close( pSess );
      return -1;
   }
   else
      fprintf( stderr, "Connected. Libssh2 version: %s\n", libssh2_version( LIBSSH2_VERSION_NUM ) );

   if( hb_ssh2_LoginPass( pSess, username, password ) )
   {
      fprintf( stderr, "Authentication by password failed.\n" );
      hb_ssh2_Close( pSess );
      return -1;
   }

   hb_ssh2_SftpInit( pSess );
   if( !pSess->sftp_session )
   {
      fprintf( stderr, "Unable to init SFTP session\n" );
      hb_ssh2_Close( pSess );
      return -1;
   }

   hb_ssh2_SftpOpenDir( pSess, sftppath );
   if( !pSess->sftp_handle )
   {
      fprintf( stderr, "Unable to open dir with SFTP\n" );
      hb_ssh2_Close( pSess );
      return -1;
   }
   fprintf( stdout, "libssh2_sftp_opendir() is done, now receive listing!\n" );
   do
   {
      char mem[512];
      unsigned long ulSize;
      unsigned long ulTime;
      unsigned long ulAttrs;

      rc = hb_ssh2_SftpReadDir( pSess, mem, sizeof( mem ), &ulSize, &ulTime, &ulAttrs );
      if( rc > 0 )
      {
         printf( " %8ld %8ld %8ld ", ulSize, ulTime, ulAttrs );
         printf( "%s\n", mem );
      }
      else
         break;

   }
   while( 1 );
   fflush( stdout );

   hb_ssh2_Close( pSess );
   hb_ssh2_Exit();

   return 0;
}
