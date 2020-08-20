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

import bindbc.sdl;

// draws wrong color ????
void RenderText(const(char)* message, SDL_Color color, int x, int y, int size) {
    import bindbc.sdl.ttf;

    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    TTF_Font *font = TTF_OpenFont( "Fontin-Regular.ttf", size );
    
    SDL_Surface * sFont = TTF_RenderText_Blended(font, message, color);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, sFont.w, sFont.h, 0, GL_BGRA, GL_UNSIGNED_BYTE, sFont.pixels);

    glBegin(GL_QUADS);
    {
        glTexCoord2f(0,0); _glVertex2f(x, y);
        glTexCoord2f(1,0); _glVertex2f(x + sFont.w, y);
        glTexCoord2f(1,1); _glVertex2f(x + sFont.w, y + sFont.h);
        glTexCoord2f(0,1); _glVertex2f(x, y + sFont.h);
    }
    glEnd();
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);

    TTF_CloseFont(font);
    SDL_FreeSurface(sFont);
}