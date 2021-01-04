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
 
import core.stdc.stdlib;
import core.stdc.stdio;
import core.stdc.math;
import core.stdc.string;

import chipmunk.chipmunk_private;
import chipmunk.chipmunk_unsafe;
import ChipmunkDemo;

static cpShape *shape1, shape2;

static void
update(cpSpace *space, cpFloat dt)
{
	cpSpaceStep(space, dt);
}

static void
draw(cpSpace *space)
{
	ChipmunkDemoDefaultDrawImpl(space);
	cpContact arr[CP_MAX_CONTACTS_PER_ARBITER];
//	cpCollideShapes(shape1, shape2, (cpCollisionID[]){0}, arr);
	cpCollisionInfo info = cpCollideShapes(shape2, shape1, 0x00000000, arr);
}

static cpSpace *
init()
{
	cpSpace *space = cpSpaceNew();
	cpSpaceSetIterations(space, 5);
	space.damping = 0.1;
	
	cpFloat mass = 1.0f;
	
	{
		cpFloat size = 100.0;
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForBox(mass, size, size)));
		cpBodySetPosition(body_, cpv(100.0, 50.0f));
		
		shape1 = cpSpaceAddShape(space, cpBoxShapeNew(body_, size, size, 0.0));
		shape1.group = 1;
	}{
		cpFloat size = 100.0;
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForBox(mass, size, size)));
		cpBodySetPosition(body_, cpv(120.0, -40.0f));
		cpBodySetAngle(body_, 1e-2);
		
		shape2 = cpSpaceAddShape(space, cpBoxShapeNew(body_, size, size, 0.0));
		shape2.group = 1;
	}
	
//	{
//		cpFloat size = 100.0;
//		const int NUM_VERTS = 5;
//		
//		cpVect verts[NUM_VERTS];
//		for(int i=0; i<NUM_VERTS; i++){
//			cpFloat angle = -2*M_PI*i/(cast(cpFloat) NUM_VERTS);
//			verts[i] = cpv(size/2.0*cos(angle), size/2.0*sin(angle));
//		}
//		
//		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForPoly(mass, NUM_VERTS, verts, cpvzero)));
//		cpBodySetPosition(body_, cpv(100.0, 50.0f));
//		
//		shape1 = cpSpaceAddShape(space, cpPolyShapeNew(body_, NUM_VERTS, verts, cpvzero));
//		shape1.group = 1;
//	}
//	{
//		cpFloat size = 100.0;
//		const int NUM_VERTS = 4;
//		
//		cpVect verts[NUM_VERTS];
//		for(int i=0; i<NUM_VERTS; i++){
//			cpFloat angle = -2*M_PI*i/(cast(cpFloat) NUM_VERTS);
//			verts[i] = cpv(size/2.0*cos(angle), size/2.0*sin(angle));
//		}
//		
//		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForPoly(mass, NUM_VERTS, verts, cpvzero)));
//		cpBodySetPosition(body_, cpv(100.0, -50.0f));
//		
//		shape2 = cpSpaceAddShape(space, cpPolyShapeNew(body_, NUM_VERTS, verts, cpvzero));
//		shape2.group = 1;
//	}
//	
//	{
//		cpFloat size = 150.0;
//		cpFloat radius = 25.0;
//		
//		cpVect a = cpv( size/2.0, 0.0);
//		cpVect b = cpv(-size/2.0, 0.0);
//		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForSegment(mass, a, b)));
//		cpBodySetPosition(body_, cpv(0, 25));
//		
//		shape1 = cpSpaceAddShape(space, cpSegmentShapeNew(body_, a, b, radius));
//		shape1.group = 1;
//	}
//	{
//		cpFloat radius = 50.0;
//		
//		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForCircle(mass, 0.0f, radius, cpvzero)));
//		cpBodySetPosition(body_, cpv(0, -25));
//		
//		shape2 = cpSpaceAddShape(space, cpCircleShapeNew(body_, radius, cpvzero));
//		shape2.group = 1;
//	}

	return space;
}

static void
destroy(cpSpace *space)
{
	ChipmunkDemoFreeSpaceChildren(space);
	cpSpaceFree(space);
}

ChipmunkDemo GJK = {
	"GJK",
	1.0f/60.0f,
	&init,
	&update,
	&draw,
	&destroy,
};
