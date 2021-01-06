module core.sys.wasi.signal;

version (WebAssembly) {
    version = WASI;
}

version (WASI):

private import core.sys.wasi.config;
public import core.stdc.signal;
public import core.sys.wasi.sys.types;

private alias void function(int) sigfn_t;
private alias void function(int, siginfo_t*, void*) sigactfn_t;

// nothrow versions
nothrow @nogc
{
  private alias void function(int) sigfn_t2;
  private alias void function(int, siginfo_t*, void*) sigactfn_t2;
}

enum
  {
    SIGEV_SIGNAL,
    SIGEV_NONE,
    SIGEV_THREAD
  }

union sigval
{
  int     sival_int;
  void*   sival_ptr;
}

enum SIGHUP    = 1;
enum SIGQUIT   = 3;
enum SIGTRAP   = 5;
enum SIGBUS    = 7;
enum SIGKILL   = 9;
enum SIGUSR1   = 10;
enum SIGUSR2   = 12;
enum SIGPIPE   = 13;
enum SIGALRM   = 14;
enum SIGCHLD   = 16;
enum SIGCONT   = 17;
enum SIGSTOP   = 18;
enum SIGTSTP   = 19;
enum SIGTTIN   = 20;
enum SIGTTOU   = 21;
enum SIGURG    = 22;
enum SIGXCPU   = 23;
enum SIGXFSZ   = 24;
enum SIGVTALRM = 25;
enum SIGPROF   = 26;
enum SIGWINCH  = 27;
enum SIGPOLL   = 28;
enum SIGPWR    = 29;
enum SIGSYS    = 30;


struct sigaction_t
{
  static if ( true /* __USE_POSIX199309 */ )
    {
      union
      {
        sigfn_t     sa_handler;
        sigactfn_t  sa_sigaction;
      }
    }
  else
    {
      sigfn_t     sa_handler;
    }
  sigset_t        sa_mask;
  int             sa_flags;

  void function() sa_restorer;
}

    struct sigset_t
    {
        c_ulong[128/c_long.sizeof] __bits;
    }

    version (MIPS_Any)
    {
        enum SIG_BLOCK      = 1;
        enum SIG_UNBLOCK    = 2;
        enum SIG_SETMASK    = 3;
    }
    else
    {
        enum SIG_BLOCK      = 0;
        enum SIG_UNBLOCK    = 1;
        enum SIG_SETMASK    = 2;
    }

    struct siginfo_t
    {
        int si_signo;
        version (MIPS_Any)  // __SI_SWAP_ERRNO_CODE
        {
            int si_code;
            int si_errno;
        }
        else
        {
            int si_errno;
            int si_code;
        }
        union __si_fields_t
        {
            char[128 - 2*int.sizeof - c_long.sizeof] __pad = 0;
            struct __si_common_t
            {
                union __first_t
                {
                    struct __piduid_t
                    {
                        pid_t si_pid;
                        uid_t si_uid;
                    }
                    __piduid_t __piduid;

                    struct __timer_t
                    {
                        int si_timerid;
                        int si_overrun;
                    }
                    __timer_t __timer;
                }
                __first_t __first;

                union __second_t
                {
                    sigval si_value;
                    struct __sigchld_t
                    {
                        int si_status;
                        clock_t si_utime;
                        clock_t si_stime;
                    }
                    __sigchld_t __sigchld;
                }
                __second_t __second;
            }
            __si_common_t __si_common;

            struct __sigfault_t
            {
                void *si_addr;
                short si_addr_lsb;
                union __first_t
                {
                    struct __addr_bnd_t
                    {
                        void *si_lower;
                        void *si_upper;
                    }
                    __addr_bnd_t __addr_bnd;
                    uint si_pkey;
                }
                __first_t __first;
            }
            __sigfault_t __sigfault;

            struct __sigpoll_t
            {
                c_long si_band;
                int si_fd;
            }
            __sigpoll_t __sigpoll;

            struct __sigsys_t
            {
                void *si_call_addr;
                int si_syscall;
                uint si_arch;
            }
            __sigsys_t __sigsys;
        }
        __si_fields_t __si_fields;
    }

    int kill(pid_t, int);
    int sigaction(int, const scope sigaction_t*, sigaction_t*);
    int sigaddset(sigset_t*, int);
    int sigdelset(sigset_t*, int);
    int sigemptyset(sigset_t*);
    int sigfillset(sigset_t*);
    int sigismember(const scope sigset_t*, int);
    int sigpending(sigset_t*);
    int sigprocmask(int, const scope sigset_t*, sigset_t*);
    int sigsuspend(const scope sigset_t*);
    int sigwait(const scope sigset_t*, int*);


struct sigaltstack {
  void *ss_sp;
  int ss_flags;
  size_t ss_size;
}
alias stack_t = sigaltstack;

struct timespec {
  time_t tv_sec;
  ulong tv_nsec;
}

struct sigevent
{
  sigval sigev_value;
  int sigev_signo;
  int sigev_notify;
  void function(sigval) sigev_notify_function;
  pthread_attr_t *sigev_notify_attributes;
  char[56 - 3 * c_long.sizeof] __pad = void;
}

int pthread_kill(pthread_t, int);
int pthread_sigmask(int, const scope sigset_t*, sigset_t*);
int pthread_sigqueue(pthread_t, int, sigval);
