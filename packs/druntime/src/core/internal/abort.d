module core.internal.abort;

/*
 * Use instead of assert(0, msg), since this does not print a message for -release compiled
 * code, and druntime is -release compiled.
 */
void abort(scope string msg, scope string filename = __FILE__, size_t line = __LINE__) @nogc nothrow @safe
{
  version (WebAssembly) {
    import core.stdc.stdio;
    import core.sys.wasi.core;
    (() @trusted { fprintf(stderr, "Abort: %s @ %s:%d\n", &msg[0], &filename[0], line); })();
    proc_exit(1);
  }
  else {
    import core.stdc.stdlib: c_abort = abort;
    // use available OS system calls to print the message to stderr
    version (Posix)
    {
        import core.sys.posix.unistd: write;
        static void writeStr(scope const(char)[][] m...) @nogc nothrow @trusted
        {
            foreach (s; m)
                write(2, s.ptr, s.length);
        }
    }
    else version (Windows)
    {
        import core.sys.windows.winbase : GetStdHandle, STD_ERROR_HANDLE, WriteFile, INVALID_HANDLE_VALUE;
        auto h = (() @trusted => GetStdHandle(STD_ERROR_HANDLE))();
        if (h == INVALID_HANDLE_VALUE)
            // attempt best we can to print the message
            assert(0, msg);
        void writeStr(scope const(char)[][] m...) @nogc nothrow @trusted
        {
            foreach (s; m)
            {
                assert(s.length <= uint.max);
                WriteFile(h, s.ptr, cast(uint)s.length, null, null);
            }
        }
    }
    else
        static assert(0, "Unsupported OS");

    import core.internal.string;
    UnsignedStringBuf strbuff = void;

    // write an appropriate message, then abort the program
    writeStr("Aborting from ", filename, "(", line.unsignedToTempString(strbuff, 10), ") ", msg);
    c_abort();
  }
}
