module chipmunk.cpPolyline;

import chipmunk.cpVect;
import chipmunk.chipmunk_types;

extern (C):

struct cpPolyline
{
    int count;
    int capacity;
    cpVect[] verts;
}

struct cpPolylineSet
{
    int count;
    int capacity;
    cpPolyline** lines;
}
@nogc nothrow:

void cpPolylineFree (cpPolyline* line);
cpBool cpPolylineIsClosed (cpPolyline* line);
cpPolyline* cpPolylineSimplifyCurves (cpPolyline* line, cpFloat tol);
cpPolyline* cpPolylineSimplifyVertexes (cpPolyline* line, cpFloat tol);
cpPolyline* cpPolylineToConvexHull (cpPolyline* line, cpFloat tol);
cpPolylineSet* cpPolylineSetAlloc ();
cpPolylineSet* cpPolylineSetInit (cpPolylineSet* set);
cpPolylineSet* cpPolylineSetNew ();
void cpPolylineSetDestroy (cpPolylineSet* set, cpBool freePolylines);
void cpPolylineSetFree (cpPolylineSet* set, cpBool freePolylines);
void cpPolylineSetCollectSegment (cpVect v0, cpVect v1, cpPolylineSet* lines);
cpPolylineSet* cpPolylineConvexDecomposition (cpPolyline* line, cpFloat tol);
