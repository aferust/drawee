/**
 * D header file for WASI.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly, Alex Rønne Petersen
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.sys.wasi.fcntl;

version (WebAssembly) { version = WASI; }

version (WASI):

private import core.sys.wasi.config;
private import core.stdc.stdint;
public import core.sys.wasi.sys.types; // for off_t, mode_t
public import core.sys.wasi.sys.stat;  // for S_IFMT, etc.

extern (C):
nothrow:
@nogc:

//
// Required
//
/*
  F_DUPFD
  F_GETFD
  F_SETFD
  F_GETFL
  F_SETFL
  F_GETLK
  F_SETLK
  F_SETLKW
  F_GETOWN
  F_SETOWN

  FD_CLOEXEC

  F_RDLCK
  F_UNLCK
  F_WRLCK

  O_CREAT
  O_EXCL
  O_NOCTTY
  O_TRUNC

  O_APPEND
  O_DSYNC
  O_NONBLOCK
  O_RSYNC
  O_SYNC

  O_ACCMODE
  O_RDONLY
  O_RDWR
  O_WRONLY

  struct flock
  {
  short   l_type;
  short   l_whence;
  off_t   l_start;
  off_t   l_len;
  pid_t   l_pid;
  }

  int creat(const scope char*, mode_t);
  int fcntl(int, int, ...);
  int open(const scope char*, int, ...);
*/
enum {
    O_CREAT         = 0x40,     // octal     0100
    O_EXCL          = 0x80,     // octal     0200
    O_NOCTTY        = 0x100,    // octal     0400
    O_TRUNC         = 0x200,    // octal    01000

    O_APPEND        = 0x400,    // octal    02000
    O_NONBLOCK      = 0x800,    // octal    04000
    O_DSYNC         = 0x1000,   // octal   010000
    O_SYNC          = 0x101000, // octal 04010000
    O_RSYNC         = O_SYNC,
    O_DIRECTORY     = 0x10000,
    O_NOFOLLOW      = 0x20000,
    O_CLOEXEC       = 0x80000,

    O_ASYNC         = 0x2000,
    O_DIRECT        = 0x4000,
    O_LARGEFILE     =      0,
    O_NOATIME       = 0x40000,
    O_PATH          = 0x200000,
    O_TMPFILE       = 0x410000,
    O_NDELAY        = O_NONBLOCK,
    O_SEARCH        = O_PATH,
    O_EXEC          = O_PATH,

    O_ACCMODE       = (03|O_SEARCH),
    O_RDONLY        = 00,
    O_WRONLY        = 01,
    O_RDWR          = 02,
}
enum {
    F_DUPFD        = 0,
    F_GETFD        = 1,
    F_SETFD        = 2,
    F_GETFL        = 3,
    F_SETFL        = 4,
    F_GETLK        = 5,
    F_SETLK        = 6,
    F_SETLKW       = 7,
    F_SETOWN       = 8,
    F_GETOWN       = 9,
}
enum {
    F_RDLCK        = 0,
    F_WRLCK        = 1,
    F_UNLCK        = 2,
}
struct flock
{
    short   l_type;
    short   l_whence;
    off_t   l_start;
    off_t   l_len;
    pid_t   l_pid;
}
enum FD_CLOEXEC     = 1;
int open(const scope char*, int, ...);

enum AT_FDCWD = -100;

//int creat(const scope char*, mode_t);
int fcntl(int, int, ...);
//int open(const scope char*, int, ...);

// Generic Posix fallocate
int posix_fallocate(int, off_t, off_t);

//
// Advisory Information (ADV)
//
/*
  POSIX_FADV_NORMAL
  POSIX_FADV_SEQUENTIAL
  POSIX_FADV_RANDOM
  POSIX_FADV_WILLNEED
  POSIX_FADV_DONTNEED
  POSIX_FADV_NOREUSE

  int posix_fadvise(int, off_t, off_t, int);
*/
