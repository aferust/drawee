module chipmunk.chipmunk;

/*
import core.stdc.stdlib: exit;
import core.stdc.stdio: printf;
*/
extern(C) @nogc nothrow {
	void exit(int status);
	int printf(const char* cptr, ...);
}

import chipmunk.cpBB;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.chipmunk_private;

extern (C):
@nogc nothrow:

extern __gshared const(char)* cpVersionString;

void cpAssertHard(T)(T cond, string msg) {
    if(!cond){
        printf(msg.ptr);
        exit(1);
    }
}

void cpAssertSoft(T)(T cond, string msg){
    if(!cond){
        printf(msg.ptr);
        exit(1);
    }
}

void cpMessage (const(char)* condition, const(char)* file, int line, int isError, int isHardError, const(char)* message, ...);
cpFloat cpMomentForCircle (cpFloat m, cpFloat r1, cpFloat r2, cpVect offset);
cpFloat cpAreaForCircle (cpFloat r1, cpFloat r2);
cpFloat cpMomentForSegment (cpFloat m, cpVect a, cpVect b, cpFloat radius);
cpFloat cpAreaForSegment (cpVect a, cpVect b, cpFloat radius);
cpFloat cpMomentForPoly (cpFloat m, int count, const(cpVect)* verts, cpVect offset, cpFloat radius);
cpFloat cpAreaForPoly (const int count, const(cpVect)* verts, cpFloat radius);
cpVect cpCentroidForPoly (const int count, const(cpVect)* verts);
cpFloat cpMomentForBox (cpFloat m, cpFloat width, cpFloat height);
cpFloat cpMomentForBox2 (cpFloat m, cpBB box);
int cpConvexHull (int count, const(cpVect)* verts, cpVect* result, int* first, cpFloat tol);
cpVect cpClosetPointOnSegment (const cpVect p, const cpVect a, const cpVect b);

// In the C project, these are defined in a .c file and typedef'd in chipmunk.h
struct cpHashSetBin {
	void *elt;
	cpHashValue hash;
	cpHashSetBin *next;
};

struct cpHashSet {
	uint entries, size;
	
	cpHashSetEqlFunc eql;
	void *default_value;
	
	cpHashSetBin **table;
	cpHashSetBin *pooledBins;
	
	cpArray *allocatedBuffers;
};
