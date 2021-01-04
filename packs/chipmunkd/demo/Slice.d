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

import ChipmunkDemo;
import core.stdc.stdlib;

enum DENSITY = (1.0/10000.0);

static void
ClipPoly(cpSpace *space, cpShape *shape, cpVect n, cpFloat dist)
{
	cpBody *body_ = cpShapeGetBody(shape);
	
	int count = cpPolyShapeGetCount(shape);
	int clippedCount = 0;
	
	cpVect *clipped = cast(cpVect *)alloca((count + 1)*cpVect.sizeof);
	
	for(int i=0, j=count-1; i<count; j=i, i++){
		cpVect a = cpBodyLocalToWorld(body_, cpPolyShapeGetVert(shape, j));
		cpFloat a_dist = cpvdot(a, n) - dist;
		
		if(a_dist < 0.0){
			clipped[clippedCount] = a;
			clippedCount++;
		}
		
		cpVect b = cpBodyLocalToWorld(body_, cpPolyShapeGetVert(shape, i));
		cpFloat b_dist = cpvdot(b, n) - dist;
		
		if(a_dist*b_dist < 0.0f){
			cpFloat t = cpfabs(a_dist)/(cpfabs(a_dist) + cpfabs(b_dist));
			
			clipped[clippedCount] = cpvlerp(a, b, t);
			clippedCount++;
		}
	}
	
	cpVect centroid = cpCentroidForPoly(clippedCount, clipped);
	cpFloat mass = cpAreaForPoly(clippedCount, clipped, 0.0f)*DENSITY;
	cpFloat moment = cpMomentForPoly(mass, clippedCount, clipped, cpvneg(centroid), 0.0f);
	
	cpBody *new_body = cpSpaceAddBody(space, cpBodyNew(mass, moment));
	cpBodySetPosition(new_body, centroid);
	cpBodySetVelocity(new_body, cpBodyGetVelocityAtWorldPoint(body_, centroid));
	cpBodySetAngularVelocity(new_body, cpBodyGetAngularVelocity(body_));
	
	cpTransform transform = cpTransformTranslate(cpvneg(centroid));
	cpShape *new_shape = cpSpaceAddShape(space, cpPolyShapeNew(new_body, clippedCount, clipped, transform, 0.0));
	// Copy whatever properties you have set on the original shape that are important
	cpShapeSetFriction(new_shape, cpShapeGetFriction(shape));
}

// Context structs are annoying, use blocks or closures instead if your compiler supports them.
struct SliceContext {
	cpVect a, b;
	cpSpace *space;
};

extern(C) static void
SliceShapePostStep(cpSpace *space, cpShape *shape, SliceContext *context)
{
	cpVect a = context.a;
	cpVect b = context.b;
	
	// Clipping plane normal and distance.
	cpVect n = cpvnormalize(cpvperp(cpvsub(b, a)));
	cpFloat dist = cpvdot(a, n);
	
	ClipPoly(space, shape, n, dist);
	ClipPoly(space, shape, cpvneg(n), -dist);
	
	cpBody *body_ = cpShapeGetBody(shape);
	cpSpaceRemoveShape(space, shape);
	cpSpaceRemoveBody(space, body_);
	cpShapeFree(shape);
	cpBodyFree(body_);
}

extern(C) static void
SliceQuery(cpShape *shape, cpVect point, cpVect normal, cpFloat alpha, SliceContext *context)
{
	cpVect a = context.a;
	cpVect b = context.b;
	
	// Check that the slice was complete by checking that the endpoints aren't in the sliced shape.
	if(cpShapePointQuery(shape, a, null) > 0.0f && cpShapePointQuery(shape, b, null) > 0.0f){
		// Can't modify the space during a query.
		// Must make a post-step callback to do the actual slicing.
		cpSpaceAddPostStepCallback(context.space, cast(cpPostStepFunc)&SliceShapePostStep, shape, context);
	}
}

static void
update(cpSpace *space, double dt)
{
	cpSpaceStep(space, dt);
	
	static cpBool lastClickState = cpFalse;
	static cpVect sliceStart = {0.0, 0.0};
	
	// Annoying state tracking code that you wouldn't need
	// in a real event driven system.
	if(ChipmunkDemoRightClick != lastClickState){
		if(ChipmunkDemoRightClick){
			// MouseDown
			sliceStart = ChipmunkDemoMouse;
		} else {
			// MouseUp
			SliceContext context = {sliceStart, ChipmunkDemoMouse, space};
			cpSpaceSegmentQuery(space, sliceStart, ChipmunkDemoMouse, 0.0, GRAB_FILTER, cast(cpSpaceSegmentQueryFunc)&SliceQuery, &context);
		}
		
		lastClickState = ChipmunkDemoRightClick;
	}
	
	if(ChipmunkDemoRightClick){
		ChipmunkDebugDrawSegment(sliceStart, ChipmunkDemoMouse, RGBAColor(1, 0, 0, 1));
	}
}

static cpSpace *
init()
{
	ChipmunkDemoMessageString = "Right click and drag to slice up the block.";
	
	cpSpace *space = cpSpaceNew();
	cpSpaceSetIterations(space, 30);
	cpSpaceSetGravity(space, cpv(0, -500));
	cpSpaceSetSleepTimeThreshold(space, 0.5f);
	cpSpaceSetCollisionSlop(space, 0.5f);
	
	cpBody *body_, staticBody = cpSpaceGetStaticBody(space);
	cpShape *shape;
	
	// Create segments around the edge of the screen.
	shape = cpSpaceAddShape(space, cpSegmentShapeNew(staticBody, cpv(-1000,-240), cpv(1000,-240), 0.0f));
	cpShapeSetElasticity(shape, 1.0f);
	cpShapeSetFriction(shape, 1.0f);
	cpShapeSetFilter(shape, NOT_GRABBABLE_FILTER);

	cpFloat width = 200.0f;
	cpFloat height = 300.0f;
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

ChipmunkDemo Slice = {
	"Slice.",
	1.0/60.0,
	&init,
	&update,
	&ChipmunkDemoDefaultDrawImpl,
	&destroy,
};
