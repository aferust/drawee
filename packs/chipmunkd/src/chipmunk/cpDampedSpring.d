module chipmunk.cpDampedSpring;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.cpConstraint;
import chipmunk.cpBB;

extern (C):
@nogc nothrow:

alias double function (cpConstraint*, double) cpDampedSpringForceFunc;

cpBool cpConstraintIsDampedSpring (const(cpConstraint)* constraint);
cpDampedSpring* cpDampedSpringAlloc ();
cpDampedSpring* cpDampedSpringInit (cpDampedSpring* joint, cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB, cpFloat restLength, cpFloat stiffness, cpFloat damping);
cpConstraint* cpDampedSpringNew (cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB, cpFloat restLength, cpFloat stiffness, cpFloat damping);
cpVect cpDampedSpringGetAnchorA (const(cpConstraint)* constraint);
void cpDampedSpringSetAnchorA (cpConstraint* constraint, cpVect anchorA);
cpVect cpDampedSpringGetAnchorB (const(cpConstraint)* constraint);
void cpDampedSpringSetAnchorB (cpConstraint* constraint, cpVect anchorB);
cpFloat cpDampedSpringGetRestLength (const(cpConstraint)* constraint);
void cpDampedSpringSetRestLength (cpConstraint* constraint, cpFloat restLength);
cpFloat cpDampedSpringGetStiffness (const(cpConstraint)* constraint);
void cpDampedSpringSetStiffness (cpConstraint* constraint, cpFloat stiffness);
cpFloat cpDampedSpringGetDamping (const(cpConstraint)* constraint);
void cpDampedSpringSetDamping (cpConstraint* constraint, cpFloat damping);
cpDampedSpringForceFunc cpDampedSpringGetSpringForceFunc (const(cpConstraint)* constraint);
void cpDampedSpringSetSpringForceFunc (cpConstraint* constraint, cpDampedSpringForceFunc springForceFunc);
