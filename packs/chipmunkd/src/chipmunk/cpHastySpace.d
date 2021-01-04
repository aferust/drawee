module chipmunk.cpHastySpace;
import core.stdc.config;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

struct cpHastySpace;

cpSpace* cpHastySpaceNew ();
void cpHastySpaceFree (cpSpace* space);
void cpHastySpaceSetThreads (cpSpace* space, c_ulong threads);
c_ulong cpHastySpaceGetThreads (cpSpace* space);
void cpHastySpaceStep (cpSpace* space, cpFloat dt);
