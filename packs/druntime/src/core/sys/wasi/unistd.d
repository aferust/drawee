/**
 * D header file for WASI.
 *
 * Copyright: Copyright Sebastiaan Koppe 2019 - 2020.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sebastiaan Koppe
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*        Copyright Sebastiaan Koppe 2019 - 2020.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.sys.wasi.unistd;

version (WebAssembly) { version = WASI; }

version (WASI):

private import core.sys.wasi.config;
private import core.stdc.stddef;
// public import core.sys.wasi.inttypes;  // for intptr_t
public import core.sys.wasi.sys.types; // for ssize_t, uid_t, gid_t, off_t, pid_t, useconds_t

extern (C):
nothrow:
@nogc:

enum STDIN_FILENO  = 0;
enum STDOUT_FILENO = 1;
enum STDERR_FILENO = 2;

extern __gshared char*   optarg;
extern __gshared int     optind;
extern __gshared int     opterr;
extern __gshared int     optopt;

int     access(const scope char*, int);
uint    alarm(uint) @trusted;
int     chdir(const scope char*);
int     chown(const scope char*, uid_t, gid_t);
int     close(int) @trusted;
size_t  confstr(int, char*, size_t);
int     dup(int) @trusted;
int     dup2(int, int) @trusted;
int     execl(const scope char*, const scope char*, ...);
int     execle(const scope char*, const scope char*, ...);
int     execlp(const scope char*, const scope char*, ...);
int     execv(const scope char*, const scope char**);
int     execve(const scope char*, const scope char**, const scope char**);
int     execvp(const scope char*, const scope char**);
void    _exit(int) @trusted;
int     fchown(int, uid_t, gid_t) @trusted;
pid_t   fork() @trusted;
c_long  fpathconf(int, int) @trusted;
//int     ftruncate(int, off_t);
char*   getcwd(char*, size_t);
gid_t   getegid() @trusted;
uid_t   geteuid() @trusted;
gid_t   getgid() @trusted;
int     getgroups(int, gid_t *);
int     gethostname(char*, size_t);
char*   getlogin() @trusted;
int     getlogin_r(char*, size_t);
int     getopt(int, const scope char**, const scope char*);
pid_t   getpgrp() @trusted;
pid_t   getpid() @trusted;
pid_t   getppid() @trusted;
uid_t   getuid() @trusted;
int     isatty(int) @trusted;
int     link(const scope char*, const scope char*);
//off_t   lseek(int, off_t, int);
c_long  pathconf(const scope char*, int);
int     pause() @trusted;
int     pipe(ref int[2]) @trusted;
ssize_t read(int, void*, size_t);
ssize_t readlink(const scope char*, char*, size_t);
int     rmdir(const scope char*);
int     setegid(gid_t) @trusted;
int     seteuid(uid_t) @trusted;
int     setgid(gid_t) @trusted;
int     setgroups(size_t, const scope gid_t*) @trusted;
int     setpgid(pid_t, pid_t) @trusted;
pid_t   setsid() @trusted;
int     setuid(uid_t) @trusted;
uint    sleep(uint) @trusted;
int     symlink(const scope char*, const scope char*);
c_long  sysconf(int) @trusted;
pid_t   tcgetpgrp(int) @trusted;
int     tcsetpgrp(int, pid_t) @trusted;
char*   ttyname(int) @trusted;
int     ttyname_r(int, char*, size_t);
int     unlink(const scope char*);
ssize_t write(int, const scope void*, size_t);

int ftruncate(int, off_t) @trusted;
off_t lseek(int, off_t, int) @trusted;
alias ftruncate ftruncate64;
alias lseek lseek64;
enum F_OK       = 0;
enum R_OK       = 4;
enum W_OK       = 2;
enum X_OK       = 1;

enum F_ULOCK    = 0;
enum F_LOCK     = 1;
enum F_TLOCK    = 2;
enum F_TEST     = 3;

enum
    {
        _CS_PATH,
        _CS_POSIX_V6_WIDTH_RESTRICTED_ENVS,
        _CS_GNU_LIBC_VERSION,
        _CS_GNU_LIBPTHREAD_VERSION,
        _CS_POSIX_V5_WIDTH_RESTRICTED_ENVS,
        _CS_POSIX_V7_WIDTH_RESTRICTED_ENVS,

        _CS_POSIX_V6_ILP32_OFF32_CFLAGS = 1116,
        _CS_POSIX_V6_ILP32_OFF32_LDFLAGS,
        _CS_POSIX_V6_ILP32_OFF32_LIBS,
        _CS_POSIX_V6_ILP32_OFF32_LINTFLAGS,
        _CS_POSIX_V6_ILP32_OFFBIG_CFLAGS,
        _CS_POSIX_V6_ILP32_OFFBIG_LDFLAGS,
        _CS_POSIX_V6_ILP32_OFFBIG_LIBS,
        _CS_POSIX_V6_ILP32_OFFBIG_LINTFLAGS,
        _CS_POSIX_V6_LP64_OFF64_CFLAGS,
        _CS_POSIX_V6_LP64_OFF64_LDFLAGS,
        _CS_POSIX_V6_LP64_OFF64_LIBS,
        _CS_POSIX_V6_LP64_OFF64_LINTFLAGS,
        _CS_POSIX_V6_LPBIG_OFFBIG_CFLAGS,
        _CS_POSIX_V6_LPBIG_OFFBIG_LDFLAGS,
        _CS_POSIX_V6_LPBIG_OFFBIG_LIBS,
        _CS_POSIX_V6_LPBIG_OFFBIG_LINTFLAGS,
        _CS_POSIX_V7_ILP32_OFF32_CFLAGS,
        _CS_POSIX_V7_ILP32_OFF32_LDFLAGS,
        _CS_POSIX_V7_ILP32_OFF32_LIBS,
        _CS_POSIX_V7_ILP32_OFF32_LINTFLAGS,
        _CS_POSIX_V7_ILP32_OFFBIG_CFLAGS,
        _CS_POSIX_V7_ILP32_OFFBIG_LDFLAGS,
        _CS_POSIX_V7_ILP32_OFFBIG_LIBS,
        _CS_POSIX_V7_ILP32_OFFBIG_LINTFLAGS,
        _CS_POSIX_V7_LP64_OFF64_CFLAGS,
        _CS_POSIX_V7_LP64_OFF64_LDFLAGS,
        _CS_POSIX_V7_LP64_OFF64_LIBS,
        _CS_POSIX_V7_LP64_OFF64_LINTFLAGS,
        _CS_POSIX_V7_LPBIG_OFFBIG_CFLAGS,
        _CS_POSIX_V7_LPBIG_OFFBIG_LDFLAGS,
        _CS_POSIX_V7_LPBIG_OFFBIG_LIBS,
        _CS_POSIX_V7_LPBIG_OFFBIG_LINTFLAGS,
        _CS_V6_ENV,
        _CS_V7_ENV
    }

enum
    {
        _PC_LINK_MAX,
        _PC_MAX_CANON,
        _PC_MAX_INPUT,
        _PC_NAME_MAX,
        _PC_PATH_MAX,
        _PC_PIPE_BUF,
        _PC_CHOWN_RESTRICTED,
        _PC_NO_TRUNC,
        _PC_VDISABLE,
        _PC_SYNC_IO,
        _PC_ASYNC_IO,
        _PC_PRIO_IO,
        _PC_SOCK_MAXBUF,
        _PC_FILESIZEBITS,
        _PC_REC_INCR_XFER_SIZE,
        _PC_REC_MAX_XFER_SIZE,
        _PC_REC_MIN_XFER_SIZE,
        _PC_REC_XFER_ALIGN,
        _PC_ALLOC_SIZE_MIN,
        _PC_SYMLINK_MAX,
        _PC_2_SYMLINKS
    }

enum
    {
        _SC_ARG_MAX,
        _SC_CHILD_MAX,
        _SC_CLK_TCK,
        _SC_NGROUPS_MAX,
        _SC_OPEN_MAX,
        _SC_STREAM_MAX,
        _SC_TZNAME_MAX,
        _SC_JOB_CONTROL,
        _SC_SAVED_IDS,
        _SC_REALTIME_SIGNALS,
        _SC_PRIORITY_SCHEDULING,
        _SC_TIMERS,
        _SC_ASYNCHRONOUS_IO,
        _SC_PRIORITIZED_IO,
        _SC_SYNCHRONIZED_IO,
        _SC_FSYNC,
        _SC_MAPPED_FILES,
        _SC_MEMLOCK,
        _SC_MEMLOCK_RANGE,
        _SC_MEMORY_PROTECTION,
        _SC_MESSAGE_PASSING,
        _SC_SEMAPHORES,
        _SC_SHARED_MEMORY_OBJECTS,
        _SC_AIO_LISTIO_MAX,
        _SC_AIO_MAX,
        _SC_AIO_PRIO_DELTA_MAX,
        _SC_DELAYTIMER_MAX,
        _SC_MQ_OPEN_MAX,
        _SC_MQ_PRIO_MAX,
        _SC_VERSION,
        _SC_PAGE_SIZE,
        _SC_PAGESIZE = _SC_PAGE_SIZE,
        _SC_RTSIG_MAX,
        _SC_SEM_NSEMS_MAX,
        _SC_SEM_VALUE_MAX,
        _SC_SIGQUEUE_MAX,
        _SC_TIMER_MAX,
        _SC_BC_BASE_MAX,
        _SC_BC_DIM_MAX,
        _SC_BC_SCALE_MAX,
        _SC_BC_STRING_MAX,
        _SC_COLL_WEIGHTS_MAX,

        _SC_EXPR_NEST_MAX = 42,
        _SC_LINE_MAX,
        _SC_RE_DUP_MAX,

        _SC_2_VERSION = 46,
        _SC_2_C_BIND,
        _SC_2_C_DEV,
        _SC_2_FORT_DEV,
        _SC_2_FORT_RUN,
        _SC_2_SW_DEV,
        _SC_2_LOCALEDEF,

        _SC_UIO_MAXIOV = 60,
        _SC_IOV_MAX = _SC_UIO_MAXIOV,

        _SC_THREADS = 67,
        _SC_THREAD_SAFE_FUNCTIONS,
        _SC_GETGR_R_SIZE_MAX,
        _SC_GETPW_R_SIZE_MAX,
        _SC_LOGIN_NAME_MAX,
        _SC_TTY_NAME_MAX,
        _SC_THREAD_DESTRUCTOR_ITERATIONS,
        _SC_THREAD_KEYS_MAX,
        _SC_THREAD_STACK_MIN,
        _SC_THREAD_THREADS_MAX,
        _SC_THREAD_ATTR_STACKADDR,
        _SC_THREAD_ATTR_STACKSIZE,
        _SC_THREAD_PRIORITY_SCHEDULING,
        _SC_THREAD_PRIO_INHERIT,
        _SC_THREAD_PRIO_PROTECT,
        _SC_THREAD_PROCESS_SHARED,

        _SC_NPROCESSORS_CONF,
        _SC_NPROCESSORS_ONLN,
        _SC_PHYS_PAGES,
        _SC_AVPHYS_PAGES,
        _SC_ATEXIT_MAX,
        _SC_PASS_MAX,

        _SC_XOPEN_VERSION,
        _SC_XOPEN_XCU_VERSION,
        _SC_XOPEN_UNIX,
        _SC_XOPEN_CRYPT,
        _SC_XOPEN_ENH_I18N,
        _SC_XOPEN_SHM,

        _SC_2_CHAR_TERM,
        _SC_2_UPE = 97,

        _SC_XOPEN_XPG2,
        _SC_XOPEN_XPG3,
        _SC_XOPEN_XPG4,

        _SC_NZERO = 109,

        _SC_XBS5_ILP32_OFF32 = 125,
        _SC_XBS5_ILP32_OFFBIG,
        _SC_XBS5_LP64_OFF64,
        _SC_XBS5_LPBIG_OFFBIG,

        _SC_XOPEN_LEGACY,
        _SC_XOPEN_REALTIME,
        _SC_XOPEN_REALTIME_THREADS,

        _SC_ADVISORY_INFO,
        _SC_BARRIERS,
        _SC_CLOCK_SELECTION = 137,
        _SC_CPUTIME,
        _SC_THREAD_CPUTIME,
        _SC_MONOTONIC_CLOCK = 149,
        _SC_READER_WRITER_LOCKS = 153,
        _SC_SPIN_LOCKS,
        _SC_REGEXP,
        _SC_SHELL = 157,
        _SC_SPAWN = 159,
        _SC_SPORADIC_SERVER,
        _SC_THREAD_SPORADIC_SERVER,
        _SC_TIMEOUTS = 164,
        _SC_TYPED_MEMORY_OBJECTS,
        _SC_2_PBS = 168,
        _SC_2_PBS_ACCOUNTING,
        _SC_2_PBS_LOCATE,
        _SC_2_PBS_MESSAGE,
        _SC_2_PBS_TRACK,
        _SC_SYMLOOP_MAX,
        _SC_STREAMS,
        _SC_2_PBS_CHECKPOINT,

        _SC_V6_ILP32_OFF32,
        _SC_V6_ILP32_OFFBIG,
        _SC_V6_LP64_OFF64,
        _SC_V6_LPBIG_OFFBIG,

        _SC_HOST_NAME_MAX,
        _SC_TRACE,
        _SC_TRACE_EVENT_FILTER,
        _SC_TRACE_INHERIT,
        _SC_TRACE_LOG,

        _SC_IPV6 = 235,
        _SC_RAW_SOCKETS,
        _SC_V7_ILP32_OFF32,
        _SC_V7_ILP32_OFFBIG,
        _SC_V7_LP64_OFF64,
        _SC_V7_LPBIG_OFFBIG,
        _SC_SS_REPL_MAX,
        _SC_TRACE_EVENT_NAME_MAX,
        _SC_TRACE_NAME_MAX,
        _SC_TRACE_SYS_MAX,
        _SC_TRACE_USER_EVENT_MAX,
        _SC_XOPEN_STREAMS,
        _SC_THREAD_ROBUST_PRIO_INHERIT,
        _SC_THREAD_ROBUST_PRIO_PROTECT
    }
//
// File Synchronization (FSC)
//
/*
  int fsync(int);
*/

int fsync(int) @trusted;

//
// XOpen (XSI)
//
/*
  char*      crypt(const scope char*, const scope char*);
  char*      ctermid(char*);
  void       encrypt(ref char[64], int);
  int        fchdir(int);
  c_long     gethostid();
  pid_t      getpgid(pid_t);
  pid_t      getsid(pid_t);
  char*      getwd(char*); // LEGACY
  int        lchown(const scope char*, uid_t, gid_t);
  int        lockf(int, int, off_t);
  int        nice(int);
  ssize_t    pread(int, void*, size_t, off_t);
  ssize_t    pwrite(int, const scope void*, size_t, off_t);
  pid_t      setpgrp();
  int        setregid(gid_t, gid_t);
  int        setreuid(uid_t, uid_t);
  void       swab(const scope void*, void*, ssize_t);
  void       sync();
  int        truncate(const scope char*, off_t);
  useconds_t ualarm(useconds_t, useconds_t);
  int        usleep(useconds_t);
  pid_t      vfork();
*/

int fchdir(int) @trusted;
int lockf(int, int, off_t);
alias lockf lockf64;
