/*
 * This file describes the WASI interface, consisting of functions, types,
 * and defined values (macros).
 *
 * The interface described here is greatly inspired by [CloudABI]'s clean,
 * thoughtfully-designed, cabability-oriented, POSIX-style API.
 *
 * [CloudABI]: https://github.com/NuxiNL/cloudlibc
 */

module core.sys.wasi.core;

version (WebAssembly) {
  version = WASI;
}

version (WASI):

@safe:
nothrow:
@nogc:

import core.stdc.stdint;

extern (C):

alias __wasi_advice_t = ubyte;
enum __WASI_ADVICE_NORMAL = UINT8_C(0);
enum __WASI_ADVICE_SEQUENTIAL = UINT8_C(1);
enum __WASI_ADVICE_RANDOM = UINT8_C(2);
enum __WASI_ADVICE_WILLNEED = UINT8_C(3);
enum __WASI_ADVICE_DONTNEED = UINT8_C(4);
enum __WASI_ADVICE_NOREUSE = UINT8_C(5);

alias __wasi_clockid_t = uint;
enum __WASI_CLOCK_REALTIME = UINT32_C(0);
enum __WASI_CLOCK_MONOTONIC = UINT32_C(1);
enum __WASI_CLOCK_PROCESS_CPUTIME_ID = UINT32_C(2);
enum __WASI_CLOCK_THREAD_CPUTIME_ID = UINT32_C(3);

alias __wasi_device_t = ulong;

alias __wasi_dircookie_t = ulong;
enum __WASI_DIRCOOKIE_START = UINT64_C(0);

alias __wasi_errno_t = ushort;
enum __WASI_ESUCCESS = UINT16_C(0);
enum __WASI_E2BIG = UINT16_C(1);
enum __WASI_EACCES = UINT16_C(2);
enum __WASI_EADDRINUSE = UINT16_C(3);
enum __WASI_EADDRNOTAVAIL = UINT16_C(4);
enum __WASI_EAFNOSUPPORT = UINT16_C(5);
enum __WASI_EAGAIN = UINT16_C(6);
enum __WASI_EALREADY = UINT16_C(7);
enum __WASI_EBADF = UINT16_C(8);
enum __WASI_EBADMSG = UINT16_C(9);
enum __WASI_EBUSY = UINT16_C(10);
enum __WASI_ECANCELED = UINT16_C(11);
enum __WASI_ECHILD = UINT16_C(12);
enum __WASI_ECONNABORTED = UINT16_C(13);
enum __WASI_ECONNREFUSED = UINT16_C(14);
enum __WASI_ECONNRESET = UINT16_C(15);
enum __WASI_EDEADLK = UINT16_C(16);
enum __WASI_EDESTADDRREQ = UINT16_C(17);
enum __WASI_EDOM = UINT16_C(18);
enum __WASI_EDQUOT = UINT16_C(19);
enum __WASI_EEXIST = UINT16_C(20);
enum __WASI_EFAULT = UINT16_C(21);
enum __WASI_EFBIG = UINT16_C(22);
enum __WASI_EHOSTUNREACH = UINT16_C(23);
enum __WASI_EIDRM = UINT16_C(24);
enum __WASI_EILSEQ = UINT16_C(25);
enum __WASI_EINPROGRESS = UINT16_C(26);
enum __WASI_EINTR = UINT16_C(27);
enum __WASI_EINVAL = UINT16_C(28);
enum __WASI_EIO = UINT16_C(29);
enum __WASI_EISCONN = UINT16_C(30);
enum __WASI_EISDIR = UINT16_C(31);
enum __WASI_ELOOP = UINT16_C(32);
enum __WASI_EMFILE = UINT16_C(33);
enum __WASI_EMLINK = UINT16_C(34);
enum __WASI_EMSGSIZE = UINT16_C(35);
enum __WASI_EMULTIHOP = UINT16_C(36);
enum __WASI_ENAMETOOLONG = UINT16_C(37);
enum __WASI_ENETDOWN = UINT16_C(38);
enum __WASI_ENETRESET = UINT16_C(39);
enum __WASI_ENETUNREACH = UINT16_C(40);
enum __WASI_ENFILE = UINT16_C(41);
enum __WASI_ENOBUFS = UINT16_C(42);
enum __WASI_ENODEV = UINT16_C(43);
enum __WASI_ENOENT = UINT16_C(44);
enum __WASI_ENOEXEC = UINT16_C(45);
enum __WASI_ENOLCK = UINT16_C(46);
enum __WASI_ENOLINK = UINT16_C(47);
enum __WASI_ENOMEM = UINT16_C(48);
enum __WASI_ENOMSG = UINT16_C(49);
enum __WASI_ENOPROTOOPT = UINT16_C(50);
enum __WASI_ENOSPC = UINT16_C(51);
enum __WASI_ENOSYS = UINT16_C(52);
enum __WASI_ENOTCONN = UINT16_C(53);
enum __WASI_ENOTDIR = UINT16_C(54);
enum __WASI_ENOTEMPTY = UINT16_C(55);
enum __WASI_ENOTRECOVERABLE = UINT16_C(56);
enum __WASI_ENOTSOCK = UINT16_C(57);
enum __WASI_ENOTSUP = UINT16_C(58);
enum __WASI_ENOTTY = UINT16_C(59);
enum __WASI_ENXIO = UINT16_C(60);
enum __WASI_EOVERFLOW = UINT16_C(61);
enum __WASI_EOWNERDEAD = UINT16_C(62);
enum __WASI_EPERM = UINT16_C(63);
enum __WASI_EPIPE = UINT16_C(64);
enum __WASI_EPROTO = UINT16_C(65);
enum __WASI_EPROTONOSUPPORT = UINT16_C(66);
enum __WASI_EPROTOTYPE = UINT16_C(67);
enum __WASI_ERANGE = UINT16_C(68);
enum __WASI_EROFS = UINT16_C(69);
enum __WASI_ESPIPE = UINT16_C(70);
enum __WASI_ESRCH = UINT16_C(71);
enum __WASI_ESTALE = UINT16_C(72);
enum __WASI_ETIMEDOUT = UINT16_C(73);
enum __WASI_ETXTBSY = UINT16_C(74);
enum __WASI_EXDEV = UINT16_C(75);
enum __WASI_ENOTCAPABLE = UINT16_C(76);

