module chipmunk.cpBody;
import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

alias void function (cpBody*, cpVect, double, double) cpBodyVelocityFunc;
alias void function (cpBody*, double) cpBodyPositionFunc;
alias void function (cpBody*, cpShape*, void*) cpBodyShapeIteratorFunc;
alias void function (cpBody*, cpConstraint*, void*) cpBodyConstraintIteratorFunc;
alias void function (cpBody*, cpArbiter*, void*) cpBodyArbiterIteratorFunc;

enum cpBodyType
{
    CP_BODY_TYPE_DYNAMIC = 0,
    CP_BODY_TYPE_KINEMATIC = 1,
    CP_BODY_TYPE_STATIC = 2
}

cpBody* cpBodyAlloc ();
cpBody* cpBodyInit (cpBody* body_, cpFloat mass, cpFloat moment);
cpBody* cpBodyNew (cpFloat mass, cpFloat moment);
cpBody* cpBodyNewKinematic ();
cpBody* cpBodyNewStatic ();
void cpBodyDestroy (cpBody* body_);
void cpBodyFree (cpBody* body_);
void cpBodyActivate (cpBody* body_);
void cpBodyActivateStatic (cpBody* body_, cpShape* filter);
void cpBodySleep (cpBody* body_);
void cpBodySleepWithGroup (cpBody* body_, cpBody* group);
cpBool cpBodyIsSleeping (const(cpBody)* body_);
cpBodyType cpBodyGetType (cpBody* body_);
void cpBodySetType (cpBody* body_, cpBodyType type);
cpSpace* cpBodyGetSpace (const(cpBody)* body_);
cpFloat cpBodyGetMass (const(cpBody)* body_);
void cpBodySetMass (cpBody* body_, cpFloat m);
cpFloat cpBodyGetMoment (const(cpBody)* body_);
void cpBodySetMoment (cpBody* body_, cpFloat i);
cpVect cpBodyGetPosition (const(cpBody)* body_);
void cpBodySetPosition (cpBody* body_, cpVect pos);
cpVect cpBodyGetCenterOfGravity (const(cpBody)* body_);
void cpBodySetCenterOfGravity (cpBody* body_, cpVect cog);
cpVect cpBodyGetVelocity (const(cpBody)* body_);
void cpBodySetVelocity (cpBody* body_, cpVect velocity);
cpVect cpBodyGetForce (const(cpBody)* body_);
void cpBodySetForce (cpBody* body_, cpVect force);
cpFloat cpBodyGetAngle (const(cpBody)* body_);
void cpBodySetAngle (cpBody* body_, cpFloat a);
cpFloat cpBodyGetAngularVelocity (const(cpBody)* body_);
void cpBodySetAngularVelocity (cpBody* body_, cpFloat angularVelocity);
cpFloat cpBodyGetTorque (const(cpBody)* body_);
void cpBodySetTorque (cpBody* body_, cpFloat torque);
cpVect cpBodyGetRotation (const(cpBody)* body_);
cpDataPointer cpBodyGetUserData (const(cpBody)* body_);
void cpBodySetUserData (cpBody* body_, cpDataPointer userData);
void cpBodySetVelocityUpdateFunc (cpBody* body_, cpBodyVelocityFunc velocityFunc);
void cpBodySetPositionUpdateFunc (cpBody* body_, cpBodyPositionFunc positionFunc);
void cpBodyUpdateVelocity (cpBody* body_, cpVect gravity, cpFloat damping, cpFloat dt);
void cpBodyUpdatePosition (cpBody* body_, cpFloat dt);
cpVect cpBodyLocalToWorld (const(cpBody)* body_, const cpVect point);
cpVect cpBodyWorldToLocal (const(cpBody)* body_, const cpVect point);
void cpBodyApplyForceAtWorldPoint (cpBody* body_, cpVect force, cpVect point);
void cpBodyApplyForceAtLocalPoint (cpBody* body_, cpVect force, cpVect point);
void cpBodyApplyImpulseAtWorldPoint (cpBody* body_, cpVect impulse, cpVect point);
void cpBodyApplyImpulseAtLocalPoint (cpBody* body_, cpVect impulse, cpVect point);
cpVect cpBodyGetVelocityAtWorldPoint (const(cpBody)* body_, cpVect point);
cpVect cpBodyGetVelocityAtLocalPoint (const(cpBody)* body_, cpVect point);
cpFloat cpBodyKineticEnergy (const(cpBody)* body_);
void cpBodyEachShape (cpBody* body_, cpBodyShapeIteratorFunc func, void* data);
void cpBodyEachConstraint (cpBody* body_, cpBodyConstraintIteratorFunc func, void* data);
void cpBodyEachArbiter (cpBody* body_, cpBodyArbiterIteratorFunc func, void* data);
