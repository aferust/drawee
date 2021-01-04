module chipmunk.cpConstraint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

alias void function (cpConstraint*, cpSpace*) cpConstraintPreSolveFunc;
alias void function (cpConstraint*, cpSpace*) cpConstraintPostSolveFunc;

void cpConstraintDestroy (cpConstraint* constraint);
void cpConstraintFree (cpConstraint* constraint);
cpSpace* cpConstraintGetSpace (const(cpConstraint)* constraint);
cpBody* cpConstraintGetBodyA (const(cpConstraint)* constraint);
cpBody* cpConstraintGetBodyB (const(cpConstraint)* constraint);
cpFloat cpConstraintGetMaxForce (const(cpConstraint)* constraint);
void cpConstraintSetMaxForce (cpConstraint* constraint, cpFloat maxForce);
cpFloat cpConstraintGetErrorBias (const(cpConstraint)* constraint);
void cpConstraintSetErrorBias (cpConstraint* constraint, cpFloat errorBias);
cpFloat cpConstraintGetMaxBias (const(cpConstraint)* constraint);
void cpConstraintSetMaxBias (cpConstraint* constraint, cpFloat maxBias);
cpBool cpConstraintGetCollideBodies (const(cpConstraint)* constraint);
void cpConstraintSetCollideBodies (cpConstraint* constraint, cpBool collideBodies);
cpConstraintPreSolveFunc cpConstraintGetPreSolveFunc (const(cpConstraint)* constraint);
void cpConstraintSetPreSolveFunc (cpConstraint* constraint, cpConstraintPreSolveFunc preSolveFunc);
cpConstraintPostSolveFunc cpConstraintGetPostSolveFunc (const(cpConstraint)* constraint);
void cpConstraintSetPostSolveFunc (cpConstraint* constraint, cpConstraintPostSolveFunc postSolveFunc);
cpDataPointer cpConstraintGetUserData (const(cpConstraint)* constraint);
void cpConstraintSetUserData (cpConstraint* constraint, cpDataPointer userData);
cpFloat cpConstraintGetImpulse (cpConstraint* constraint);
