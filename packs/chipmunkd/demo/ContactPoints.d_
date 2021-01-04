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
import ChipmunkDemo;

static cpBool NeverCollide(cpArbiter *arb, cpSpace *space, void *data){return cpFalse;}

static void
update(cpSpace *space, cpFloat dt)
{
	int steps = 1;
	dt = 1.0f/60.0f/cast(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
}

static cpSpace *
init()
{
	cpSpace *space = cpSpaceNew();
	cpSpaceSetIterations(space, 5);
	cpSpaceSetDamping(space, 0.1f);
	
	cpSpaceSetDefaultCollisionHandler(space, NeverCollide, null, null, null, null);
	
	{
		cpFloat mass = 1.0f;
		cpFloat length = 100.0f;
		cpVect a = cpv(-length/2.0f, 0.0f), b = cpv(length/2.0f, 0.0f);
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForSegment(mass, a, b)));
		cpBodySetPos(body_, cpv(-160.0f, -80.0f));
		
		cpSpaceAddShape(space, cpSegmentShapeNew(body_, a, b, 30.0f));
	}
	
	{
		cpFloat mass = 1.0f;
		cpFloat length = 100.0f;
		cpVect a = cpv(-length/2.0f, 0.0f), b = cpv(length/2.0f, 0.0f);
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForSegment(mass, a, b)));
		cpBodySetPos(body_, cpv(-160.0f, 80.0f));
		
		cpSpaceAddShape(space, cpSegmentShapeNew(body_, a, b, 20.0f));
	}
	
	{
		cpFloat mass = 1.0f;
		const int NUM_VERTS = 5;
		
		cpVect verts[NUM_VERTS];
		for(int i=0; i<NUM_VERTS; i++){
			cpFloat angle = -2*M_PI*i/(cast(cpFloat) NUM_VERTS);
			verts[i] = cpv(40*cos(angle), 40*sin(angle));
		}
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForPoly(mass, NUM_VERTS, verts, cpvzero)));
		cpBodySetPos(body_, cpv(-0.0f, -80.0f));
		
		cpSpaceAddShape(space, cpPolyShapeNew(body_, NUM_VERTS, verts, cpvzero));
	}
	
	{
		cpFloat mass = 1.0f;
		const int NUM_VERTS = 4;
		
		cpVect verts[NUM_VERTS];
		for(int i=0; i<NUM_VERTS; i++){
			cpFloat angle = -2*M_PI*i/(cast(cpFloat) NUM_VERTS);
			verts[i] = cpv(60*cos(angle), 60*sin(angle));
		}
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, cpMomentForPoly(mass, NUM_VERTS, verts, cpvzero)));
		cpBodySetPos(body_, cpv(-0.0f, 80.0f));
		
		cpSpaceAddShape(space, cpPolyShapeNew(body_, NUM_VERTS, verts, cpvzero));
	}
	
	{
		cpFloat mass = 1.0f;
		cpFloat r = 60.0f;
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, INFINITY));
		cpBodySetPos(body_, cpv(160.0, -80.0f));
		
		cpSpaceAddShape(space, cpCircleShapeNew(body_, r, cpvzero));
	}
	
	{
		cpFloat mass = 1.0f;
		cpFloat r = 40.0f;
		
		cpBody *body_ = cpSpaceAddBody(space, cpBodyNew(mass, INFINITY));
		cpBodySetPos(body_, cpv(160.0, 80.0f));
		
		cpSpaceAddShape(space, cpCircleShapeNew(body_, r, cpvzero));
	}
	
	return space;
}

static void
destroy(cpSpace *space)
{
	ChipmunkDemoFreeSpaceChildren(space);
	cpSpaceFree(space);
}

ChipmunkDemo ContactPoints = {
	"ContactPoints",
	1.0/60.0,
	&init,
	&update,
	&ChipmunkDemoDefaultDrawImpl,
	&destroy,
};
