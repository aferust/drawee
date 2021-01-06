import core.runtime, core.time : MonoTime;
import core.stdc.stdio;

ModuleInfo* getModuleInfo(string name)
{
    foreach (m; ModuleInfo)
        if (m.name == name) return m;
    assert(0, "module '"~name~"' not found");
}

UnitTestResult tester()
{
    return Runtime.args.length > 1 ? testModules() : testAll();
}

string mode;


UnitTestResult testModules()
{
    UnitTestResult ret;
    ret.summarize = false;
    ret.runMain = false;
    foreach (name; Runtime.args[1..$])
    {
        immutable pkg = ".package";
        immutable pkgLen = pkg.length;

        if (name.length > pkgLen && name[$ - pkgLen .. $] == pkg)
            name = name[0 .. $ - pkgLen];

        doTest(getModuleInfo(name), ret);
    }

    return ret;
}

UnitTestResult testAll()
{
    UnitTestResult ret;
    ret.summarize = false;
    ret.runMain = false;
    foreach (moduleInfo; ModuleInfo)
    {
        doTest(moduleInfo, ret);
    }

    return ret;
}


void doTest(ModuleInfo* moduleInfo, ref UnitTestResult ret)
{
    if (auto fp = moduleInfo.unitTest)
    {
        auto name = moduleInfo.name;
        ++ret.executed;
        try
        {
            immutable t0 = MonoTime.currTime;
            fp();
            ++ret.passed;
            printf("%.3fs PASS %.*s %.*s\n",
                   (MonoTime.currTime - t0).total!"msecs" / 1000.0,
                   cast(uint)mode.length, mode.ptr,
                   cast(uint)name.length, name.ptr);
        }
        catch (Throwable e)
        {
            auto msg = e.toString();
            printf("****** FAIL %.*s %.*s\n%.*s\n",
                   cast(uint)mode.length, mode.ptr,
                   cast(uint)name.length, name.ptr,
                   cast(uint)msg.length, msg.ptr);
        }
    }
}


shared static this()
{
    version (D_Coverage)
    {
        import core.runtime : dmd_coverSetMerge;
        dmd_coverSetMerge(true);
    }
    Runtime.extendedModuleUnitTester = &tester;

    debug mode = "debug";
    else  mode =  "release";
    static if ((void*).sizeof == 4) mode ~= "32";
    else static if ((void*).sizeof == 8) mode ~= "64";
    else static assert(0, "You must be from the future!");
}

void main()
{
}

// pragma(msg, "emit _start");
// import ldc.attributes;
// import core.sys.wasi.core;
// extern (C) {
//   pragma(mangle, "_d_run_main")
//     int _d_run_main(int argc, char **argv, void* mainFunc);

//   pragma(mangle, "_Dmain")
//     int _Dmain(char[][] args);

//   pragma(mangle, "main")
//     int main(int argc, char **argv)
//     {
//       pragma(LDC_profile_instr, false);
//       return _d_run_main(argc, argv, &_Dmain);
//     }

//   void __wasm_call_ctors();
//   pragma(mangle, "_start")
//     export void _start() {
//     __wasm_call_ctors();
//     proc_exit(main(0, null));
//   }
// }
