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

import core.stdc.limits;
import core.stdc.string;
import core.stdc.stdlib;

import GL.glew;
import GL.glfw;

import chipmunk;
import chipmunk.chipmunk_private;
import ChipmunkDebugDraw;
import ChipmunkDemoShaderSupport;

static cpSpaceDebugColor RGBAColor(float r, float g, float b, float a){
	cpSpaceDebugColor color = {r, g, b, a};
	return color;
}

static cpSpaceDebugColor LAColor(float l, float a){
	cpSpaceDebugColor color = {l, l, l, a};
	return color;
}

float ChipmunkDebugDrawPointLineScale = 1.0f;
float ChipmunkDebugDrawOutlineWidth = 1.0f;

static GLuint program;

struct v2f {
	GLfloat x, y;
};
static v2f v2f0 = {0.0f, 0.0f};
auto to_v2f(cpVect v) { return v2f(v.x, v.y); }

struct Vertex {v2f vertex, aa_coord; cpSpaceDebugColor fill_color, outline_color;}
struct Triangle {Vertex a, b, c;}

static GLuint vao = 0;
static GLuint vbo = 0;

void
ChipmunkDebugDrawInit()
{
	// Setup the AA shader.
	GLint vshader = CompileShader(GL_VERTEX_SHADER, q{
		attribute vec2 vertex;
		attribute vec2 aa_coord;
		attribute vec4 fill_color;
		attribute vec4 outline_color;

		varying vec2 v_aa_coord;
		varying vec4 v_fill_color;
		varying vec4 v_outline_color;

		void main(){
			// TODO: get rid of the GL 2.x matrix bit eventually?
			gl_Position = gl_ModelViewProjectionMatrix*vec4(vertex, 0.0, 1.0);

			v_fill_color = fill_color;
			v_outline_color = outline_color;
			v_aa_coord = aa_coord;
		}
	});
	
	GLint fshader = CompileShader(GL_FRAGMENT_SHADER, q{
		uniform float u_outline_coef;
		
		varying vec2 v_aa_coord;
		varying vec4 v_fill_color;
		//const vec4 v_fill_color = vec4(0.0, 0.0, 0.0, 1.0);
		varying vec4 v_outline_color;
		
		float aa_step(float t1, float t2, float f)
		{
			//return step(t2, f);
			return smoothstep(t1, t2, f);
		}
		
		void main()
		{
			float l = length(v_aa_coord);
			
			// Different pixel size estimations are handy.
			//float fw = fwidth(l);
			//float fw = length(vec2(dFdx(l), dFdy(l)));
			float fw = length(fwidth(v_aa_coord));
			
			// Outline width threshold.
			float ow = 1.0 - fw;//*u_outline_coef;
			
			// Fill/outline color.
			float fo_step = aa_step(max(ow - fw, 0.0), ow, l);
			vec4 fo_color = mix(v_fill_color, v_outline_color, fo_step);
			
			// Use pre-multiplied alpha.
			float alpha = 1.0 - aa_step(1.0 - fw, 1.0, l);
			gl_FragColor = fo_color*(fo_color.a*alpha);
			//gl_FragColor = vec4(vec3(l), 1);
		}
	});
	
	program = LinkProgram(vshader, fshader);
	CHECK_GL_ERRORS();
	
	// Setu VBO and VAO.
version(OSX) {
	glGenVertexArraysAPPLE(1, &vao);
	glBindVertexArrayAPPLE(vao);
}
else {
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);
}
	
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);

	SetAttribute(program, "vertex", Vertex.vertex.sizeof / GL_FLOAT.sizeof, GL_FLOAT,
				 Vertex.sizeof, cast(GLvoid*)Vertex.vertex.offsetof);
	SetAttribute(program, "aa_coord", Vertex.aa_coord.sizeof / GL_FLOAT.sizeof, GL_FLOAT,
				 Vertex.sizeof, cast(GLvoid*)Vertex.aa_coord.offsetof);
	SetAttribute(program, "fill_color", Vertex.fill_color.sizeof / GL_FLOAT.sizeof, GL_FLOAT,
				 Vertex.sizeof, cast(GLvoid*)Vertex.fill_color.offsetof);
	SetAttribute(program, "outline_color", Vertex.outline_color.sizeof / GL_FLOAT.sizeof, GL_FLOAT,
				 Vertex.sizeof, cast(GLvoid*)Vertex.outline_color.offsetof);
	
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
version(OSX)
	glBindVertexArrayAPPLE(0);
