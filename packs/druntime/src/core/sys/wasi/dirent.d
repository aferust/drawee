/**
 * D header file for WASI.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly,
 Alex Rønne Petersn
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.sys.wasi.dirent;

private import core.sys.wasi.config;
public import core.sys.wasi.sys.types; // for ino_t

version (WebAssembly):
extern (C):
nothrow:
@nogc:

//
// Required
//
/*
  DIR

  struct dirent
  {
  char[] d_name;
  }

  int     closedir(DIR*);
  DIR*    opendir(const scope char*);
  dirent* readdir(DIR*);
  void    rewinddir(DIR*);
*/

enum
{
    DT_UNKNOWN  = 0,
    DT_FIFO     = 1,
    DT_CHR      = 2,
    DT_DIR      = 4,
    DT_BLK      = 6,
    DT_REG      = 8,
    DT_LNK      = 10,
    DT_SOCK     = 12,
    DT_WHT      = 14
}

struct dirent
{
    ino_t       d_ino;
    ubyte       d_type;
    char[256]   d_name = 0;
}

struct DIR
{
}

int     closedir(DIR*);
DIR*    opendir(const scope char*);
//dirent* readdir(DIR*);
void    rewinddir(DIR*);
static if ( __USE_FILE_OFFSET64 )
    {
        dirent* readdir64(DIR*);
        alias   readdir64 readdir;
    }
 else
     {
         dirent* readdir(DIR*);
     }
int readdir_r(DIR*, dirent*, dirent**);
void   seekdir(DIR*, c_long);
c_long telldir(DIR*);
