module chipmunk.chipmunk_structs;

import chipmunk.chipmunk;
import chipmunk.chipmunk_types;
import chipmunk.cpBB;
import chipmunk.cpShape;
import chipmunk.cpBody;
import chipmunk.cpSpace;
import chipmunk.cpConstraint;
import chipmunk.cpDampedSpring;
import chipmunk.cpDampedRotarySpring;
import chipmunk.cpSpatialIndex;

extern (C):
@nogc nothrow:

alias cpBB function (cpShape*, cpTransform) cpShapeCacheDataImpl;
alias void function (cpShape*) cpShapeDestroyImpl;
alias void function (const(cpShape)*, cpVect, cpPointQueryInfo*) cpShapePointQueryImpl;
alias void function (const(cpShape)*, cpVect, cpVect, double, cpSegmentQueryInfo*) cpShapeSegmentQueryImpl;
alias void function (cpConstraint*, double) cpConstraintPreStepImpl;
alias void function (cpConstraint*, double) cpConstraintApplyCachedImpulseImpl;
alias void function (cpConstraint*, double) cpConstraintApplyImpulseImpl;
alias double function (cpConstraint*) cpConstraintGetImpulseImpl;
alias void function (cpArbiter*) cpSpaceArbiterApplyImpulseFunc;

enum cpArbiterState
{
    CP_ARBITER_STATE_FIRST_COLLISION = 0,
    CP_ARBITER_STATE_NORMAL = 1,
    CP_ARBITER_STATE_IGNORE = 2,
    CP_ARBITER_STATE_CACHED = 3,
    CP_ARBITER_STATE_INVALIDATED = 4
}

enum cpShapeType
{
    CP_CIRCLE_SHAPE = 0,
    CP_SEGMENT_SHAPE = 1,
    CP_POLY_SHAPE = 2,
    CP_NUM_SHAPES = 3
}

struct cpArray
{
    int num;
    int max;
    void** arr;
}

struct cpBody
{
    cpBodyVelocityFunc velocity_func;
    cpBodyPositionFunc position_func;
    cpFloat m;
    cpFloat m_inv;
    cpFloat i;
    cpFloat i_inv;
    cpVect cog;
    cpVect p;
    cpVect v;
    cpVect f;
    cpFloat a;
    cpFloat w;
    cpFloat t;
    cpTransform transform;
    cpDataPointer userData;
    cpVect v_bias;
    cpFloat w_bias;
    cpSpace* space;
    cpShape* shapeList;
    cpArbiter* arbiterList;
    cpConstraint* constraintList;

    private struct Sleeping
    {
        cpBody* root;
        cpBody* next;
        cpFloat idleTime;
    }
	Sleeping sleeping;
}

struct cpArbiterThread
{
    cpArbiter* next;
    cpArbiter* prev;
}

struct cpContact
{
    cpVect r1;
    cpVect r2;
    cpFloat nMass;
    cpFloat tMass;
    cpFloat bounce;
    cpFloat jnAcc;
    cpFloat jtAcc;
    cpFloat jBias;
    cpFloat bias;
    cpHashValue hash;
}

struct cpCollisionInfo
{
    const(cpShape)* a;
    const(cpShape)* b;
    cpCollisionID id;
    cpVect n;
    int count;
    cpContact* arr;
}

struct cpArbiter
{
    cpFloat e;
    cpFloat u;
    cpVect surface_vr;
    cpDataPointer data;
    const(cpShape)* a;
    const(cpShape)* b;
    cpBody* body_a;
    cpBody* body_b;
    cpArbiterThread thread_a;
    cpArbiterThread thread_b;
    int count;
    cpContact* contacts;
    cpVect n;
    cpCollisionHandler* handler;
    cpCollisionHandler* handlerA;
    cpCollisionHandler* handlerB;
    cpBool swapped;
    cpTimestamp stamp;
    enum cpArbiterState
    {
        CP_ARBITER_STATE_FIRST_COLLISION = 0,
        CP_ARBITER_STATE_NORMAL = 1,
        CP_ARBITER_STATE_IGNORE = 2,
        CP_ARBITER_STATE_CACHED = 3,
        CP_ARBITER_STATE_INVALIDATED = 4
    }
    cpArbiterState state;
}

struct cpShapeMassInfo
{
    cpFloat m;
    cpFloat i;
    cpVect cog;
    cpFloat area;
}

struct cpShapeClass
{
    cpShapeType type;
    cpShapeCacheDataImpl cacheData;
    cpShapeDestroyImpl destroy;
    cpShapePointQueryImpl pointQuery;
    cpShapeSegmentQueryImpl segmentQuery;
}

struct cpShape
{
    const(cpShapeClass)* klass;
    cpSpace* space;
    cpBody* body_;
    cpShapeMassInfo massInfo;
    cpBB bb;
    cpBool sensor;
    cpFloat e;
    cpFloat u;
    cpVect surfaceV;
    cpDataPointer userData;
    cpCollisionType type;
    cpShapeFilter filter;
    cpShape* next;
    cpShape* prev;
    cpHashValue hashid;
}

struct cpCircleShape
{
    cpShape shape;
    cpVect c;
    cpVect tc;
    cpFloat r;
}