else
	glBindVertexArray(0);

	CHECK_GL_ERRORS();
}

import std.algorithm;
alias MAX = std.algorithm.max;

static GLsizei triangle_capacity = 0;
static GLsizei triangle_count = 0;
static Triangle *triangle_buffer = null;

static Triangle *PushTriangles(GLsizei count)
{
	if(triangle_count + count > triangle_capacity){
		triangle_capacity += MAX(triangle_capacity, count);
		triangle_buffer = cast(Triangle *)realloc(triangle_buffer, triangle_capacity*Triangle.sizeof);
	}
	
	Triangle *buffer = triangle_buffer + triangle_count;
	triangle_count += count;
	return buffer;
}


void ChipmunkDebugDrawCircle(cpVect pos, cpFloat angle, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor)
{
	Triangle *triangles = PushTriangles(2);
	
	cpFloat r = radius + 1.0f/ChipmunkDebugDrawPointLineScale;
	Vertex a = {{cast(GLfloat)(pos.x - r), cast(GLfloat)(pos.y - r)}, {-1.0f, -1.0f}, fillColor, outlineColor};
	Vertex b = {{cast(GLfloat)(pos.x - r), cast(GLfloat)(pos.y + r)}, {-1.0f,  1.0f}, fillColor, outlineColor};
	Vertex c = {{cast(GLfloat)(pos.x + r), cast(GLfloat)(pos.y + r)}, { 1.0f,  1.0f}, fillColor, outlineColor};
	Vertex d = {{cast(GLfloat)(pos.x + r), cast(GLfloat)(pos.y - r)}, { 1.0f, -1.0f}, fillColor, outlineColor};
	
	Triangle t0 = {a, b, c}; triangles[0] = t0;
	Triangle t1 = {a, c, d}; triangles[1] = t1;
	
	ChipmunkDebugDrawSegment(pos, cpvadd(pos, cpvmult(cpvforangle(angle), radius - ChipmunkDebugDrawPointLineScale*0.5f)), outlineColor);
}

void ChipmunkDebugDrawSegment(cpVect a, cpVect b, cpSpaceDebugColor color)
{
	ChipmunkDebugDrawFatSegment(a, b, 0.0f, color, color);
}

