module chipmunk.cpRobust;

import chipmunk.chipmunk_types;

extern (C):
@nogc nothrow:

cpBool cpCheckPointGreater (const cpVect a, const cpVect b, const cpVect c);
cpBool cpCheckAxis (cpVect v0, cpVect v1, cpVect p, cpVect n);
