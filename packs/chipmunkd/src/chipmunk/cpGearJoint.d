module chipmunk.cpGearJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsGearJoint (const(cpConstraint)* constraint);
cpGearJoint* cpGearJointAlloc ();
cpGearJoint* cpGearJointInit (cpGearJoint* joint, cpBody* a, cpBody* b, cpFloat phase, cpFloat ratio);
cpConstraint* cpGearJointNew (cpBody* a, cpBody* b, cpFloat phase, cpFloat ratio);
cpFloat cpGearJointGetPhase (const(cpConstraint)* constraint);
void cpGearJointSetPhase (cpConstraint* constraint, cpFloat phase);
cpFloat cpGearJointGetRatio (const(cpConstraint)* constraint);
void cpGearJointSetRatio (cpConstraint* constraint, cpFloat ratio);
