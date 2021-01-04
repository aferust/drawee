module chipmunk.cpPivotJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsPivotJoint (const(cpConstraint)* constraint);
cpPivotJoint* cpPivotJointAlloc ();
cpPivotJoint* cpPivotJointInit (cpPivotJoint* joint, cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB);
cpConstraint* cpPivotJointNew (cpBody* a, cpBody* b, cpVect pivot);
cpConstraint* cpPivotJointNew2 (cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB);
cpVect cpPivotJointGetAnchorA (const(cpConstraint)* constraint);
void cpPivotJointSetAnchorA (cpConstraint* constraint, cpVect anchorA);
cpVect cpPivotJointGetAnchorB (const(cpConstraint)* constraint);
void cpPivotJointSetAnchorB (cpConstraint* constraint, cpVect anchorB);
