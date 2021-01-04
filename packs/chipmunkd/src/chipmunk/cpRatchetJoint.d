module chipmunk.cpRatchetJoint;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsRatchetJoint (const(cpConstraint)* constraint);
cpRatchetJoint* cpRatchetJointAlloc ();
cpRatchetJoint* cpRatchetJointInit (cpRatchetJoint* joint, cpBody* a, cpBody* b, cpFloat phase, cpFloat ratchet);
cpConstraint* cpRatchetJointNew (cpBody* a, cpBody* b, cpFloat phase, cpFloat ratchet);
cpFloat cpRatchetJointGetAngle (const(cpConstraint)* constraint);
void cpRatchetJointSetAngle (cpConstraint* constraint, cpFloat angle);
cpFloat cpRatchetJointGetPhase (const(cpConstraint)* constraint);
void cpRatchetJointSetPhase (cpConstraint* constraint, cpFloat phase);
cpFloat cpRatchetJointGetRatchet (const(cpConstraint)* constraint);
void cpRatchetJointSetRatchet (cpConstraint* constraint, cpFloat ratchet);
