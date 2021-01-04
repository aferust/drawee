module chipmunk.cpPinJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsPinJoint (const(cpConstraint)* constraint);
cpPinJoint* cpPinJointAlloc ();
cpPinJoint* cpPinJointInit (cpPinJoint* joint, cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB);
cpConstraint* cpPinJointNew (cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB);
cpVect cpPinJointGetAnchorA (const(cpConstraint)* constraint);
void cpPinJointSetAnchorA (cpConstraint* constraint, cpVect anchorA);
cpVect cpPinJointGetAnchorB (const(cpConstraint)* constraint);
void cpPinJointSetAnchorB (cpConstraint* constraint, cpVect anchorB);
cpFloat cpPinJointGetDist (const(cpConstraint)* constraint);
void cpPinJointSetDist (cpConstraint* constraint, cpFloat dist);