void ChipmunkDebugDrawFatSegment(cpVect a, cpVect b, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor)
{
	Triangle *triangles = PushTriangles(6);
	
	cpVect n = cpvnormalize(cpvrperp(cpvsub(b, a)));
	cpVect t = cpvrperp(n);
	
	cpFloat half = 1.0f/ChipmunkDebugDrawPointLineScale;
	cpFloat r = radius + half;
	if(r <= half){
		r = half;
		fillColor = outlineColor;
	}
	
	cpVect nw = (cpvmult(n, r));
	cpVect tw = (cpvmult(t, r));
	v2f v0 = to_v2f(cpvsub(b, cpvadd(nw, tw))); // { 1.0, -1.0}
	v2f v1 = to_v2f(cpvadd(b, cpvsub(nw, tw))); // { 1.0,  1.0}
	v2f v2 = to_v2f(cpvsub(b, nw)); // { 0.0, -1.0}
	v2f v3 = to_v2f(cpvadd(b, nw)); // { 0.0,  1.0}
	v2f v4 = to_v2f(cpvsub(a, nw)); // { 0.0, -1.0}
	v2f v5 = to_v2f(cpvadd(a, nw)); // { 0.0,  1.0}
	v2f v6 = to_v2f(cpvsub(a, cpvsub(nw, tw))); // {-1.0, -1.0}
	v2f v7 = to_v2f(cpvadd(a, cpvadd(nw, tw))); // {-1.0,  1.0}
	
	Triangle t0 = {{v0, { 1.0f, -1.0f}, fillColor, outlineColor}, {v1, { 1.0f,  1.0f}, fillColor, outlineColor}, {v2, { 0.0f, -1.0f}, fillColor, outlineColor}}; triangles[0] = t0;
	Triangle t1 = {{v3, { 0.0f,  1.0f}, fillColor, outlineColor}, {v1, { 1.0f,  1.0f}, fillColor, outlineColor}, {v2, { 0.0f, -1.0f}, fillColor, outlineColor}}; triangles[1] = t1;
	Triangle t2 = {{v3, { 0.0f,  1.0f}, fillColor, outlineColor}, {v4, { 0.0f, -1.0f}, fillColor, outlineColor}, {v2, { 0.0f, -1.0f}, fillColor, outlineColor}}; triangles[2] = t2;
	Triangle t3 = {{v3, { 0.0f,  1.0f}, fillColor, outlineColor}, {v4, { 0.0f, -1.0f}, fillColor, outlineColor}, {v5, { 0.0f,  1.0f}, fillColor, outlineColor}}; triangles[3] = t3;
	Triangle t4 = {{v6, {-1.0f, -1.0f}, fillColor, outlineColor}, {v4, { 0.0f, -1.0f}, fillColor, outlineColor}, {v5, { 0.0f,  1.0f}, fillColor, outlineColor}}; triangles[4] = t4;
	Triangle t5 = {{v6, {-1.0f, -1.0f}, fillColor, outlineColor}, {v7, {-1.0f,  1.0f}, fillColor, outlineColor}, {v5, { 0.0f,  1.0f}, fillColor, outlineColor}}; triangles[5] = t5;
}

extern cpVect ChipmunkDemoMouse;

void ChipmunkDebugDrawPolygon(int count, const cpVect *verts, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor)
{
	struct ExtrudeVerts {cpVect offset, n;};
	size_t bytes = (ExtrudeVerts.sizeof)*count;
	ExtrudeVerts *extrude = cast(ExtrudeVerts *)alloca(bytes);
	memset(extrude, 0, bytes);
	
	for(int i=0; i<count; i++){
		cpVect v0 = verts[(i-1+count)%count];
		cpVect v1 = verts[i];
		cpVect v2 = verts[(i+1)%count];
		
		cpVect n1 = cpvnormalize(cpvrperp(cpvsub(v1, v0)));
		cpVect n2 = cpvnormalize(cpvrperp(cpvsub(v2, v1)));
		
		cpVect offset = cpvmult(cpvadd(n1, n2), 1.0/(cpvdot(n1, n2) + 1.0f));
		ExtrudeVerts v = {offset, n2}; extrude[i] = v;
	}
	
//	Triangle *triangles = PushTriangles(6*count);
	Triangle *triangles = PushTriangles(5*count - 2);
	Triangle *cursor = triangles;
	
	cpFloat inset = -cpfmax(0.0f, 1.0f/ChipmunkDebugDrawPointLineScale - radius);
	for(int i=0; i<count-2; i++){
		v2f v0 = to_v2f(cpvadd(verts[  0], cpvmult(extrude[  0].offset, inset)));
		v2f v1 = to_v2f(cpvadd(verts[i+1], cpvmult(extrude[i+1].offset, inset)));
		v2f v2 = to_v2f(cpvadd(verts[i+2], cpvmult(extrude[i+2].offset, inset)));
		
		Triangle t = {{v0, v2f0, fillColor, fillColor}, {v1, v2f0, fillColor, fillColor}, {v2, v2f0, fillColor, fillColor}}; *cursor++ = t;
	}
	
	cpFloat outset = 1.0f/ChipmunkDebugDrawPointLineScale + radius - inset;
	for(int i=0, j=count-1; i<count; j=i, i++){
		cpVect vA = verts[i];
		cpVect vB = verts[j];
		
		cpVect nA = extrude[i].n;
		cpVect nB = extrude[j].n;
		
		cpVect offsetA = extrude[i].offset;
		cpVect offsetB = extrude[j].offset;
		
		cpVect innerA = cpvadd(vA, cpvmult(offsetA, inset));
		cpVect innerB = cpvadd(vB, cpvmult(offsetB, inset));
		
		// Admittedly my variable naming sucks here...
		v2f inner0 = to_v2f(innerA);
		v2f inner1 = to_v2f(innerB);
		v2f outer0 = to_v2f(cpvadd(innerA, cpvmult(nB, outset)));
		v2f outer1 = to_v2f(cpvadd(innerB, cpvmult(nB, outset)));
		v2f outer2 = to_v2f(cpvadd(innerA, cpvmult(offsetA, outset)));
		v2f outer3 = to_v2f(cpvadd(innerA, cpvmult(nA, outset)));
		
		v2f n0 = to_v2f(nA);
		v2f n1 = to_v2f(nB);
		v2f offset0 = to_v2f(offsetA);
		
		Triangle t0 = {{inner0, v2f0, fillColor, outlineColor}, {inner1,    v2f0, fillColor, outlineColor}, {outer1,      n1, fillColor, outlineColor}}; *cursor++ = t0;
		Triangle t1 = {{inner0, v2f0, fillColor, outlineColor}, {outer0,      n1, fillColor, outlineColor}, {outer1,      n1, fillColor, outlineColor}}; *cursor++ = t1;
		Triangle t2 = {{inner0, v2f0, fillColor, outlineColor}, {outer0,      n1, fillColor, outlineColor}, {outer2, offset0, fillColor, outlineColor}}; *cursor++ = t2;
		Triangle t3 = {{inner0, v2f0, fillColor, outlineColor}, {outer2, offset0, fillColor, outlineColor}, {outer3,      n0, fillColor, outlineColor}}; *cursor++ = t3;
	}
}

