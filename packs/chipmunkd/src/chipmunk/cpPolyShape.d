module chipmunk.cpPolyShape;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;
import chipmunk.cpBB;

extern (C):
@nogc nothrow:

cpPolyShape* cpPolyShapeAlloc ();
cpPolyShape* cpPolyShapeInit (cpPolyShape* poly, cpBody* body_, int count, const(cpVect)* verts, cpTransform transform, cpFloat radius);
cpPolyShape* cpPolyShapeInitRaw (cpPolyShape* poly, cpBody* body_, int count, const(cpVect)* verts, cpFloat radius);
cpShape* cpPolyShapeNew (cpBody* body_, int count, const(cpVect)* verts, cpTransform transform, cpFloat radius);
cpShape* cpPolyShapeNewRaw (cpBody* body_, int count, const(cpVect)* verts, cpFloat radius);
cpPolyShape* cpBoxShapeInit (cpPolyShape* poly, cpBody* body_, cpFloat width, cpFloat height, cpFloat radius);
cpPolyShape* cpBoxShapeInit2 (cpPolyShape* poly, cpBody* body_, cpBB box, cpFloat radius);
cpShape* cpBoxShapeNew (cpBody* body_, cpFloat width, cpFloat height, cpFloat radius);
cpShape* cpBoxShapeNew2 (cpBody* body_, cpBB box, cpFloat radius);
int cpPolyShapeGetCount (const(cpShape)* shape);
cpVect cpPolyShapeGetVert (const(cpShape)* shape, int index);
cpFloat cpPolyShapeGetRadius (const(cpShape)* shape);
