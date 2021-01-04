module chipmunk.chipmunk_types;

/*
import core.stdc.config;
import core.stdc.math;
import core.stdc.float_;
*/
alias wchar_t = wchar;

import chipmunk.cpVect;

extern (C):
@nogc nothrow:

double sqrt(double x);
double sin(double x);
double cos(double x);
double acos(double x);
double atan2(double y, double x);
double fmod(double x, double y);
double exp(double x);
double pow(double x, double y);
double floor(double x);
double ceil(double x);

enum DBL_MIN = double.min_normal;
alias c_ulong = uint;

enum CP_NO_GROUP = 0;
enum cpBitmask CP_ALL_CATEGORIES = ~0;
enum cpCollisionType CP_WILDCARD_COLLISION_TYPE = ~0;

// TODO: support CP_USE_DOUBLES? Right now I just assume we're using doubles.

alias cpFloat = double;
alias cpfsqrt = sqrt;
alias cpfsin = sin;
alias cpfcos = cos;
alias cpfacos = acos;
alias cpfatan2 = atan2;
alias cpfmod = fmod;
alias cpfexp = exp;
alias cpfpow = pow;
alias cpffloor = floor;
alias cpfceil = ceil;
enum CPFLOAT_MIN = DBL_MIN;

alias c_ulong cpHashValue;
alias uint cpCollisionID;
alias ubyte cpBool;
alias void* cpDataPointer;
alias c_ulong cpCollisionType;
alias c_ulong cpGroup;
alias uint cpBitmask;
alias uint cpTimestamp;

enum cpFalse = 0;
enum cpTrue = 1;

enum INFINITY = cpFloat.infinity;

enum CP_PI = cast(cpFloat)3.14159265358979323846264338327950288;

struct cpVect
{
    cpFloat x;
    cpFloat y;

    cpVect opBinary(string op)(const cpFloat s) const if (op == "*")
    {
        return cpvmult(this, s);
    }

    cpVect opBinary(string op)(const cpVect v2) const if (op == "+")
    {
        return cpvadd(this, v2);
    }

    cpVect opBinary(string op)(const cpVect v2) const if (op == "-")
    {
        return cpvsub(this, v2);
    }

    cpBool opEquals()(const cpVect v2) const if (op == "==")
    {
        return cpveql(this, v2);
    }

    cpVect opUnary(string op)() const if (op == "-")
    {
        return cpvneg(this);
    }
}

struct cpTransform
{
    cpFloat a;
    cpFloat b;
    cpFloat c;
    cpFloat d;
    cpFloat tx;
    cpFloat ty;
}

struct cpMat2x2
{
    cpFloat a;
    cpFloat b;
    cpFloat c;
    cpFloat d;
}

/// Return the max of two cpFloats.
static cpFloat cpfmax(cpFloat a, cpFloat b)
{
	return (a > b) ? a : b;
}

/// Return the min of two cpFloats.
static cpFloat cpfmin(cpFloat a, cpFloat b)
{
	return (a < b) ? a : b;
}

/// Return the absolute value of a cpFloat.
static cpFloat cpfabs(cpFloat f)
{
	return (f < 0) ? -f : f;
}

/// Clamp @c f to be between @c min and @c max.
static cpFloat cpfclamp(cpFloat f, cpFloat min, cpFloat max)
{
	return cpfmin(cpfmax(f, min), max);
}

/// Clamp @c f to be between 0 and 1.
static cpFloat cpfclamp01(cpFloat f)
{
	return cpfmax(0.0f, cpfmin(f, 1.0f));
}

/// Linearly interpolate (or extrapolate) between @c f1 and @c f2 by @c t percent.
static cpFloat cpflerp(cpFloat f1, cpFloat f2, cpFloat t)
{
	return f1*(1.0f - t) + f2*t;
}

/// Linearly interpolate from @c f1 to @c f2 by no more than @c d.
static cpFloat cpflerpconst(cpFloat f1, cpFloat f2, cpFloat d)
{
	return f1 + cpfclamp(f2 - f1, -d, d);
}
