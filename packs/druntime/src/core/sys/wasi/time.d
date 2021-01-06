module core.sys.wasi.time;

version (WebAssembly) {
    version = WASI;
}

version (WASI):

private import core.sys.wasi.config;
public import core.stdc.time;
public import core.sys.wasi.sys.types;
public import core.sys.wasi.signal; // for sigevent

extern (C):
nothrow:
@nogc:

//
// Required (defined in core.stdc.time)
//
/*
  char* asctime(in tm*);
  clock_t clock();
  char* ctime(in time_t*);
  double difftime(time_t, time_t);
  tm* gmtime(in time_t*);
  tm* localtime(in time_t*);
  time_t mktime(tm*);
  size_t strftime(char*, size_t, in char*, in tm*);
  time_t time(time_t*);
*/

time_t timegm(tm*);

// TODO: use wasi.core defines here instead of magic vals
enum CLOCK_MONOTONIC = 1;

alias int clockid_t;
alias void* timer_t;

struct timespec
{
  time_t  tv_sec;
  c_long  tv_nsec;
}

struct itimerspec
{
    timespec it_interval;
    timespec it_value;
}

enum TIMER_ABSTIME = 1;

enum CLOCK_REALTIME = 0;
enum CLOCK_PROCESS_CPUTIME_ID = 2;
enum CLOCK_THREAD_CPUTIME_ID = 3;
enum CLOCK_REALTIME_COARSE = 5;
enum CLOCK_BOOTTIME = 7;
enum CLOCK_REALTIME_ALARM = 8;
enum CLOCK_BOOTTIME_ALARM = 9;
enum CLOCK_SGI_CYCLE = 10;
enum CLOCK_TAI = 11;

int nanosleep(const scope timespec*, timespec*);

int clock_getres(clockid_t, timespec*);
int clock_gettime(clockid_t, timespec*);
int clock_nanosleep(clockid_t, int, const scope timespec*, timespec*);
int clock_getcpuclockid(pid_t, clockid_t *);

int timer_create(clockid_t, sigevent*, timer_t*);
int timer_delete(timer_t);
int timer_gettime(timer_t, itimerspec*);
int timer_settime(timer_t, int, const scope itimerspec*, itimerspec*);
int timer_getoverrun(timer_t);

char* asctime_r(const scope tm*, char*);
char* ctime_r(const scope time_t*, char*);
tm*   gmtime_r(const scope time_t*, tm*);
tm*   localtime_r(const scope time_t*, tm*);

extern __gshared int daylight;
extern __gshared c_long timezone;

tm*   getdate(const scope char*);
char* strptime(const scope char*, const scope char*, tm*);
