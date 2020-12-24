module primitives;

import core.stdc.math: cos, sin;
import core.stdc.stdlib: malloc, free, exit;

import std.range: chunks;

import bindbc.opengl;
import dvector;
import bettercmath;

alias Mat4 = Matrix!(float, 4);

import gamemath;
import globals;

@nogc nothrow:

enum PI = 3.14159265359f;

struct GLLine{
    
    Dvector!float vertices;
    GLuint shaderProgram;
    GLuint vbo;

    @nogc nothrow:

    this(GLuint shaderProgram){
        this.shaderProgram = shaderProgram;

        vertices = [0.0f, 0.0f, 0.0f, 0.0f];

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);
    }

    void set(Point point1, Point point2, Color color){
        vertices[0] = float(point1.x);
        vertices[1] = float(point1.y);
        vertices[2] = float(point2.x);
        vertices[3] = float(point2.y);

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);

        glUseProgram(shaderProgram);

        GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
        glEnableVertexAttribArray(posAttrib);
        
        auto vertexSize =float.sizeof*2;
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, false, cast(uint)vertexSize, null);

        auto pmAtt = glGetUniformLocation(shaderProgram, "projectionMat");
        glUniformMatrix4fv(pmAtt, 1, GL_FALSE, ortho.elements.ptr);

        // set color
        auto cAtt = glGetUniformLocation(shaderProgram, "ucolor");
        glUniform4fv(cAtt, 1, color.ptr);
    }

    void draw() {
        glUseProgram(shaderProgram);
        glDrawArrays(GL_LINES, 0, 2);
        glDisableVertexAttribArray(0);
        glUseProgram(0);
    }

    ~this(){
        vertices.free();
    }
}

struct GLCircle {
    
    Dvector!float vertices;
    GLuint shaderProgram;
    GLuint vbo;

    @nogc nothrow:

    this(GLuint shaderProgram){
        this.shaderProgram = shaderProgram;

        enum numVertices = 1000;

        float increment = 2.0f * PI / float(numVertices);

        for (float currAngle = 0.0f; currAngle <= 2.0f * PI; currAngle += increment)
        {
            vertices ~= 0.0f;
            vertices ~= 0.0f;
        }

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);
    }

    void set(int x, int y, float radius, Color color){
        enum numVertices = 1000;

        float increment = 2.0f * PI / float(numVertices);

        size_t i;
        for (float currAngle = 0.0f; currAngle <= 2.0f * PI; currAngle += increment)
        {
            vertices[i] = radius * cos(currAngle) + float(x);
            vertices[i+1] = radius * sin(currAngle) + float(y);
            i += 2;
        }

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);
        
        glUseProgram(shaderProgram);

        GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
        auto vertexSize =float.sizeof*2;
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, false, cast(uint)vertexSize, null);
        glEnableVertexAttribArray(posAttrib);

        auto pmAtt = glGetUniformLocation(shaderProgram, "projectionMat");
        glUniformMatrix4fv(pmAtt, 1, GL_FALSE, ortho.elements.ptr);

        // set color
        auto cAtt = glGetUniformLocation(shaderProgram, "ucolor");
        glUniform4fv(cAtt, 1, color.ptr);
    }

    void draw() {
        glUseProgram(shaderProgram);
        glDrawArrays(GL_LINE_LOOP, 0, cast(int)vertices.length/2);
        glDisableVertexAttribArray(0);
        glUseProgram(0);
    }

    ~this(){
        vertices.free();
    }
}

struct GLSolidCircle {
    
    Dvector!float vertices;
    GLuint shaderProgram;
    GLuint vbo;

    @nogc nothrow:

    this(GLuint shaderProgram){
        this.shaderProgram = shaderProgram;      

        enum quality = 0.125;
	    int triangleAmount = cast(int)(SCREEN_WIDTH * quality);

		foreach(i; 0..triangleAmount) { 
		    vertices ~= 0; 
			vertices ~= 0;
		}

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STREAM_DRAW);
    }

    void set(int x, int y, float radius, Color color){        

        enum quality = 0.125;
	    int triangleAmount = cast(int)(SCREEN_WIDTH * quality);
        
        int i;
        foreach(ref c; chunks(vertices[], 2)) {
		    c[0] = x + (radius * cos(i *  2*PI / float(triangleAmount))); 
            c[1] = y + (radius * sin(i * 2*PI / float(triangleAmount)));
            ++i;
		}

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STREAM_DRAW);

        glUseProgram(shaderProgram);

        GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, false, uint(0), null);
        glEnableVertexAttribArray(posAttrib);

        auto pmAtt = glGetUniformLocation(shaderProgram, "projectionMat");
        glUniformMatrix4fv(pmAtt, 1, GL_FALSE, ortho.elements.ptr);

        // set color
        auto cAtt = glGetUniformLocation(shaderProgram, "ucolor");
        glUniform4fv(cAtt, 1, color.ptr);
    }

    void draw() {
        glUseProgram(shaderProgram);
        glDrawArrays(GL_TRIANGLE_FAN, 0, cast(int)vertices.length/2);
        glDisableVertexAttribArray(0);
        glUseProgram(0);
    }

    ~this(){
        vertices.free();
    }
}