void ChipmunkDebugDrawDot(cpFloat size, cpVect pos, cpSpaceDebugColor fillColor)
{
	Triangle *triangles = PushTriangles(2);
	
	float r = cast(float)(size*0.5f/ChipmunkDebugDrawPointLineScale);
	Vertex a = {{cast(float)pos.x - r, cast(float)pos.y - r}, {-1.0f, -1.0f}, fillColor, fillColor};
	Vertex b = {{cast(float)pos.x - r, cast(float)pos.y + r}, {-1.0f,  1.0f}, fillColor, fillColor};
	Vertex c = {{cast(float)pos.x + r, cast(float)pos.y + r}, { 1.0f,  1.0f}, fillColor, fillColor};
	Vertex d = {{cast(float)pos.x + r, cast(float)pos.y - r}, { 1.0f, -1.0f}, fillColor, fillColor};
	
	Triangle t0 = {a, b, c}; triangles[0] = t0;
	Triangle t1 = {a, c, d}; triangles[1] = t1;
}

void ChipmunkDebugDrawBB(cpBB bb, cpSpaceDebugColor color)
{
	cpVect verts[] = [
		cpv(bb.r, bb.b),
		cpv(bb.r, bb.t),
		cpv(bb.l, bb.t),
		cpv(bb.l, bb.b),
	];
	ChipmunkDebugDrawPolygon(4, verts.ptr, 0.0f, color, LAColor(0, 0));
}

void
ChipmunkDebugDrawFlushRenderer()
{
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, Triangle.sizeof*triangle_count, triangle_buffer, GL_STREAM_DRAW);
	
	glUseProgram(program);
	glUniform1f(glGetUniformLocation(program, "u_outline_coef"), ChipmunkDebugDrawPointLineScale);
	
version(OSX)
	glBindVertexArrayAPPLE(vao);
else
	glBindVertexArray(vao);

	glDrawArrays(GL_TRIANGLES, 0, triangle_count*3);
		
	CHECK_GL_ERRORS();
}

void
ChipmunkDebugDrawClearRenderer()
{
	triangle_count = 0;
}

static int pushed_triangle_count = 0;
void
ChipmunkDebugDrawPushRenderer()
{
	pushed_triangle_count = triangle_count;
}

void
ChipmunkDebugDrawPopRenderer()
{
	triangle_count = pushed_triangle_count;
}
