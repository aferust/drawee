/* Copyright (c) 2007 Scott Lembcke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
import chipmunk;
import chipmunk.chipmunk_unsafe;

import std.string;
import core.stdc.stdlib;

import ChipmunkDemo;

enum DENSITY = (1.0/10000.0);

static cpShape *shape;

static void
update(cpSpace *space, double dt)
{
	cpFloat tolerance = 2.0;
	
	if(ChipmunkDemoRightClick && cpShapePointQuery(shape, ChipmunkDemoMouse, null) > tolerance){
		cpBody *body_ = cpShapeGetBody(shape);
		int count = cpPolyShapeGetCount(shape);
		
		// Allocate the space for the new vertexes on the stack.
		cpVect *verts = cast(cpVect *)alloca((count + 1)*cpVect.sizeof);
		
		for(int i=0; i<count; i++){
			verts[i] = cpPolyShapeGetVert(shape, i);
		}
		
		verts[count] = cpBodyWorldToLocal(body_, ChipmunkDemoMouse);
		
		// This function builds a convex hull for the vertexes.
		// Because the result array is the same as verts, it will reduce it in place.
		int hullCount = cpConvexHull(count + 1, verts, verts, null, tolerance);
		
		// Figure out how much to shift the body_ by.
		cpVect centroid = cpCentroidForPoly(hullCount, verts);
		
		// Recalculate the body_ properties to match the updated shape.
		cpFloat mass = cpAreaForPoly(hullCount, verts, 0.0f)*DENSITY;
		cpBodySetMass(body_, mass);
		cpBodySetMoment(body_, cpMomentForPoly(mass, hullCount, verts, cpvneg(centroid), 0.0f));
		cpBodySetPosition(body_, cpBodyLocalToWorld(body_, centroid));
		
		// Use the setter function from chipmunk_unsafe.h.
		// You could also remove and recreate the shape if you wanted.
		cpPolyShapeSetVerts(shape, hullCount, verts, cpTransformTranslate(cpvneg(centroid)));
	}
	
	cpSpaceStep(space, dt);
}

static cpSpace *
init()
{
	ChipmunkDemoMessageString = "Right click and drag to change the blocks's shape.".toStringz;
	
	cpSpace *space = cpSpaceNew();
	cpSpaceSetIterations(space, 30);
	cpSpaceSetGravity(space, cpv(0, -500));
	cpSpaceSetSleepTimeThreshold(space, 0.5f);
	cpSpaceSetCollisionSlop(space, 0.5f);
	
	cpBody *body_, staticBody = cpSpaceGetStaticBody(space);
	
	// Create segments around the edge of the screen.
	shape = cpSpaceAddShape(space, cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(320,-240), 0.0f));
	cpShapeSetElasticity(shape, 1.0f);
	cpShapeSetFriction(shape, 1.0f);
	cpShapeSetFilter(shape, NOT_GRABBABLE_FILTER);

	cpFloat width = 50.0f;
	cpFloat height = 70.0f;
	cpFloat mass = width*height*DENSITY;
	cpFloat moment = cpMomentForBox(mass, width, height);
	
	body_ = cpSpaceAddBody(space, cpBodyNew(mass, moment));
	
	shape = cpSpaceAddShape(space, cpBoxShapeNew(body_, width, height, 0.0));
	cpShapeSetFriction(shape, 0.6f);
		
	return space;
}

static void
destroy(cpSpace *space)
{
	ChipmunkDemoFreeSpaceChildren(space);
	cpSpaceFree(space);
}

ChipmunkDemo Convex = {
	"Convex.",
	1.0/60.0,
	&init,
	&update,
	&ChipmunkDemoDefaultDrawImpl,
	&destroy,
};
