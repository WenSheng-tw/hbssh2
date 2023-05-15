/*
 * Sample showing how to do SFTP write transfers.

 * "sftp 192.168.0.1"
 */

#include "hb_ssh2.h"

int main( int argc, char *argv[] )
{
   HB_SSH2_SESSION *pSess;
   char username[64];
   char password[64];
   char sftppath[128];
   char hostname[128];
   const char *loclfile = "sftp_write.c";
   int iPort = 22;
   int iLen;

   int rc;
   FILE *local;
   char mem[1024 * 100];
   size_t nread;

   if( argc > 1 )
   {
      iLen = ( ( iLen = strlen( argv[1] ) ) > 128 ) ? 128 : iLen;
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
      iLen = ( ( iLen = strlen( argv[1] ) ) > 128 ) ? 128 : iLen;
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
      fprintf( stderr, "Connected. Libssh2 version: %s\n",
            libssh2_version( LIBSSH2_VERSION_NUM ) );

   if( hb_ssh2_LoginPass( pSess, username, password ) )
   {
      fprintf( stderr, "Authentication by password failed.\n" );
      hb_ssh2_Close( pSess );
      return -1;
   }

   local = fopen( loclfile, "rb" );
   if( !local )
   {
      fprintf( stderr, "Can't open local file %s\n", loclfile );
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

   fprintf( stderr, "libssh2_sftp_open()!\n" );
   /* Request a file via SFTP */
   if( hb_ssh2_SftpOpenFile( pSess, sftppath,
               LIBSSH2_FXF_WRITE | LIBSSH2_FXF_CREAT | LIBSSH2_FXF_TRUNC,
               LIBSSH2_SFTP_S_IRUSR | LIBSSH2_SFTP_S_IWUSR |
               LIBSSH2_SFTP_S_IRGRP | LIBSSH2_SFTP_S_IROTH ) )
   {
      fprintf( stderr, "Unable to open file with SFTP\n" );
      hb_ssh2_Close( pSess );
      return -1;
   }
   fprintf( stderr, "libssh2_sftp_open() is done, now send data!\n" );
   do
   {
      nread = fread( mem, 1, sizeof( mem ), local );
      if( nread <= 0 )
      {
         /* end of file */
         break;
      }
      rc = hb_ssh2_SftpWrite( pSess, mem, nread );
   }
   while( rc > 0 );

   hb_ssh2_Close( pSess );
   hb_ssh2_Exit(  );

   return 0;
}
