module chipmunk.cpSpace;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.cpArbiter;
import chipmunk.cpShape;
import chipmunk.cpBB;

extern (C):
@nogc nothrow:

alias ubyte function (cpArbiter*, cpSpace*, void*) cpCollisionBeginFunc;
alias ubyte function (cpArbiter*, cpSpace*, void*) cpCollisionPreSolveFunc;
alias void function (cpArbiter*, cpSpace*, void*) cpCollisionPostSolveFunc;
alias void function (cpArbiter*, cpSpace*, void*) cpCollisionSeparateFunc;
alias void function (cpSpace*, void*, void*) cpPostStepFunc;
alias void function (cpShape*, cpVect, double, cpVect, void*) cpSpacePointQueryFunc;
alias void function (cpShape*, cpVect, cpVect, double, void*) cpSpaceSegmentQueryFunc;
alias void function (cpShape*, void*) cpSpaceBBQueryFunc;
alias void function (cpShape*, cpContactPointSet*, void*) cpSpaceShapeQueryFunc;
alias void function (cpBody*, void*) cpSpaceBodyIteratorFunc;
alias void function (cpShape*, void*) cpSpaceShapeIteratorFunc;
alias void function (cpConstraint*, void*) cpSpaceConstraintIteratorFunc;
alias void function (cpVect, double, double, cpSpaceDebugColor, cpSpaceDebugColor, void*) cpSpaceDebugDrawCircleImpl;
alias void function (cpVect, cpVect, cpSpaceDebugColor, void*) cpSpaceDebugDrawSegmentImpl;
alias void function (cpVect, cpVect, double, cpSpaceDebugColor, cpSpaceDebugColor, void*) cpSpaceDebugDrawFatSegmentImpl;
alias void function (int, const(cpVect)*, double, cpSpaceDebugColor, cpSpaceDebugColor, void*) cpSpaceDebugDrawPolygonImpl;
alias void function (double, cpVect, cpSpaceDebugColor, void*) cpSpaceDebugDrawDotImpl;
alias cpSpaceDebugColor function (cpShape*, void*) cpSpaceDebugDrawColorForShapeImpl;

enum cpSpaceDebugDrawFlags
{
    CP_SPACE_DEBUG_DRAW_SHAPES = 1,
    CP_SPACE_DEBUG_DRAW_CONSTRAINTS = 2,
    CP_SPACE_DEBUG_DRAW_COLLISION_POINTS = 4
}

struct cpCollisionHandler
{
    const cpCollisionType typeA;
    const cpCollisionType typeB;
    cpCollisionBeginFunc beginFunc;
    cpCollisionPreSolveFunc preSolveFunc;
    cpCollisionPostSolveFunc postSolveFunc;
    cpCollisionSeparateFunc separateFunc;
    cpDataPointer userData;
}

struct cpSpaceDebugColor
{
    float r;
    float g;
    float b;
    float a;
}

struct cpSpaceDebugDrawOptions
{
    cpSpaceDebugDrawCircleImpl drawCircle;
    cpSpaceDebugDrawSegmentImpl drawSegment;
    cpSpaceDebugDrawFatSegmentImpl drawFatSegment;
    cpSpaceDebugDrawPolygonImpl drawPolygon;
    cpSpaceDebugDrawDotImpl drawDot;
    cpSpaceDebugDrawFlags flags;
    cpSpaceDebugColor shapeOutlineColor;
    cpSpaceDebugDrawColorForShapeImpl colorForShape;
    cpSpaceDebugColor constraintColor;
    cpSpaceDebugColor collisionPointColor;
    cpDataPointer data;
}

