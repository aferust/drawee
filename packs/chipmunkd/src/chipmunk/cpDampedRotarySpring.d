module chipmunk.cpDampedRotarySpring;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

alias double function (cpConstraint*, double) cpDampedRotarySpringTorqueFunc;

cpBool cpConstraintIsDampedRotarySpring (const(cpConstraint)* constraint);
cpDampedRotarySpring* cpDampedRotarySpringAlloc ();
cpDampedRotarySpring* cpDampedRotarySpringInit (cpDampedRotarySpring* joint, cpBody* a, cpBody* b, cpFloat restAngle, cpFloat stiffness, cpFloat damping);
cpConstraint* cpDampedRotarySpringNew (cpBody* a, cpBody* b, cpFloat restAngle, cpFloat stiffness, cpFloat damping);
cpFloat cpDampedRotarySpringGetRestAngle (const(cpConstraint)* constraint);
void cpDampedRotarySpringSetRestAngle (cpConstraint* constraint, cpFloat restAngle);
cpFloat cpDampedRotarySpringGetStiffness (const(cpConstraint)* constraint);
void cpDampedRotarySpringSetStiffness (cpConstraint* constraint, cpFloat stiffness);
cpFloat cpDampedRotarySpringGetDamping (const(cpConstraint)* constraint);
void cpDampedRotarySpringSetDamping (cpConstraint* constraint, cpFloat damping);
cpDampedRotarySpringTorqueFunc cpDampedRotarySpringGetSpringTorqueFunc (const(cpConstraint)* constraint);
void cpDampedRotarySpringSetSpringTorqueFunc (cpConstraint* constraint, cpDampedRotarySpringTorqueFunc springTorqueFunc);
