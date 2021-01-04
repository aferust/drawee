module clib;

extern(C) @nogc nothrow {
	void* malloc(size_t sz);
	void* realloc(void* ptr, size_t sz);
	void free(void* ptr);
	void* memcpy(void* dest, const void* src, size_t n);
	void* memmove(void *str1, const void* str2, size_t n);
	void exit(int return_code);
	int printf(const char *format, ...);

    alias c_long = long;
}