module chipmunk.cpRotaryLimitJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsRotaryLimitJoint (const(cpConstraint)* constraint);
cpRotaryLimitJoint* cpRotaryLimitJointAlloc ();
cpRotaryLimitJoint* cpRotaryLimitJointInit (cpRotaryLimitJoint* joint, cpBody* a, cpBody* b, cpFloat min, cpFloat max);
cpConstraint* cpRotaryLimitJointNew (cpBody* a, cpBody* b, cpFloat min, cpFloat max);
cpFloat cpRotaryLimitJointGetMin (const(cpConstraint)* constraint);
void cpRotaryLimitJointSetMin (cpConstraint* constraint, cpFloat min);
cpFloat cpRotaryLimitJointGetMax (const(cpConstraint)* constraint);
void cpRotaryLimitJointSetMax (cpConstraint* constraint, cpFloat max);