alias __wasi_eventrwflags_t = ushort;
enum __WASI_EVENT_FD_READWRITE_HANGUP = UINT16_C(0x0001);

alias __wasi_eventtype_t = ubyte;
enum __WASI_EVENTTYPE_CLOCK = UINT8_C(0);
enum __WASI_EVENTTYPE_FD_READ = UINT8_C(1);
enum __WASI_EVENTTYPE_FD_WRITE = UINT8_C(2);

alias __wasi_exitcode_t = uint;

alias __wasi_fd_t = uint;

alias __wasi_fdflags_t = ushort;
enum __WASI_FDFLAG_APPEND = UINT16_C(0x0001);
enum __WASI_FDFLAG_DSYNC = UINT16_C(0x0002);
enum __WASI_FDFLAG_NONBLOCK = UINT16_C(0x0004);
enum __WASI_FDFLAG_RSYNC = UINT16_C(0x0008);
enum __WASI_FDFLAG_SYNC = UINT16_C(0x0010);

alias __wasi_filedelta_t = long;

alias __wasi_filesize_t = ulong;

alias __wasi_filetype_t = ubyte;
enum __WASI_FILETYPE_UNKNOWN = UINT8_C(0);
enum __WASI_FILETYPE_BLOCK_DEVICE = UINT8_C(1);
enum __WASI_FILETYPE_CHARACTER_DEVICE = UINT8_C(2);
enum __WASI_FILETYPE_DIRECTORY = UINT8_C(3);
enum __WASI_FILETYPE_REGULAR_FILE = UINT8_C(4);
enum __WASI_FILETYPE_SOCKET_DGRAM = UINT8_C(5);
enum __WASI_FILETYPE_SOCKET_STREAM = UINT8_C(6);
enum __WASI_FILETYPE_SYMBOLIC_LINK = UINT8_C(7);

alias __wasi_fstflags_t = ushort;
enum __WASI_FILESTAT_SET_ATIM = UINT16_C(0x0001);
enum __WASI_FILESTAT_SET_ATIM_NOW = UINT16_C(0x0002);
enum __WASI_FILESTAT_SET_MTIM = UINT16_C(0x0004);
enum __WASI_FILESTAT_SET_MTIM_NOW = UINT16_C(0x0008);

