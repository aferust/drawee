module clib;

extern(C) @nogc nothrow {
	void* malloc(size_t sz);
	void* realloc(void* ptr, size_t sz);
	void free(void* ptr);
	void* memcpy(void* dest, const void* src, size_t n);
	void* memmove(void *str1, const void* str2, size_t n);
	void exit(int return_code);
	int printf(const char *format, ...);
    int sprintf(char *str, const char *format, ...);

    
}
alias c_long = long;

extern (C) @nogc nothrow{
    double sqrt(double x);
    float sqrtf(float x);
    float fabs(float x);
    double sin(double x);
    double cos(double x);
    double acos(double x);
    double atan2(double y, double x);
    double fmod(double x, double y);
    double exp(double x);
    double pow(double x, double y);
    float powf( float base, float exponent );
    double floor(double x);
    double ceil(double x);
    double round (double a);
    float roundf (float a);
}