cpSpace* cpSpaceAlloc ();
cpSpace* cpSpaceInit (cpSpace* space);
cpSpace* cpSpaceNew ();
void cpSpaceDestroy (cpSpace* space);
void cpSpaceFree (cpSpace* space);
int cpSpaceGetIterations (const(cpSpace)* space);
void cpSpaceSetIterations (cpSpace* space, int iterations);
cpVect cpSpaceGetGravity (const(cpSpace)* space);
void cpSpaceSetGravity (cpSpace* space, cpVect gravity);
cpFloat cpSpaceGetDamping (const(cpSpace)* space);
void cpSpaceSetDamping (cpSpace* space, cpFloat damping);
cpFloat cpSpaceGetIdleSpeedThreshold (const(cpSpace)* space);
void cpSpaceSetIdleSpeedThreshold (cpSpace* space, cpFloat idleSpeedThreshold);
cpFloat cpSpaceGetSleepTimeThreshold (const(cpSpace)* space);
void cpSpaceSetSleepTimeThreshold (cpSpace* space, cpFloat sleepTimeThreshold);
cpFloat cpSpaceGetCollisionSlop (const(cpSpace)* space);
void cpSpaceSetCollisionSlop (cpSpace* space, cpFloat collisionSlop);
cpFloat cpSpaceGetCollisionBias (const(cpSpace)* space);
void cpSpaceSetCollisionBias (cpSpace* space, cpFloat collisionBias);
cpTimestamp cpSpaceGetCollisionPersistence (const(cpSpace)* space);
void cpSpaceSetCollisionPersistence (cpSpace* space, cpTimestamp collisionPersistence);
cpDataPointer cpSpaceGetUserData (const(cpSpace)* space);
void cpSpaceSetUserData (cpSpace* space, cpDataPointer userData);
cpBody* cpSpaceGetStaticBody (const(cpSpace)* space);
cpFloat cpSpaceGetCurrentTimeStep (const(cpSpace)* space);
cpBool cpSpaceIsLocked (cpSpace* space);
cpCollisionHandler* cpSpaceAddDefaultCollisionHandler (cpSpace* space);
cpCollisionHandler* cpSpaceAddCollisionHandler (cpSpace* space, cpCollisionType a, cpCollisionType b);
cpCollisionHandler* cpSpaceAddWildcardHandler (cpSpace* space, cpCollisionType type);
cpShape* cpSpaceAddShape (cpSpace* space, cpShape* shape);
cpBody* cpSpaceAddBody (cpSpace* space, cpBody* body_);
cpConstraint* cpSpaceAddConstraint (cpSpace* space, cpConstraint* constraint);
void cpSpaceRemoveShape (cpSpace* space, cpShape* shape);
void cpSpaceRemoveBody (cpSpace* space, cpBody* body_);
void cpSpaceRemoveConstraint (cpSpace* space, cpConstraint* constraint);
cpBool cpSpaceContainsShape (cpSpace* space, cpShape* shape);
cpBool cpSpaceContainsBody (cpSpace* space, cpBody* body_);
cpBool cpSpaceContainsConstraint (cpSpace* space, cpConstraint* constraint);
cpBool cpSpaceAddPostStepCallback (cpSpace* space, cpPostStepFunc func, void* key, void* data);
void cpSpacePointQuery (cpSpace* space, cpVect point, cpFloat maxDistance, cpShapeFilter filter, cpSpacePointQueryFunc func, void* data);
cpShape* cpSpacePointQueryNearest (cpSpace* space, cpVect point, cpFloat maxDistance, cpShapeFilter filter, cpPointQueryInfo* out_);
void cpSpaceSegmentQuery (cpSpace* space, cpVect start, cpVect end, cpFloat radius, cpShapeFilter filter, cpSpaceSegmentQueryFunc func, void* data);
cpShape* cpSpaceSegmentQueryFirst (cpSpace* space, cpVect start, cpVect end, cpFloat radius, cpShapeFilter filter, cpSegmentQueryInfo* out_);
void cpSpaceBBQuery (cpSpace* space, cpBB bb, cpShapeFilter filter, cpSpaceBBQueryFunc func, void* data);
cpBool cpSpaceShapeQuery (cpSpace* space, cpShape* shape, cpSpaceShapeQueryFunc func, void* data);
void cpSpaceEachBody (cpSpace* space, cpSpaceBodyIteratorFunc func, void* data);
void cpSpaceEachShape (cpSpace* space, cpSpaceShapeIteratorFunc func, void* data);
void cpSpaceEachConstraint (cpSpace* space, cpSpaceConstraintIteratorFunc func, void* data);
void cpSpaceReindexStatic (cpSpace* space);
void cpSpaceReindexShape (cpSpace* space, cpShape* shape);
void cpSpaceReindexShapesForBody (cpSpace* space, cpBody* body_);
void cpSpaceUseSpatialHash (cpSpace* space, cpFloat dim, int count);
void cpSpaceStep (cpSpace* space, cpFloat dt);
void cpSpaceDebugDraw (cpSpace* space, cpSpaceDebugDrawOptions* options);
