module chipmunk.cpSimpleMotor;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

cpBool cpConstraintIsSimpleMotor (const(cpConstraint)* constraint);
cpSimpleMotor* cpSimpleMotorAlloc ();
cpSimpleMotor* cpSimpleMotorInit (cpSimpleMotor* joint, cpBody* a, cpBody* b, cpFloat rate);
cpConstraint* cpSimpleMotorNew (cpBody* a, cpBody* b, cpFloat rate);
cpFloat cpSimpleMotorGetRate (const(cpConstraint)* constraint);
void cpSimpleMotorSetRate (cpConstraint* constraint, cpFloat rate);
