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
module core.sys.wasi.sys.stat;

private import core.sys.wasi.config;
private import core.stdc.stdint;
private import core.sys.wasi.time;     // for timespec
public import core.sys.wasi.sys.types; // for off_t, mode_t

version (WebAssembly)
version = WASI;

version (WASI):
extern (C) nothrow @nogc:

//
// Required
//
/*
  struct stat
  {
  dev_t   st_dev;
  ino_t   st_ino;
  mode_t  st_mode;
  nlink_t st_nlink;
  uid_t   st_uid;
  gid_t   st_gid;
  off_t   st_size;
  time_t  st_atime;
  time_t  st_mtime;
  time_t  st_ctime;
  }

  S_IRWXU
  S_IRUSR
  S_IWUSR
  S_IXUSR
  S_IRWXG
  S_IRGRP
  S_IWGRP
  S_IXGRP
  S_IRWXO
  S_IROTH
  S_IWOTH
  S_IXOTH
  S_ISUID
  S_ISGID
  S_ISVTX

  S_ISBLK(m)
  S_ISCHR(m)
  S_ISDIR(m)
  S_ISFIFO(m)
  S_ISREG(m)
  S_ISLNK(m)
  S_ISSOCK(m)

  S_TYPEISMQ(buf)
  S_TYPEISSEM(buf)
  S_TYPEISSHM(buf)

  int    chmod(const scope char*, mode_t);
  int    fchmod(int, mode_t);
  int    fstat(int, stat*);
  int    lstat(const scope char*, stat*);
  int    mkdir(const scope char*, mode_t);
  int    mkfifo(const scope char*, mode_t);
  int    stat(const scope char*, stat*);
  mode_t umask(mode_t);
*/

alias __mode_t = uint;
enum {
    S_IRUSR    = 0x100, // octal 0400
    S_IWUSR    = 0x080, // octal 0200
    S_IXUSR    = 0x040, // octal 0100
    S_IRWXU    = S_IRUSR | S_IWUSR | S_IXUSR,

    S_IRGRP    = S_IRUSR >> 3,
    S_IWGRP    = S_IWUSR >> 3,
    S_IXGRP    = S_IXUSR >> 3,
    S_IRWXG    = S_IRWXU >> 3,

    S_IROTH    = S_IRGRP >> 3,
    S_IWOTH    = S_IWGRP >> 3,
    S_IXOTH    = S_IXGRP >> 3,
    S_IRWXO    = S_IRWXG >> 3,

    S_ISUID    = 0x800, // octal 04000
    S_ISGID    = 0x400, // octal 02000
    S_ISVTX    = 0x200, // octal 01000
}
struct stat_t {
    dev_t st_dev;
    ino_t st_ino;
    nlink_t st_nlink;

    mode_t st_mode;
    uid_t st_uid;
    gid_t st_gid;
    uint    __pad0;
    dev_t st_rdev;
    off_t st_size;
    blksize_t st_blksize;
    blkcnt_t st_blocks;

    timespec st_atim;
    timespec st_mtim;
    timespec st_ctim;
    extern(D) @safe @property inout pure nothrow
    {
        ref inout(time_t) st_atime() return { return st_atim.tv_sec; }
        ref inout(time_t) st_mtime() return { return st_mtim.tv_sec; }
        ref inout(time_t) st_ctime() return { return st_ctim.tv_sec; }
    }
    long[3] __unused;
}
private
    {
        extern (D) bool S_ISTYPE( mode_t mode, uint mask )
        {
            return ( mode & S_IFMT ) == mask;
        }
    }

extern (D) bool S_ISBLK( mode_t mode )  { return S_ISTYPE( mode, S_IFBLK );  }
extern (D) bool S_ISCHR( mode_t mode )  { return S_ISTYPE( mode, S_IFCHR );  }
extern (D) bool S_ISDIR( mode_t mode )  { return S_ISTYPE( mode, S_IFDIR );  }
extern (D) bool S_ISFIFO( mode_t mode ) { return S_ISTYPE( mode, S_IFIFO );  }
extern (D) bool S_ISREG( mode_t mode )  { return S_ISTYPE( mode, S_IFREG );  }
extern (D) bool S_ISLNK( mode_t mode )  { return S_ISTYPE( mode, S_IFLNK );  }
extern (D) bool S_ISSOCK( mode_t mode ) { return S_ISTYPE( mode, S_IFSOCK ); }

int utimensat(int dirfd, const char *pathname,
              ref const(timespec)[2] times, int flags);

int    chmod(const scope char*, mode_t);
int    fchmod(int, mode_t);
//int    fstat(int, stat_t*);
//int    lstat(const scope char*, stat_t*);
int    mkdir(const scope char*, mode_t);
int    mkfifo(const scope char*, mode_t);
//int    stat(const scope char*, stat_t*);
mode_t umask(mode_t);

int stat(const scope char*, stat_t*);
int fstat(int, stat_t*);
int lstat(const scope char*, stat_t*);

alias fstat fstat64;
alias lstat lstat64;
alias stat stat64;
//
// Typed Memory Objects (TYM)
//
/*
  S_TYPEISTMO(buf)
*/

//
// XOpen (XSI)
//
/*
  S_IFMT
  S_IFBLK
  S_IFCHR
  S_IFIFO
  S_IFREG
  S_IFDIR
  S_IFLNK
  S_IFSOCK

  int mknod(in 3char*, mode_t, dev_t);
*/

enum {
    S_IFMT     = 0xF000, // octal 0170000
    S_IFBLK    = 0x6000, // octal 0060000
    S_IFCHR    = 0x2000, // octal 0020000
    S_IFIFO    = 0x1000, // octal 0010000
    S_IFREG    = 0x8000, // octal 0100000
    S_IFDIR    = 0x4000, // octal 0040000
    S_IFLNK    = 0xA000, // octal 0120000
    S_IFSOCK   = 0xC000, // octal 0140000
}

int mknod(const scope char*, mode_t, dev_t);
