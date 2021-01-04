module chipmunk.cpArbiter;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

enum CP_MAX_CONTACTS_PER_ARBITER = 2;

struct cpContactPointSet
{
    int count;
    cpVect normal;
    contactPoint[CP_MAX_CONTACTS_PER_ARBITER] points;

    private struct contactPoint {
       cpVect pointA, pointB;
       cpFloat distance;
    }
}

cpFloat cpArbiterGetRestitution (const(cpArbiter)* arb);
void cpArbiterSetRestitution (cpArbiter* arb, cpFloat restitution);
cpFloat cpArbiterGetFriction (const(cpArbiter)* arb);
void cpArbiterSetFriction (cpArbiter* arb, cpFloat friction);
cpVect cpArbiterGetSurfaceVelocity (cpArbiter* arb);
void cpArbiterSetSurfaceVelocity (cpArbiter* arb, cpVect vr);
cpDataPointer cpArbiterGetUserData (const(cpArbiter)* arb);
void cpArbiterSetUserData (cpArbiter* arb, cpDataPointer userData);
cpVect cpArbiterTotalImpulse (const(cpArbiter)* arb);
cpFloat cpArbiterTotalKE (const(cpArbiter)* arb);
cpBool cpArbiterIgnore (cpArbiter* arb);
void cpArbiterGetShapes (const(cpArbiter)* arb, cpShape** a, cpShape** b);
void cpArbiterGetBodies (const(cpArbiter)* arb, cpBody** a, cpBody** b);
cpContactPointSet cpArbiterGetContactPointSet (const(cpArbiter)* arb);
void cpArbiterSetContactPointSet (cpArbiter* arb, cpContactPointSet* set);
cpBool cpArbiterIsFirstContact (const(cpArbiter)* arb);
cpBool cpArbiterIsRemoval (const(cpArbiter)* arb);
int cpArbiterGetCount (const(cpArbiter)* arb);
cpVect cpArbiterGetNormal (const(cpArbiter)* arb);
cpVect cpArbiterGetPointA (const(cpArbiter)* arb, int i);
cpVect cpArbiterGetPointB (const(cpArbiter)* arb, int i);
cpFloat cpArbiterGetDepth (const(cpArbiter)* arb, int i);
cpBool cpArbiterCallWildcardBeginA (cpArbiter* arb, cpSpace* space);
cpBool cpArbiterCallWildcardBeginB (cpArbiter* arb, cpSpace* space);
cpBool cpArbiterCallWildcardPreSolveA (cpArbiter* arb, cpSpace* space);
cpBool cpArbiterCallWildcardPreSolveB (cpArbiter* arb, cpSpace* space);
void cpArbiterCallWildcardPostSolveA (cpArbiter* arb, cpSpace* space);
void cpArbiterCallWildcardPostSolveB (cpArbiter* arb, cpSpace* space);
void cpArbiterCallWildcardSeparateA (cpArbiter* arb, cpSpace* space);
void cpArbiterCallWildcardSeparateB (cpArbiter* arb, cpSpace* space);
