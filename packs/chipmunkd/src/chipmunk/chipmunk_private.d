module chipmunk.chipmunk_private;

import chipmunk.chipmunk;
import chipmunk.cpVect;
import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.cpSpace;
import chipmunk.cpSpatialIndex;
import chipmunk.cpArbiter;
import chipmunk.cpShape;
import chipmunk.cpBody;

extern (C):
@nogc nothrow:

enum ulong CP_HASH_COEF = 3344921057;
auto CP_HASH_PAIR(TA, TB)(TA A, TB B) {
    return cast(cpHashValue)(A)*CP_HASH_COEF ^ cast(cpHashValue)(B)*CP_HASH_COEF;
}

alias ubyte function (void*, void*) cpHashSetEqlFunc;
alias void* function (void*, void*) cpHashSetTransFunc;
alias void function (void*, void*) cpHashSetIteratorFunc;
alias ubyte function (void*, void*) cpHashSetFilterFunc;

extern __gshared cpCollisionHandler cpCollisionHandlerDoNothing;

cpArray* cpArrayNew (int size);
void cpArrayFree (cpArray* arr);
void cpArrayPush (cpArray* arr, void* object);
void* cpArrayPop (cpArray* arr);
void cpArrayDeleteObj (cpArray* arr, void* obj);
cpBool cpArrayContains (cpArray* arr, void* ptr);
void cpArrayFreeEach (cpArray* arr, void function(void*) freeFunc);
cpHashSet* cpHashSetNew (int size, cpHashSetEqlFunc eqlFunc);
void cpHashSetSetDefaultValue (cpHashSet* set, void* default_value);
void cpHashSetFree (cpHashSet* set);
int cpHashSetCount (cpHashSet* set);
void* cpHashSetInsert (cpHashSet* set, cpHashValue hash, void* ptr, cpHashSetTransFunc trans, void* data);
void* cpHashSetRemove (cpHashSet* set, cpHashValue hash, void* ptr);
void* cpHashSetFind (cpHashSet* set, cpHashValue hash, void* ptr);
void cpHashSetEach (cpHashSet* set, cpHashSetIteratorFunc func, void* data);
void cpHashSetFilter (cpHashSet* set, cpHashSetFilterFunc func, void* data);
void cpBodyAddShape (cpBody* body_, cpShape* shape);
void cpBodyRemoveShape (cpBody* body_, cpShape* shape);
void cpBodyAccumulateMassFromShapes (cpBody* body_);
void cpBodyRemoveConstraint (cpBody* body_, cpConstraint* constraint);
cpSpatialIndex* cpSpatialIndexInit (cpSpatialIndex* index, cpSpatialIndexClass* klass, cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
cpArbiter* cpArbiterInit (cpArbiter* arb, cpShape* a, cpShape* b);
void cpArbiterUnthread (cpArbiter* arb);
void cpArbiterUpdate (cpArbiter* arb, cpCollisionInfo* info, cpSpace* space);
void cpArbiterPreStep (cpArbiter* arb, cpFloat dt, cpFloat bias, cpFloat slop);
void cpArbiterApplyCachedImpulse (cpArbiter* arb, cpFloat dt_coef);
void cpArbiterApplyImpulse (cpArbiter* arb);
cpShape* cpShapeInit (cpShape* shape, const(cpShapeClass)* klass, cpBody* body_, cpShapeMassInfo massInfo);
cpCollisionInfo cpCollide (const(cpShape)* a, const(cpShape)* b, cpCollisionID id, cpContact* contacts);
void CircleSegmentQuery (cpShape* shape, cpVect center, cpFloat r1, cpVect a, cpVect b, cpFloat r2, cpSegmentQueryInfo* info);
cpBool cpShapeFilterReject (cpShapeFilter a, cpShapeFilter b);
void cpLoopIndexes (const(cpVect)* verts, int count, int* start, int* end);
void cpConstraintInit (cpConstraint* constraint, const(cpConstraintClass)* klass, cpBody* a, cpBody* b);
void cpConstraintActivateBodies (cpConstraint* constraint);
void cpSpaceSetStaticBody (cpSpace* space, cpBody* body_);
void cpSpaceProcessComponents (cpSpace* space, cpFloat dt);
void cpSpacePushFreshContactBuffer (cpSpace* space);
cpContact* cpContactBufferGetArray (cpSpace* space);
void cpSpacePushContacts (cpSpace* space, int count);
cpPostStepCallback* cpSpaceGetPostStepCallback (cpSpace* space, void* key);
cpBool cpSpaceArbiterSetFilter (cpArbiter* arb, cpSpace* space);
void cpSpaceFilterArbiters (cpSpace* space, cpBody* body_, cpShape* filter);
void cpSpaceActivateBody (cpSpace* space, cpBody* body_);
void cpSpaceLock (cpSpace* space);
void cpSpaceUnlock (cpSpace* space, cpBool runPostStep);
void cpSpaceUncacheArbiter (cpSpace* space, cpArbiter* arb);
cpArray* cpSpaceArrayForBodyType (cpSpace* space, cpBodyType type);
void cpShapeUpdateFunc (cpShape* shape, void* unused);
cpCollisionID cpSpaceCollideShapes (cpShape* a, cpShape* b, cpCollisionID id, cpSpace* space);
cpConstraint* cpConstraintNext (cpConstraint* node, cpBody* body_);
cpArbiter* cpArbiterNext (cpArbiter* node, cpBody* body_);

// functions inlined in chipmunk headers:

static cpArbiterThread *
cpArbiterThreadForBody(cpArbiter *arb, cpBody *body_)
{
	return (arb.body_a == body_ ? &arb.thread_a : &arb.thread_b);
}

static cpBool
cpShapeActive(cpShape *shape)
{
	// checks if the shape is added to a shape list.
	// TODO could this just check the space now?
	return (shape.prev || (shape.body_ && shape.body_.shapeList == shape));
}

static void
CircleSegmentQuery(cpShape *shape, cpVect center, cpFloat r1, cpVect a, cpVect b, cpFloat r2, cpSegmentQueryInfo *info)
{
	cpVect da = cpvsub(a, center);
	cpVect db = cpvsub(b, center);
	cpFloat rsum = r1 + r2;

	cpFloat qa = cpvdot(da, da) - 2.0f*cpvdot(da, db) + cpvdot(db, db);
	cpFloat qb = cpvdot(da, db) - cpvdot(da, da);
	cpFloat det = qb*qb - qa*(cpvdot(da, da) - rsum*rsum);

	if(det >= 0.0f){
		cpFloat t = (-qb - cpfsqrt(det))/(qa);
		if(0.0f<= t && t <= 1.0f){
			cpVect n = cpvnormalize(cpvlerp(da, db, t));

			info.shape = shape;
			info.point = cpvsub(cpvlerp(a, b, t), cpvmult(n, r2));
			info.normal = n;
			info.alpha = t;
		}
	}
}

static cpBool
cpShapeFilterReject(cpShapeFilter a, cpShapeFilter b)
{
	// Reject the collision if:
	return (
		// They are in the same non-zero group.
		(a.group != 0 && a.group == b.group) ||
		// One of the category/mask combinations fails.
		(a.categories & b.mask) == 0 ||
		(b.categories & a.mask) == 0
	);
}

static void
cpConstraintActivateBodies(cpConstraint *constraint)
{
	cpBody *a = constraint.a; cpBodyActivate(a);
	cpBody *b = constraint.b; cpBodyActivate(b);
}

static cpVect
relative_velocity(cpBody *a, cpBody *b, cpVect r1, cpVect r2){
	cpVect v1_sum = cpvadd(a.v, cpvmult(cpvperp(r1), a.w));
	cpVect v2_sum = cpvadd(b.v, cpvmult(cpvperp(r2), b.w));

	return cpvsub(v2_sum, v1_sum);
}

static cpFloat
normal_relative_velocity(cpBody *a, cpBody *b, cpVect r1, cpVect r2, cpVect n){
	return cpvdot(relative_velocity(a, b, r1, r2), n);
}

static void
apply_impulse(cpBody *body_, cpVect j, cpVect r){
	body_.v = cpvadd(body_.v, cpvmult(j, body_.m_inv));
	body_.w += body_.i_inv*cpvcross(r, j);
}

static void
apply_impulses(cpBody *a , cpBody *b, cpVect r1, cpVect r2, cpVect j)
{
	apply_impulse(a, cpvneg(j), r1);
	apply_impulse(b, j, r2);
}

static void
apply_bias_impulse(cpBody *body_, cpVect j, cpVect r)
{
	body_.v_bias = cpvadd(body_.v_bias, cpvmult(j, body_.m_inv));
	body_.w_bias += body_.i_inv*cpvcross(r, j);
}

static void
apply_bias_impulses(cpBody *a , cpBody *b, cpVect r1, cpVect r2, cpVect j)
{
	apply_bias_impulse(a, cpvneg(j), r1);
	apply_bias_impulse(b, j, r2);
}

static cpFloat
k_scalar_body(cpBody *body_, cpVect r, cpVect n)
{
	cpFloat rcn = cpvcross(r, n);
	return body_.m_inv + body_.i_inv*rcn*rcn;
}

static cpFloat
k_scalar(cpBody *a, cpBody *b, cpVect r1, cpVect r2, cpVect n)
{
	cpFloat value = k_scalar_body(a, r1, n) + k_scalar_body(b, r2, n);
	cpAssertSoft(value != 0.0, "Unsolvable collision or constraint.");

	return value;
}

static cpMat2x2
k_tensor(cpBody *a, cpBody *b, cpVect r1, cpVect r2)
{
	cpFloat m_sum = a.m_inv + b.m_inv;

	// start with Identity*m_sum
	cpFloat k11 = m_sum, k12 = 0.0f;
	cpFloat k21 = 0.0f,  k22 = m_sum;

	// add the influence from r1
	cpFloat a_i_inv = a.i_inv;
	cpFloat r1xsq =  r1.x * r1.x * a_i_inv;
	cpFloat r1ysq =  r1.y * r1.y * a_i_inv;
	cpFloat r1nxy = -r1.x * r1.y * a_i_inv;
	k11 += r1ysq; k12 += r1nxy;
	k21 += r1nxy; k22 += r1xsq;

	// add the influnce from r2
	cpFloat b_i_inv = b.i_inv;
	cpFloat r2xsq =  r2.x * r2.x * b_i_inv;
	cpFloat r2ysq =  r2.y * r2.y * b_i_inv;
	cpFloat r2nxy = -r2.x * r2.y * b_i_inv;
	k11 += r2ysq; k12 += r2nxy;
	k21 += r2nxy; k22 += r2xsq;

	// invert
	cpFloat det = k11*k22 - k12*k21;
	cpAssertSoft(det != 0.0, "Unsolvable constraint.");

	cpFloat det_inv = 1.0f/det;
	return cpMat2x2New(
		 k22*det_inv, -k12*det_inv,
		-k21*det_inv,  k11*det_inv
 	);
}

static cpFloat
bias_coef(cpFloat errorBias, cpFloat dt)
{
	return 1.0f - cpfpow(errorBias, dt);
}

static void
cpSpaceUncacheArbiter(cpSpace *space, cpArbiter *arb)
{
	const cpShape* a = arb.a, b = arb.b;
	const cpShape*[2] shape_pair = [a, b];
	cpHashValue arbHashID = cast(uint)CP_HASH_PAIR(cast(cpHashValue)a, cast(cpHashValue)b);
	cpHashSetRemove(space.cachedArbiters, arbHashID, cast(void*) shape_pair.ptr);
	cpArrayDeleteObj(space.arbiters, arb);
}

static cpArray *
cpSpaceArrayForBodyType(cpSpace *space, cpBodyType type)
{
	return (type == cpBodyType.CP_BODY_TYPE_STATIC ? space.staticBodies : space.dynamicBodies);
}

static cpConstraint *
cpConstraintNext(cpConstraint *node, cpBody *body_)
{
	return (node.a == body_ ? node.next_a : node.next_b);
}

static cpArbiter *
cpArbiterNext(cpArbiter *node, cpBody *body_)
{
	return (node.body_a == body_ ? node.thread_a.next : node.thread_b.next);
}
