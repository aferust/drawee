/**
 * D header file for WASI.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.sys.wasi.stdio;

version (WebAssembly) {
    version = WASI;
}

version (WASI):

private import core.sys.wasi.config;
public import core.stdc.stdio;
public import core.sys.wasi.sys.types; // for off_t

extern (C):

nothrow:
@nogc:

//
// Required (defined in core.stdc.stdio)
//
/*
BUFSIZ
_IOFBF
_IOLBF
_IONBF
L_tmpnam
SEEK_CUR
SEEK_END
SEEK_SET
FILENAME_MAX
FOPEN_MAX
TMP_MAX
EOF
NULL
stderr
stdin
stdout
FILE
fpos_t
size_t

void   clearerr(FILE*);
int    fclose(FILE*);
int    feof(FILE*);
int    ferror(FILE*);
int    fflush(FILE*);
int    fgetc(FILE*);
int    fgetpos(FILE*, fpos_t *);
char*  fgets(char*, int, FILE*);
FILE*  fopen(const scope char*, const scope char*);
int    fprintf(FILE*, const scope char*, ...);
int    fputc(int, FILE*);
int    fputs(const scope char*, FILE*);
size_t fread(void *, size_t, size_t, FILE*);
FILE*  freopen(const scope char*, const scope char*, FILE*);
int    fscanf(FILE*, const scope char*, ...);
int    fseek(FILE*, c_long, int);
int    fsetpos(FILE*, const scope fpos_t*);
c_long ftell(FILE*);
size_t fwrite(in void *, size_t, size_t, FILE*);
int    getc(FILE*);
int    getchar();
char*  gets(char*);
void   perror(const scope char*);
int    printf(const scope char*, ...);
int    putc(int, FILE*);
int    putchar(int);
int    puts(const scope char*);
int    remove(const scope char*);
int    rename(const scope char*, const scope char*);
void   rewind(FILE*);
int    scanf(const scope char*, ...);
void   setbuf(FILE*, char*);
int    setvbuf(FILE*, char*, int, size_t);
int    snprintf(char*, size_t, const scope char*, ...);
int    sprintf(char*, const scope char*, ...);
int    sscanf(const scope char*, const scope char*, int ...);
FILE*  tmpfile();
char*  tmpnam(char*);
int    ungetc(int, FILE*);
int    vfprintf(FILE*, const scope char*, va_list);
int    vfscanf(FILE*, const scope char*, va_list);
int    vprintf(const scope char*, va_list);
int    vscanf(const scope char*, va_list);
int    vsnprintf(char*, size_t, const scope char*, va_list);
int    vsprintf(char*, const scope char*, va_list);
int    vsscanf(const scope char*, const scope char*, va_list arg);
*/

//
// C Extension (CX)
//
/*
L_ctermid

char*  ctermid(char*);
FILE*  fdopen(int, const scope char*);
int    fileno(FILE*);
int    fseeko(FILE*, off_t, int);
off_t  ftello(FILE*);
char*  gets(char*);
int    pclose(FILE*);
FILE*  popen(const scope char*, const scope char*);
*/

int   fseeko(FILE*, off_t, int);
off_t ftello(FILE*);

char*  ctermid(char*);
FILE*  fdopen(int, const scope char*);
int    fileno(FILE*);
//int    fseeko(FILE*, off_t, int);
//off_t  ftello(FILE*);
char*  gets(char*);
int    pclose(FILE*);
FILE*  popen(const scope char*, const scope char*);


//
// Thread-Safe Functions (TSF)
//
/*
void   flockfile(FILE*);
int    ftrylockfile(FILE*);
void   funlockfile(FILE*);
int    getc_unlocked(FILE*);
int    getchar_unlocked();
int    putc_unlocked(int, FILE*);
int    putchar_unlocked(int);
*/

//
// XOpen (XSI)
//
/*
P_tmpdir
va_list (defined in core.stdc.stdarg)

char*  tempnam(const scope char*, const scope char*);
*/

char*  tempnam(const scope char*, const scope char*);

enum P_tmpdir  = "/tmp";

ssize_t getdelim (char** lineptr, size_t* n, int delimiter, FILE* stream);
ssize_t getline (char** lineptr, size_t* n, FILE* stream);