alias __wasi_inode_t = ulong;

alias __wasi_linkcount_t = uint;

alias __wasi_lookupflags_t = uint;
enum __WASI_LOOKUP_SYMLINK_FOLLOW = UINT32_C(0x00000001);

alias __wasi_oflags_t = ushort;
enum __WASI_O_CREAT = UINT16_C(0x0001);
enum __WASI_O_DIRECTORY = UINT16_C(0x0002);
enum __WASI_O_EXCL = UINT16_C(0x0004);
enum __WASI_O_TRUNC = UINT16_C(0x0008);

alias __wasi_riflags_t = ushort;
enum __WASI_SOCK_RECV_PEEK = UINT16_C(0x0001);
enum __WASI_SOCK_RECV_WAITALL = UINT16_C(0x0002);

alias __wasi_rights_t = ulong;
enum __WASI_RIGHT_FD_DATASYNC = UINT64_C(0x0000000000000001);
enum __WASI_RIGHT_FD_READ = UINT64_C(0x0000000000000002);
enum __WASI_RIGHT_FD_SEEK = UINT64_C(0x0000000000000004);
enum __WASI_RIGHT_FD_FDSTAT_SET_FLAGS = UINT64_C(0x0000000000000008);
enum __WASI_RIGHT_FD_SYNC = UINT64_C(0x0000000000000010);
enum __WASI_RIGHT_FD_TELL = UINT64_C(0x0000000000000020);
enum __WASI_RIGHT_FD_WRITE = UINT64_C(0x0000000000000040);
enum __WASI_RIGHT_FD_ADVISE = UINT64_C(0x0000000000000080);
enum __WASI_RIGHT_FD_ALLOCATE = UINT64_C(0x0000000000000100);
enum __WASI_RIGHT_PATH_CREATE_DIRECTORY = UINT64_C(0x0000000000000200);
enum __WASI_RIGHT_PATH_CREATE_FILE = UINT64_C(0x0000000000000400);
enum __WASI_RIGHT_PATH_LINK_SOURCE = UINT64_C(0x0000000000000800);
enum __WASI_RIGHT_PATH_LINK_TARGET = UINT64_C(0x0000000000001000);
enum __WASI_RIGHT_PATH_OPEN = UINT64_C(0x0000000000002000);
enum __WASI_RIGHT_FD_READDIR = UINT64_C(0x0000000000004000);
enum __WASI_RIGHT_PATH_READLINK = UINT64_C(0x0000000000008000);
enum __WASI_RIGHT_PATH_RENAME_SOURCE = UINT64_C(0x0000000000010000);
enum __WASI_RIGHT_PATH_RENAME_TARGET = UINT64_C(0x0000000000020000);
enum __WASI_RIGHT_PATH_FILESTAT_GET = UINT64_C(0x0000000000040000);
enum __WASI_RIGHT_PATH_FILESTAT_SET_SIZE = UINT64_C(0x0000000000080000);
enum __WASI_RIGHT_PATH_FILESTAT_SET_TIMES = UINT64_C(0x0000000000100000);
enum __WASI_RIGHT_FD_FILESTAT_GET = UINT64_C(0x0000000000200000);
enum __WASI_RIGHT_FD_FILESTAT_SET_SIZE = UINT64_C(0x0000000000400000);
enum __WASI_RIGHT_FD_FILESTAT_SET_TIMES = UINT64_C(0x0000000000800000);
enum __WASI_RIGHT_PATH_SYMLINK = UINT64_C(0x0000000001000000);
enum __WASI_RIGHT_PATH_REMOVE_DIRECTORY = UINT64_C(0x0000000002000000);
enum __WASI_RIGHT_PATH_UNLINK_FILE = UINT64_C(0x0000000004000000);
enum __WASI_RIGHT_POLL_FD_READWRITE = UINT64_C(0x0000000008000000);
enum __WASI_RIGHT_SOCK_SHUTDOWN = UINT64_C(0x0000000010000000);

alias __wasi_roflags_t = ushort;
enum __WASI_SOCK_RECV_DATA_TRUNCATED = UINT16_C(0x0001);

