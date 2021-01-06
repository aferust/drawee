/**
 * D header file for WASI.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly,
 Alex Rønne Petersen
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.sys.wasi.config;

public import core.stdc.config;


version (WebAssembly):
extern (C) nothrow @nogc:

enum _XOPEN_SOURCE     = 600;
enum _POSIX_SOURCE     = true;
enum _POSIX_C_SOURCE   = 200112L;

enum _FILE_OFFSET_BITS   = 64;

enum __REDIRECT          = false;

enum __USE_FILE_OFFSET64 = _FILE_OFFSET_BITS == 64;
enum __USE_LARGEFILE     = __USE_FILE_OFFSET64 && !__REDIRECT;
enum __USE_LARGEFILE64   = __USE_FILE_OFFSET64 && !__REDIRECT;

enum __WORDSIZE=64;
