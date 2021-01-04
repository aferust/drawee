module chipmunk.cpGrooveJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsGrooveJoint (const(cpConstraint)* constraint);
cpGrooveJoint* cpGrooveJointAlloc ();
cpGrooveJoint* cpGrooveJointInit (cpGrooveJoint* joint, cpBody* a, cpBody* b, cpVect groove_a, cpVect groove_b, cpVect anchorB);
cpConstraint* cpGrooveJointNew (cpBody* a, cpBody* b, cpVect groove_a, cpVect groove_b, cpVect anchorB);
cpVect cpGrooveJointGetGrooveA (const(cpConstraint)* constraint);
void cpGrooveJointSetGrooveA (cpConstraint* constraint, cpVect grooveA);
cpVect cpGrooveJointGetGrooveB (const(cpConstraint)* constraint);
void cpGrooveJointSetGrooveB (cpConstraint* constraint, cpVect grooveB);
cpVect cpGrooveJointGetAnchorB (const(cpConstraint)* constraint);
void cpGrooveJointSetAnchorB (cpConstraint* constraint, cpVect anchorB);
cpBool cpConstraintIsGrooveJoint (const(cpConstraint)* constraint);
