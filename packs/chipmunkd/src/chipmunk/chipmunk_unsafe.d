module chipmunk.chipmunk_unsafe;

import chipmunk.chipmunk_types;
import chipmunk.chipmunk_structs;

extern (C):
@nogc nothrow:

void cpCircleShapeSetRadius (cpShape* shape, cpFloat radius);
void cpCircleShapeSetOffset (cpShape* shape, cpVect offset);
void cpSegmentShapeSetEndpoints (cpShape* shape, cpVect a, cpVect b);
void cpSegmentShapeSetRadius (cpShape* shape, cpFloat radius);
void cpPolyShapeSetVerts (cpShape* shape, int count, cpVect* verts, cpTransform transform);
void cpPolyShapeSetVertsRaw (cpShape* shape, int count, cpVect* verts);
void cpPolyShapeSetRadius (cpShape* shape, cpFloat radius);