struct GLPoly {
    Dvector!float vertices;
    GLuint shaderProgram;
    GLuint vbo;

    @nogc nothrow:

    this(GLuint shaderProgram){
        this.shaderProgram = shaderProgram;

        //foreach(i; 0 .. triangles.length / 3){
            vertices ~= 0;
            vertices ~= 0;
            vertices ~= 0;
            vertices ~= 0;
            vertices ~= 0;
            vertices ~= 0;
        //}

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);
        
    }

    void set(Color color){
        vertices.free;
        foreach(i; 0 .. triangles.length / 3){
            vertices ~= float(rail[triangles[i*3]].x);
            vertices ~= float(rail[triangles[i*3]].y);
            
            vertices ~= float(rail[triangles[i*3 + 1]].x);
            vertices ~= float(rail[triangles[i*3 + 1]].y);
            
            vertices ~= float(rail[triangles[i*3 + 2]].x);
            vertices ~= float(rail[triangles[i*3 + 2]].y);
        }

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);

        glUseProgram(shaderProgram);

        GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, false, uint(0), null);
        glEnableVertexAttribArray(posAttrib);

        auto pmAtt = glGetUniformLocation(shaderProgram, "projectionMat");
        glUniformMatrix4fv(pmAtt, 1, GL_FALSE, ortho.elements.ptr);

        // set color
        auto cAtt = glGetUniformLocation(shaderProgram, "ucolor");
        glUniform4fv(cAtt, 1, color.ptr);

    }

    void draw() {
        glUseProgram(shaderProgram);
        glDrawArrays(GL_TRIANGLES, 0, cast(int)vertices.length/2);
        glDisableVertexAttribArray(0);
        glUseProgram(0);
    }

    ~this(){
        vertices.free;
    }
}

struct GLRect {
    Dvector!float vertices;
    GLuint shaderProgram;
    GLuint vbo;

    @nogc nothrow:

    this(GLuint shaderProgram){
        this.shaderProgram = shaderProgram;
        
        vertices = [
            0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f
        ];

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);
    }

    void set(Rect r, Color color){

        vertices ~= r.x;
        vertices ~= r.y;
        
        vertices ~= r.x + r.w;
        vertices ~= r.y;
        
        vertices ~= r.x;
        vertices ~= r.y+r.h;

        vertices ~= r.x+r.w;
        vertices ~= r.y;

        vertices ~= r.x+r.w;
        vertices ~= r.y+r.h;

        vertices ~= r.x;
        vertices ~= r.y+r.h;

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices[].ptr, GL_STATIC_DRAW);

        glUseProgram(shaderProgram);

        GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
        glEnableVertexAttribArray(posAttrib);
        glVertexAttribPointer(posAttrib, 2, GL_FLOAT, false, uint(0), null);

        auto pmAtt = glGetUniformLocation(shaderProgram, "projectionMat");
        glUniformMatrix4fv(pmAtt, 1, GL_FALSE, ortho.elements.ptr);

        // set color
        auto cAtt = glGetUniformLocation(shaderProgram, "ucolor");
        glUniform4fv(cAtt, 1, color.ptr);
    }

    void draw() {
        glUseProgram(shaderProgram);
        glDrawArrays(GL_TRIANGLES, 0, cast(int)vertices.length/2);
        vertices.free();
    }
}


/+ Shaders +/

GLuint initShader(const char* vShader, const char* fShader, const char* outputAttributeName) {
    struct Shader {
        GLenum       type;
        const char*      source;
    }
    Shader[2] shaders = [
        Shader(GL_VERTEX_SHADER, vShader),
        Shader(GL_FRAGMENT_SHADER, fShader)
    ];

    GLuint program = glCreateProgram();

    for ( int i = 0; i < 2; ++i ) {
        Shader s = shaders[i];
        GLuint shader = glCreateShader( s.type );
        glShaderSource( shader, 1, &s.source, null );
        glCompileShader( shader );

        GLint  compiled;
        glGetShaderiv( shader, GL_COMPILE_STATUS, &compiled );
        if ( !compiled ) {
            printf(" failed to compile: ");
            GLint  logSize;
            glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &logSize );
            char* logMsg = cast(char*)malloc(char.sizeof*logSize);
            glGetShaderInfoLog( shader, logSize, null, logMsg );
            printf("%s \n", logMsg);
            free(logMsg);

            exit( -1 );
        }

        glAttachShader( program, shader );
    }

    /* link  and error check */
    glLinkProgram(program);

    GLint linked;
    glGetProgramiv( program, GL_LINK_STATUS, &linked );
    if ( !linked ) {
        printf("Shader program failed to link");
        GLint  logSize;
        glGetProgramiv( program, GL_INFO_LOG_LENGTH, &logSize);
        char* logMsg = cast(char*)malloc(char.sizeof*logSize);
        glGetProgramInfoLog( program, logSize, null, logMsg );
        printf("%s \n", logMsg);
        free(logMsg);
        exit( -1 );
    }

    /* use program object */
    glUseProgram(program);

    return program;
}

