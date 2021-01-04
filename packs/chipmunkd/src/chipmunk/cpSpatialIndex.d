module chipmunk.cpSpatialIndex;
alias c_ulong = ulong;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.cpBB;

extern (C):
@nogc nothrow:

alias cpBB function (void*) cpSpatialIndexBBFunc;
alias void function (void*, void*) cpSpatialIndexIteratorFunc;
alias uint function (void*, void*, uint, void*) cpSpatialIndexQueryFunc;
alias double function (void*, void*, void*) cpSpatialIndexSegmentQueryFunc;
alias cpVect function (void*) cpBBTreeVelocityFunc;
alias void function (cpSpatialIndex*) cpSpatialIndexDestroyImpl;
alias int function (cpSpatialIndex*) cpSpatialIndexCountImpl;
alias void function (cpSpatialIndex*, void function (void*, void*), void*) cpSpatialIndexEachImpl;
alias ubyte function (cpSpatialIndex*, void*, c_ulong) cpSpatialIndexContainsImpl;
alias void function (cpSpatialIndex*, void*, c_ulong) cpSpatialIndexInsertImpl;
alias void function (cpSpatialIndex*, void*, c_ulong) cpSpatialIndexRemoveImpl;
alias void function (cpSpatialIndex*) cpSpatialIndexReindexImpl;
alias void function (cpSpatialIndex*, void*, c_ulong) cpSpatialIndexReindexObjectImpl;
alias void function (cpSpatialIndex*, uint function (void*, void*, uint, void*), void*) cpSpatialIndexReindexQueryImpl;
alias void function (cpSpatialIndex*, void*, cpBB, uint function (void*, void*, uint, void*), void*) cpSpatialIndexQueryImpl;
alias void function (cpSpatialIndex*, void*, cpVect, cpVect, double, double function (void*, void*, void*), void*) cpSpatialIndexSegmentQueryImpl;

struct cpSpatialIndex
{
    cpSpatialIndexClass* klass;
    cpSpatialIndexBBFunc bbfunc;
    cpSpatialIndex* staticIndex;
    cpSpatialIndex* dynamicIndex;
}

struct cpSpatialIndexClass
{
    cpSpatialIndexDestroyImpl destroy;
    cpSpatialIndexCountImpl count;
    cpSpatialIndexEachImpl each;
    cpSpatialIndexContainsImpl contains;
    cpSpatialIndexInsertImpl insert;
    cpSpatialIndexRemoveImpl remove;
    cpSpatialIndexReindexImpl reindex;
    cpSpatialIndexReindexObjectImpl reindexObject;
    cpSpatialIndexReindexQueryImpl reindexQuery;
    cpSpatialIndexQueryImpl query;
    cpSpatialIndexSegmentQueryImpl segmentQuery;
}

struct cpBBTree;


struct cpSweep1D;


struct cpSpaceHash;


cpSpaceHash* cpSpaceHashAlloc ();
cpSpatialIndex* cpSpaceHashInit (cpSpaceHash* hash, cpFloat celldim, int numcells, cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
cpSpatialIndex* cpSpaceHashNew (cpFloat celldim, int cells, cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
void cpSpaceHashResize (cpSpaceHash* hash, cpFloat celldim, int numcells);
cpBBTree* cpBBTreeAlloc ();
cpSpatialIndex* cpBBTreeInit (cpBBTree* tree, cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
cpSpatialIndex* cpBBTreeNew (cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
void cpBBTreeOptimize (cpSpatialIndex* index);
void cpBBTreeSetVelocityFunc (cpSpatialIndex* index, cpBBTreeVelocityFunc func);
cpSweep1D* cpSweep1DAlloc ();
cpSpatialIndex* cpSweep1DInit (cpSweep1D* sweep, cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
cpSpatialIndex* cpSweep1DNew (cpSpatialIndexBBFunc bbfunc, cpSpatialIndex* staticIndex);
void cpSpatialIndexFree (cpSpatialIndex* index);
void cpSpatialIndexCollideStatic (cpSpatialIndex* dynamicIndex, cpSpatialIndex* staticIndex, cpSpatialIndexQueryFunc func, void* data);

// inlined in chipmunk headers:

static void cpSpatialIndexDestroy(cpSpatialIndex *index)
{
	if(index.klass) index.klass.destroy(index);
}

/// Get the number of objects in the spatial index.
static int cpSpatialIndexCount(cpSpatialIndex *index)
{
	return index.klass.count(index);
}

/// Iterate the objects in the spatial index. @c func will be called once for each object.
static void cpSpatialIndexEach(cpSpatialIndex *index, cpSpatialIndexIteratorFunc func, void *data)
{
	index.klass.each(index, func, data);
}

/// Returns true if the spatial index contains the given object.
/// Most spatial indexes use hashed storage, so you must provide a hash value too.
static cpBool cpSpatialIndexContains(cpSpatialIndex *index, void *obj, cpHashValue hashid)
{
	return index.klass.contains(index, obj, hashid);
}

/// Add an object to a spatial index.
/// Most spatial indexes use hashed storage, so you must provide a hash value too.
static void cpSpatialIndexInsert(cpSpatialIndex *index, void *obj, cpHashValue hashid)
{
	index.klass.insert(index, obj, hashid);
}

/// Remove an object from a spatial index.
/// Most spatial indexes use hashed storage, so you must provide a hash value too.
static void cpSpatialIndexRemove(cpSpatialIndex *index, void *obj, cpHashValue hashid)
{
	index.klass.remove(index, obj, hashid);
}

/// Perform a full reindex of a spatial index.
static void cpSpatialIndexReindex(cpSpatialIndex *index)
{
	index.klass.reindex(index);
}

/// Reindex a single object in the spatial index.
static void cpSpatialIndexReindexObject(cpSpatialIndex *index, void *obj, cpHashValue hashid)
{
	index.klass.reindexObject(index, obj, hashid);
}

/// Perform a rectangle query against the spatial index, calling @c func for each potential match.
static void cpSpatialIndexQuery(cpSpatialIndex *index, void *obj, cpBB bb, cpSpatialIndexQueryFunc func, void *data)
{
	index.klass.query(index, obj, bb, func, data);
}

/// Perform a segment query against the spatial index, calling @c func for each potential match.
static void cpSpatialIndexSegmentQuery(cpSpatialIndex *index, void *obj, cpVect a, cpVect b, cpFloat t_exit, cpSpatialIndexSegmentQueryFunc func, void *data)
{
	index.klass.segmentQuery(index, obj, a, b, t_exit, func, data);
}

/// Simultaneously reindex and find all colliding objects.
/// @c func will be called once for each potentially overlapping pair of objects found.
/// If the spatial index was initialized with a static index, it will collide it's objects against that as well.
static void cpSpatialIndexReindexQuery(cpSpatialIndex *index, cpSpatialIndexQueryFunc func, void *data)
{
	index.klass.reindexQuery(index, func, data);
}