alias __wasi_sdflags_t = ubyte;
enum __WASI_SHUT_RD = UINT8_C(0x01);
enum __WASI_SHUT_WR = UINT8_C(0x02);

alias __wasi_siflags_t = ushort;

alias __wasi_signal_t = ubyte;
/* UINT8_C(0) is reserved; POSIX has special semantics for kill(pid, 0). */
enum __WASI_SIGHUP = UINT8_C(1);
enum __WASI_SIGINT = UINT8_C(2);
enum __WASI_SIGQUIT = UINT8_C(3);
enum __WASI_SIGILL = UINT8_C(4);
enum __WASI_SIGTRAP = UINT8_C(5);
enum __WASI_SIGABRT = UINT8_C(6);
enum __WASI_SIGBUS = UINT8_C(7);
enum __WASI_SIGFPE = UINT8_C(8);
enum __WASI_SIGKILL = UINT8_C(9);
enum __WASI_SIGUSR1 = UINT8_C(10);
enum __WASI_SIGSEGV = UINT8_C(11);
enum __WASI_SIGUSR2 = UINT8_C(12);
enum __WASI_SIGPIPE = UINT8_C(13);
enum __WASI_SIGALRM = UINT8_C(14);
enum __WASI_SIGTERM = UINT8_C(15);
enum __WASI_SIGCHLD = UINT8_C(16);
enum __WASI_SIGCONT = UINT8_C(17);
enum __WASI_SIGSTOP = UINT8_C(18);
enum __WASI_SIGTSTP = UINT8_C(19);
enum __WASI_SIGTTIN = UINT8_C(20);
enum __WASI_SIGTTOU = UINT8_C(21);
enum __WASI_SIGURG = UINT8_C(22);
enum __WASI_SIGXCPU = UINT8_C(23);
enum __WASI_SIGXFSZ = UINT8_C(24);
enum __WASI_SIGVTALRM = UINT8_C(25);
enum __WASI_SIGPROF = UINT8_C(26);
enum __WASI_SIGWINCH = UINT8_C(27);
enum __WASI_SIGPOLL = UINT8_C(28);
enum __WASI_SIGPWR = UINT8_C(29);
enum __WASI_SIGSYS = UINT8_C(30);

alias __wasi_subclockflags_t = ushort;
enum __WASI_SUBSCRIPTION_CLOCK_ABSTIME = UINT16_C(0x0001);

alias __wasi_timestamp_t = ulong;

alias __wasi_userdata_t = ulong;

alias __wasi_whence_t = ubyte;
enum __WASI_WHENCE_CUR = UINT8_C(0);
enum __WASI_WHENCE_END = UINT8_C(1);
enum __WASI_WHENCE_SET = UINT8_C(2);

alias __wasi_preopentype_t = ubyte;
enum __WASI_PREOPENTYPE_DIR = UINT8_C(0);

struct __wasi_dirent_t
{
  __wasi_dircookie_t d_next;
  __wasi_inode_t d_ino;
  uint d_namlen;
  __wasi_filetype_t d_type;
}

struct __wasi_event_t
{
  __wasi_userdata_t userdata;
  __wasi_errno_t error;
  __wasi_eventtype_t type;

  union __wasi_event_u
  {
    struct __wasi_event_u_fd_readwrite_t
    {
      __wasi_filesize_t nbytes;
      __wasi_eventrwflags_t flags;
    }

    __wasi_event_u_fd_readwrite_t fd_readwrite;
  }

  __wasi_event_u u;
}

struct __wasi_prestat_t
{
  __wasi_preopentype_t pr_type;

  union __wasi_prestat_u
  {
    struct __wasi_prestat_u_dir_t
    {
      size_t pr_name_len;
    }

    __wasi_prestat_u_dir_t dir;
  }

  __wasi_prestat_u u;
}

struct __wasi_fdstat_t
{
  __wasi_filetype_t fs_filetype;
  __wasi_fdflags_t fs_flags;
  __wasi_rights_t fs_rights_base;
  __wasi_rights_t fs_rights_inheriting;
}

struct __wasi_filestat_t
{
  __wasi_device_t st_dev;
  __wasi_inode_t st_ino;
  __wasi_filetype_t st_filetype;
  __wasi_linkcount_t st_nlink;
  __wasi_filesize_t st_size;
  __wasi_timestamp_t st_atim;
  __wasi_timestamp_t st_mtim;
  __wasi_timestamp_t st_ctim;
}

