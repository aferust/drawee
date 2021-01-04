module chipmunk.cpShape;

import chipmunk.chipmunk;
import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.cpBB;
import chipmunk.cpArbiter;

extern (C):
@nogc nothrow:

static const cpShapeFilter CP_SHAPE_FILTER_ALL = {CP_NO_GROUP, CP_ALL_CATEGORIES, CP_ALL_CATEGORIES};

/// Collision filter value for a shape that does not collide with anything.
static const cpShapeFilter CP_SHAPE_FILTER_NONE = {CP_NO_GROUP, ~CP_ALL_CATEGORIES, ~CP_ALL_CATEGORIES};

struct cpPointQueryInfo
{
    const(cpShape)* shape;
    cpVect point;
    cpFloat distance;
    cpVect gradient;
}

struct cpSegmentQueryInfo
{
    const(cpShape)* shape;
    cpVect point;
    cpVect normal;
    cpFloat alpha;
}

struct cpShapeFilter
{
    cpGroup group;
    cpBitmask categories;
    cpBitmask mask;
}

// inlined in chipmunk header
static cpShapeFilter
cpShapeFilterNew(cpGroup group, cpBitmask categories, cpBitmask mask)
{
	cpShapeFilter filter = {group, categories, mask};
	return filter;
}

void cpShapeDestroy (cpShape* shape);
void cpShapeFree (cpShape* shape);
cpBB cpShapeCacheBB (cpShape* shape);
cpBB cpShapeUpdate (cpShape* shape, cpTransform transform);
cpFloat cpShapePointQuery (const(cpShape)* shape, cpVect p, cpPointQueryInfo* out_);
cpBool cpShapeSegmentQuery (const(cpShape)* shape, cpVect a, cpVect b, cpFloat radius, cpSegmentQueryInfo* info);
cpContactPointSet cpShapesCollide (const(cpShape)* a, const(cpShape)* b);
cpSpace* cpShapeGetSpace (const(cpShape)* shape);
cpBody* cpShapeGetBody (const(cpShape)* shape);
void cpShapeSetBody (cpShape* shape, cpBody* body_);
cpFloat cpShapeGetMass (cpShape* shape);
void cpShapeSetMass (cpShape* shape, cpFloat mass);
cpFloat cpShapeGetDensity (cpShape* shape);
void cpShapeSetDensity (cpShape* shape, cpFloat density);
cpFloat cpShapeGetMoment (cpShape* shape);
cpFloat cpShapeGetArea (cpShape* shape);
cpVect cpShapeGetCenterOfGravity (cpShape* shape);
cpBB cpShapeGetBB (const(cpShape)* shape);
cpBool cpShapeGetSensor (const(cpShape)* shape);
void cpShapeSetSensor (cpShape* shape, cpBool sensor);
cpFloat cpShapeGetElasticity (const(cpShape)* shape);
void cpShapeSetElasticity (cpShape* shape, cpFloat elasticity);
cpFloat cpShapeGetFriction (const(cpShape)* shape);
void cpShapeSetFriction (cpShape* shape, cpFloat friction);
cpVect cpShapeGetSurfaceVelocity (const(cpShape)* shape);
void cpShapeSetSurfaceVelocity (cpShape* shape, cpVect surfaceVelocity);
cpDataPointer cpShapeGetUserData (const(cpShape)* shape);
void cpShapeSetUserData (cpShape* shape, cpDataPointer userData);
cpCollisionType cpShapeGetCollisionType (const(cpShape)* shape);
void cpShapeSetCollisionType (cpShape* shape, cpCollisionType collisionType);
cpShapeFilter cpShapeGetFilter (const(cpShape)* shape);
void cpShapeSetFilter (cpShape* shape, cpShapeFilter filter);
cpCircleShape* cpCircleShapeAlloc ();
cpCircleShape* cpCircleShapeInit (cpCircleShape* circle, cpBody* body_, cpFloat radius, cpVect offset);
cpShape* cpCircleShapeNew (cpBody* body_, cpFloat radius, cpVect offset);
cpVect cpCircleShapeGetOffset (const(cpShape)* shape);
cpFloat cpCircleShapeGetRadius (const(cpShape)* shape);
cpSegmentShape* cpSegmentShapeAlloc ();
cpSegmentShape* cpSegmentShapeInit (cpSegmentShape* seg, cpBody* body_, cpVect a, cpVect b, cpFloat radius);
cpShape* cpSegmentShapeNew (cpBody* body_, cpVect a, cpVect b, cpFloat radius);
void cpSegmentShapeSetNeighbors (cpShape* shape, cpVect prev, cpVect next);
cpVect cpSegmentShapeGetA (const(cpShape)* shape);
cpVect cpSegmentShapeGetB (const(cpShape)* shape);
cpVect cpSegmentShapeGetNormal (const(cpShape)* shape);
cpFloat cpSegmentShapeGetRadius (const(cpShape)* shape);
