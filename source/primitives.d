module primitives;

import std.math;

import bindbc.opengl;

import globals;

@nogc nothrow:

enum quality = 0.125;

/// allows absolute positioning
void _glVertex2f(int x, int y){
    glVertex2f(x * 2.0 / cast(float)SCREEN_WIDTH - 1.0, 1.0 - y * 2.0 / cast(float)SCREEN_HEIGHT);
    //glVertex2f(x, y);
}

void filledCircle(int x, int y, int radius, Color!float cl){
	int i;
	int triangleAmount = cast(int)(SCREEN_WIDTH * quality); //# of triangles used to draw circle
	
	GLfloat twicePi = 2.0f * PI;
	
	glBegin(GL_TRIANGLE_FAN);
        glEnable(GL_POINT_SMOOTH);
        glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
        glColor3f(cl.r, cl.g, cl.b);
		_glVertex2f(x, y); // center of circle
		for(i = 0; i <= triangleAmount;i++) { 
			_glVertex2f(
		        cast(int)(x + (radius * cos(i *  twicePi / triangleAmount))), 
			    cast(int)(y + (radius * sin(i * twicePi / triangleAmount)))
			);
		}
	glEnd();
}

void hollowCircle(GLfloat x, GLfloat y, GLfloat radius, Color!float cl){
	int i;
	int lineAmount = cast(int)(SCREEN_WIDTH * quality); //# of triangles used to draw circle
	
	GLfloat twicePi = 2.0f * PI;
	
	glBegin(GL_LINE_LOOP);
        glColor3f(cl.r, cl.g, cl.b);
		for(i = 0; i <= lineAmount;i++) { 
			_glVertex2f(
			    cast(int)(x + (radius * cos(i *  twicePi / lineAmount))), 
			    cast(int)(y + (radius* sin(i * twicePi / lineAmount)))
			);
		}
	glEnd();
}

void drawPolygon(){
    glClear( GL_COLOR_BUFFER_BIT );
    glBegin(GL_TRIANGLES);
        glColor3f(1.0f, 1.0f, 1.0f);
        foreach(i; 0 .. triangles.length / 3){
            _glVertex2f(rail[triangles[i*3]].x, rail[triangles[i*3]].y );
            _glVertex2f(rail[triangles[i*3 + 1]].x, rail[triangles[i*3 + 1]].y );
            _glVertex2f(rail[triangles[i*3 + 2]].x, rail[triangles[i*3 + 2]].y );
        }
    glEnd();
}

void line(Point p1, Point p2, Color!float cl){
    glBegin(GL_LINES);
        glColor3f(cl.r, cl.g, cl.b);
        _glVertex2f(p1.x, p1.y);
        _glVertex2f(p2.x, p2.y);
    glEnd();
}

void drawRect(Rect r, Color!float cl){
    glBegin(GL_QUADS);
        glColor3d(cl.r, cl.g, cl.b);
        _glVertex2f(r.x, r.y);
        _glVertex2f(r.x+r.w, r.y);
        _glVertex2f(r.x+r.w, r.y+r.h);
        _glVertex2f(r.x, r.y+r.h);
    glEnd();
}