struct cpSegmentShape
{
    cpShape shape;
    cpVect a;
    cpVect b;
    cpVect n;
    cpVect ta;
    cpVect tb;
    cpVect tn;
    cpFloat r;
    cpVect a_tangent;
    cpVect b_tangent;
}

struct cpSplittingPlane
{
    cpVect v0;
    cpVect n;
}

struct cpPolyShape
{
    cpShape shape;
    cpFloat r;
    int count;
    cpSplittingPlane* planes;
    cpSplittingPlane[12] _planes;
}

struct cpConstraintClass
{
    cpConstraintPreStepImpl preStep;
    cpConstraintApplyCachedImpulseImpl applyCachedImpulse;
    cpConstraintApplyImpulseImpl applyImpulse;
    cpConstraintGetImpulseImpl getImpulse;
}

struct cpConstraint
{
    const(cpConstraintClass)* klass;
    cpSpace* space;
    cpBody* a;
    cpBody* b;
    cpConstraint* next_a;
    cpConstraint* next_b;
    cpFloat maxForce;
    cpFloat errorBias;
    cpFloat maxBias;
    cpBool collideBodies;
    cpConstraintPreSolveFunc preSolve;
    cpConstraintPostSolveFunc postSolve;
    cpDataPointer userData;
}

struct cpPinJoint
{
    cpConstraint constraint;
    cpVect anchorA;
    cpVect anchorB;
    cpFloat dist;
    cpVect r1;
    cpVect r2;
    cpVect n;
    cpFloat nMass;
    cpFloat jnAcc;
    cpFloat bias;
}

struct cpSlideJoint
{
    cpConstraint constraint;
    cpVect anchorA;
    cpVect anchorB;
    cpFloat min;
    cpFloat max;
    cpVect r1;
    cpVect r2;
    cpVect n;
    cpFloat nMass;
    cpFloat jnAcc;
    cpFloat bias;
}

struct cpPivotJoint
{
    cpConstraint constraint;
    cpVect anchorA;
    cpVect anchorB;
    cpVect r1;
    cpVect r2;
    cpMat2x2 k;
    cpVect jAcc;
    cpVect bias;
}

struct cpGrooveJoint
{
    cpConstraint constraint;
    cpVect grv_n;
    cpVect grv_a;
    cpVect grv_b;
    cpVect anchorB;
    cpVect grv_tn;
    cpFloat clamp;
    cpVect r1;
    cpVect r2;
    cpMat2x2 k;
    cpVect jAcc;
    cpVect bias;
}

struct cpDampedSpring
{
    cpConstraint constraint;
    cpVect anchorA;
    cpVect anchorB;
    cpFloat restLength;
    cpFloat stiffness;
    cpFloat damping;
    cpDampedSpringForceFunc springForceFunc;
    cpFloat target_vrn;
    cpFloat v_coef;
    cpVect r1;
    cpVect r2;
    cpFloat nMass;
    cpVect n;
    cpFloat jAcc;
}

struct cpDampedRotarySpring
{
    cpConstraint constraint;
    cpFloat restAngle;
    cpFloat stiffness;
    cpFloat damping;
    cpDampedRotarySpringTorqueFunc springTorqueFunc;
    cpFloat target_wrn;
    cpFloat w_coef;
    cpFloat iSum;
    cpFloat jAcc;
}

struct cpRotaryLimitJoint
{
    cpConstraint constraint;
    cpFloat min;
    cpFloat max;
    cpFloat iSum;
    cpFloat bias;
    cpFloat jAcc;
}

struct cpRatchetJoint
{
    cpConstraint constraint;
    cpFloat angle;
    cpFloat phase;
    cpFloat ratchet;
    cpFloat iSum;
    cpFloat bias;
    cpFloat jAcc;
}

struct cpGearJoint
{
    cpConstraint constraint;
    cpFloat phase;
    cpFloat ratio;
    cpFloat ratio_inv;
    cpFloat iSum;
    cpFloat bias;
    cpFloat jAcc;
}

struct cpSimpleMotor
{
    cpConstraint constraint;
    cpFloat rate;
    cpFloat iSum;
    cpFloat jAcc;
}

struct cpSpace
{
    int iterations;
    cpVect gravity;
    cpFloat damping;
    cpFloat idleSpeedThreshold;
    cpFloat sleepTimeThreshold;
    cpFloat collisionSlop;
    cpFloat collisionBias;
    cpTimestamp collisionPersistence;
    cpDataPointer userData;
    cpTimestamp stamp;
    cpFloat curr_dt;
    cpArray* dynamicBodies;
    cpArray* staticBodies;
    cpArray* rousedBodies;
    cpArray* sleepingComponents;
    cpHashValue shapeIDCounter;
    cpSpatialIndex* staticShapes;
    cpSpatialIndex* dynamicShapes;
    cpArray* constraints;
    cpArray* arbiters;
    cpContactBufferHeader* contactBuffersHead;
    cpHashSet* cachedArbiters;
    cpArray* pooledArbiters;
    cpArray* allocatedBuffers;
    uint locked;
    cpBool usesWildcards;
    cpHashSet* collisionHandlers;
    cpCollisionHandler defaultHandler;
    cpBool skipPostStep;
    cpArray* postStepCallbacks;
    cpBody* staticBody;
    cpBody _staticBody;
}

struct cpPostStepCallback
{
    cpPostStepFunc func;
    void* key;
    void* data;
}

struct cpContactBufferHeader;