void loadShaderHero(){
    const char*  vert = q{
        attribute vec4 position;
        uniform mat4 projectionMat;
        void main() {
            gl_Position = projectionMat * vec4(position.xyz, 1.0);
        }
    };
    const char*  frag = q{
        precision mediump float;
        uniform vec4 ucolor;
        void main() {
            gl_FragColor = ucolor;
        }
    };

    shaderProgramHero = initShader(vert,  frag, "ucolor");

    uvAttribute = glGetAttribLocation(shaderProgramHero, "ucolor");
    if (uvAttribute < 0) {
        printf("Shader did not contain the 'color' attribute. \n");
    }
    positionAttribute = glGetAttribLocation(shaderProgramHero, "position");
    if (positionAttribute < 0) {
        printf("Shader did not contain the 'position' attribute. \n");
    }
}

void loadShaderEnemy(){
    const char*  vert = q{
        attribute vec4 position;
        uniform mat4 projectionMat;
        void main() {
            gl_Position = projectionMat * vec4(position.xyz, 1.0);
        }
    };
    const char*  frag = q{
        precision mediump float;
        uniform vec4 ucolor;
        void main() {
            gl_FragColor = ucolor;
        }
    };

    shaderProgramEnemy = initShader(vert,  frag, "fragColor");

    uvAttribute = glGetAttribLocation(shaderProgramEnemy, "uv");
    if (uvAttribute < 0) {
        printf("Shader did not contain the 'color' attribute. \n");
    }
    positionAttribute = glGetAttribLocation(shaderProgramEnemy, "position");
    if (positionAttribute < 0) {
        printf("Shader did not contain the 'position' attribute. \n");
    }
}

void loadShaderPoly(){
    const char*  vert = q{
        attribute vec4 position;
        uniform mat4 projectionMat;
        void main() {
            gl_Position = projectionMat * vec4(position.xyz, 1.0);
        }
    };
    const char*  frag = q{
        precision mediump float;
        uniform vec4 ucolor;
        void main() {
            gl_FragColor = ucolor;
        }
    };

    shaderProgramPoly = initShader(vert,  frag, "fragColor");

    uvAttribute = glGetAttribLocation(shaderProgramPoly, "uv");
    if (uvAttribute < 0) {
        printf("Shader did not contain the 'color' attribute. \n");
    }
    positionAttribute = glGetAttribLocation(shaderProgramPoly, "position");
    if (positionAttribute < 0) {
        printf("Shader did not contain the 'position' attribute. \n");
    }
}

void loadShaderGreen(){
    const char*  vert = q{
        attribute vec4 position;
        uniform mat4 projectionMat;
        void main() {
            gl_Position = projectionMat * vec4(position.xyz, 1.0);
        }
    };
    const char*  frag = q{
        precision mediump float;
        uniform vec4 ucolor;
        void main() {
            gl_FragColor = ucolor;
        }
    };

    shaderProgramGreen= initShader(vert,  frag, "fragColor");

    uvAttribute = glGetAttribLocation(shaderProgramGreen, "uv");
    if (uvAttribute < 0) {
        printf("Shader did not contain the 'color' attribute. \n");
    }
    positionAttribute = glGetAttribLocation(shaderProgramGreen, "position");
    if (positionAttribute < 0) {
        printf("Shader did not contain the 'position' attribute. \n");
    }
}

void loadShaderRed(){
    const char*  vert = q{
        attribute vec4 position;
        uniform mat4 projectionMat;
        void main() {
            gl_Position = projectionMat * vec4(position.xyz, 1.0);
        }
    };
    const char*  frag = q{
        precision mediump float;
        uniform vec4 ucolor;
        void main() {
            gl_FragColor = ucolor;
        }
    };

    shaderProgramRed = initShader(vert,  frag, "fragColor");

    uvAttribute = glGetAttribLocation(shaderProgramRed, "uv");
    if (uvAttribute < 0) {
        printf("Shader did not contain the 'color' attribute. \n");
    }
    positionAttribute = glGetAttribLocation(shaderProgramRed, "position");
    if (positionAttribute < 0) {
        printf("Shader did not contain the 'position' attribute. \n");
    }
}