struct __wasi_ciovec_t
{
  const(void)* buf;
  size_t buf_len;
}

struct __wasi_iovec_t
{
  void* buf;
  size_t buf_len;
}

struct __wasi_subscription_t
{
  __wasi_userdata_t userdata;
  __wasi_eventtype_t type;

  union __wasi_subscription_u
  {
    struct __wasi_subscription_u_clock_t
    {
      __wasi_userdata_t identifier;
      __wasi_clockid_t clock_id;
      __wasi_timestamp_t timeout;
      __wasi_timestamp_t precision;
      __wasi_subclockflags_t flags;
    }

    __wasi_subscription_u_clock_t clock;

    struct __wasi_subscription_u_fd_readwrite_t
    {
      __wasi_fd_t fd;
    }

    __wasi_subscription_u_fd_readwrite_t fd_readwrite;
  }

  __wasi_subscription_u u;
}

import ldc.attributes;
@llvmAttr("wasm-import-module", "wasi_snapshot_preview1") {

  __wasi_errno_t args_get (char** argv, char* argv_buf);

  __wasi_errno_t args_sizes_get (size_t* argc, size_t* argv_buf_size);

  __wasi_errno_t clock_res_get (
                                __wasi_clockid_t clock_id,
                                __wasi_timestamp_t* resolution);

  __wasi_errno_t clock_time_get (
                                 __wasi_clockid_t clock_id,
                                 __wasi_timestamp_t precision,
                                 __wasi_timestamp_t* time);

  __wasi_errno_t environ_get (char** environ, char* environ_buf);

  __wasi_errno_t environ_sizes_get (
                                    size_t* environ_count,
                                    size_t* environ_buf_size);

  __wasi_errno_t fd_prestat_get (__wasi_fd_t fd, __wasi_prestat_t* buf);

  __wasi_errno_t fd_prestat_dir_name (
                                      __wasi_fd_t fd,
                                      char* path,
                                      size_t path_len);

  __wasi_errno_t fd_close (__wasi_fd_t fd);

  __wasi_errno_t fd_datasync (__wasi_fd_t fd);

  __wasi_errno_t fd_pread (
                           __wasi_fd_t fd,
                           const(__wasi_iovec_t)* iovs,
                           size_t iovs_len,
                           __wasi_filesize_t offset,
                           size_t* nread);

  __wasi_errno_t fd_pwrite (
                            __wasi_fd_t fd,
                            const(__wasi_ciovec_t)* iovs,
                            size_t iovs_len,
                            __wasi_filesize_t offset,
                            size_t* nwritten);

  __wasi_errno_t fd_read (
                          __wasi_fd_t fd,
                          const(__wasi_iovec_t)* iovs,
                          size_t iovs_len,
                          size_t* nread);

  __wasi_errno_t fd_renumber (__wasi_fd_t from, __wasi_fd_t to);

  __wasi_errno_t fd_seek (
                          __wasi_fd_t fd,
                          __wasi_filedelta_t offset,
                          __wasi_whence_t whence,
                          __wasi_filesize_t* newoffset);

  __wasi_errno_t fd_tell (__wasi_fd_t fd, __wasi_filesize_t* newoffset);

  __wasi_errno_t fd_fdstat_get (__wasi_fd_t fd, __wasi_fdstat_t* buf);

  __wasi_errno_t fd_fdstat_set_flags (
                                      __wasi_fd_t fd,
                                      __wasi_fdflags_t flags);

  __wasi_errno_t fd_fdstat_set_rights (
                                       __wasi_fd_t fd,
                                       __wasi_rights_t fs_rights_base,
                                       __wasi_rights_t fs_rights_inheriting);

  __wasi_errno_t fd_sync (__wasi_fd_t fd);

  __wasi_errno_t fd_write (
                           __wasi_fd_t fd,
                           const(__wasi_ciovec_t)* iovs,
                           size_t iovs_len,
                           size_t* nwritten);

  __wasi_errno_t fd_advise (
                            __wasi_fd_t fd,
                            __wasi_filesize_t offset,
                            __wasi_filesize_t len,
                            __wasi_advice_t advice);

  __wasi_errno_t fd_allocate (
                              __wasi_fd_t fd,
                              __wasi_filesize_t offset,
                              __wasi_filesize_t len);

  __wasi_errno_t path_create_directory (
                                        __wasi_fd_t fd,
                                        const(char)* path,
                                        size_t path_len);

  __wasi_errno_t path_link (
                            __wasi_fd_t old_fd,
                            __wasi_lookupflags_t old_flags,
                            const(char)* old_path,
                            size_t old_path_len,
                            __wasi_fd_t new_fd,
                            const(char)* new_path,
                            size_t new_path_len);

  __wasi_errno_t path_open (
                            __wasi_fd_t dirfd,
                            __wasi_lookupflags_t dirflags,
                            const(char)* path,
                            size_t path_len,
                            __wasi_oflags_t oflags,
                            __wasi_rights_t fs_rights_base,
                            __wasi_rights_t fs_rights_inheriting,
                            __wasi_fdflags_t fs_flags,
                            __wasi_fd_t* fd);

  __wasi_errno_t fd_readdir (
                             __wasi_fd_t fd,
                             void* buf,
                             size_t buf_len,
                             __wasi_dircookie_t cookie,
                             size_t* bufused);

  __wasi_errno_t path_readlink (
                                __wasi_fd_t fd,
                                const(char)* path,
                                size_t path_len,
                                char* buf,
                                size_t buf_len,
                                size_t* bufused);

  __wasi_errno_t path_rename (
                              __wasi_fd_t old_fd,
                              const(char)* old_path,
                              size_t old_path_len,
                              __wasi_fd_t new_fd,
                              const(char)* new_path,
                              size_t new_path_len);

  __wasi_errno_t fd_filestat_get (__wasi_fd_t fd, __wasi_filestat_t* buf);

  __wasi_errno_t fd_filestat_set_times (
                                        __wasi_fd_t fd,
                                        __wasi_timestamp_t st_atim,
                                        __wasi_timestamp_t st_mtim,
                                        __wasi_fstflags_t fstflags);

  __wasi_errno_t fd_filestat_set_size (
                                       __wasi_fd_t fd,
                                       __wasi_filesize_t st_size);

  __wasi_errno_t path_filestat_get (
                                    __wasi_fd_t fd,
                                    __wasi_lookupflags_t flags,
                                    const(char)* path,
                                    size_t path_len,
                                    __wasi_filestat_t* buf);

  __wasi_errno_t path_filestat_set_times (
                                          __wasi_fd_t fd,
                                          __wasi_lookupflags_t flags,
                                          const(char)* path,
                                          size_t path_len,
                                          __wasi_timestamp_t st_atim,
                                          __wasi_timestamp_t st_mtim,
                                          __wasi_fstflags_t fstflags);

  __wasi_errno_t path_symlink (
                               const(char)* old_path,
                               size_t old_path_len,
                               __wasi_fd_t fd,
                               const(char)* new_path,
                               size_t new_path_len);

  __wasi_errno_t path_unlink_file (
                                   __wasi_fd_t fd,
                                   const(char)* path,
                                   size_t path_len);

  __wasi_errno_t path_remove_directory (
                                        __wasi_fd_t fd,
                                        const(char)* path,
                                        size_t path_len);

  __wasi_errno_t poll_oneoff (
                              const(__wasi_subscription_t)* in_,
                              __wasi_event_t* out_,
                              size_t nsubscriptions,
                              size_t* nevents);

  void proc_exit (__wasi_exitcode_t rval);

  __wasi_errno_t proc_raise (__wasi_signal_t sig);

  __wasi_errno_t random_get (void* buf, size_t buf_len);

  __wasi_errno_t sock_recv (
                            __wasi_fd_t sock,
                            const(__wasi_iovec_t)* ri_data,
                            size_t ri_data_len,
                            __wasi_riflags_t ri_flags,
                            size_t* ro_datalen,
                            __wasi_roflags_t* ro_flags);

  __wasi_errno_t sock_send (
                            __wasi_fd_t sock,
                            const(__wasi_ciovec_t)* si_data,
                            size_t si_data_len,
                            __wasi_siflags_t si_flags,
                            size_t* so_datalen);

  __wasi_errno_t sock_shutdown (__wasi_fd_t sock, __wasi_sdflags_t how);

  __wasi_errno_t sched_yield ();
}
