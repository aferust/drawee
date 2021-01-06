module core.sys.wasi.sys.socket;

version (WebAssembly) {
  version = WASI;
}

version (WASI):

alias sa_family_t = ushort;
