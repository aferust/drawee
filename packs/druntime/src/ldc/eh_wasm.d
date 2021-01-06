/**
 * This module implements the runtime-part of LDC exceptions
 * on Windows, based on the MSVC++ runtime.
 */
module ldc.eh_wasm;

version (WebAssembly):

extern (C) void _d_throw_exception(Throwable t) {
  assert(0, t.msg);
}

extern (C) void _Unwind_Resume(void*) {
  assert(0, "No unwind support");
}
