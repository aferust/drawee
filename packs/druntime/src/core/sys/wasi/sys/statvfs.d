/++
    D header file correspoding to sys/statvfs.h.

    Copyright: Copyright 2012 -
    License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:   Robert Klotzner and $(HTTP jmdavisprog.com, Jonathan M Davis)
    Standards: $(HTTP http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/sys_statvfs.h.html,
                      The Open Group Base Specifications Issue 7 IEEE Std 1003.1, 2018 Edition)
 +/
module core.sys.wasi.sys.statvfs;
private import core.stdc.config;
private import core.sys.wasi.config;
public import core.sys.wasi.sys.types;

version (WebAssembly):
extern (C) :
nothrow:
@nogc:

    struct statvfs_t
    {
        c_ulong f_bsize;
        c_ulong f_frsize;
        fsblkcnt_t f_blocks;
        fsblkcnt_t f_bfree;
        fsblkcnt_t f_bavail;
        fsfilcnt_t f_files;
        fsfilcnt_t f_ffree;
        fsfilcnt_t f_favail;
        c_ulong f_fsid;
        c_ulong f_flag;
        c_ulong f_namemax;
    }

    enum FFlag
    {
        ST_RDONLY = 1,        /* Mount read-only.  */
        ST_NOSUID = 2
    }

    int statvfs (const char * file, statvfs_t* buf);
    int fstatvfs (int fildes, statvfs_t *buf) @trusted;
