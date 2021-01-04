module chipmunk.cpSlideJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsSlideJoint (const(cpConstraint)* constraint);
cpSlideJoint* cpSlideJointAlloc ();
cpSlideJoint* cpSlideJointInit (cpSlideJoint* joint, cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB, cpFloat min, cpFloat max);
cpConstraint* cpSlideJointNew (cpBody* a, cpBody* b, cpVect anchorA, cpVect anchorB, cpFloat min, cpFloat max);
cpVect cpSlideJointGetAnchorA (const(cpConstraint)* constraint);
void cpSlideJointSetAnchorA (cpConstraint* constraint, cpVect anchorA);
cpVect cpSlideJointGetAnchorB (const(cpConstraint)* constraint);
void cpSlideJointSetAnchorB (cpConstraint* constraint, cpVect anchorB);
cpFloat cpSlideJointGetMin (const(cpConstraint)* constraint);
void cpSlideJointSetMin (cpConstraint* constraint, cpFloat min);
cpFloat cpSlideJointGetMax (const(cpConstraint)* constraint);
void cpSlideJointSetMax (cpConstraint* constraint, cpFloat max);
