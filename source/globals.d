module globals;

import std.typecons;

import bindbc.sdl;
version(WebAssembly){
    import opengl.gl4;
}else{
    import bindbc.opengl;
}
import dvector;
import bcaa;
import chipmunk;

import heroimp;
import enemyimp;
import obstacleimp;
import tween;
import msgnode;

__gshared {
    SDL_GLContext glcontext;
    SDL_Window *window;

    enum SCREEN_WIDTH  = 800;
    enum SCREEN_HEIGHT = 700;
    enum FOOTER_HEIGHT = 100;
    enum totalArea = SCREEN_WIDTH * SCREEN_HEIGHT;

    enum FPS = 60;
    enum FRAME_RATE = 1000/FPS;

    enum HERO_RADIUS = 9.5f;
    int grid_size = 5;

    import primitives; 
    
    // shader stuff
    
    GLuint shaderProgramHero;
    GLuint shaderProgramEnemy;
    GLuint shaderProgramPoly;
    GLuint shaderProgramGreen;
    GLuint shaderProgramRed;
    GLuint shaderProgramFg;
    GLuint shaderProgramEn;
    GLuint shaderProgramText;

    Mat4 ortho;

    // Drawer objects
    GLSolidCircle drSCircle;
    GLCircle drShield;
    GLLine drLine;
    GLPoly drPoly;
    GLRect drRect;
    GLTexturedRect drTRect;
    GLText drText;

    // Texture IDs
    GLuint textureIdObstacle;
    GLuint textureIdBg1, textureIdFg;
    GLuint textureIdEnemy1;
    GLuint textureIdEnemy2;
    GLuint textureFontArea;
    
    FontSet charSetScore, charSetMsg;
}

alias FontSet = Bcaa!(dchar, FontInfo);

struct FontInfo {
    GLuint textureId;
    int w;
    int h;
}

struct Point {
    int x;
    int y;

    bool opEqual(in ref Point other) const {
        return x == other.x && y == other.y;
    }
}

struct Circle {
    Point pos;
    int radius;
}

struct Color{
    float[4] rgba;
    alias rgba this;
    
    @nogc nothrow:
    static Color red(){return Color([1.0f, 0.0f, 0.0f, 1.0f]);}
    static Color green(){return Color([0.0f, 1.0f, 0.0f, 1.0f]);}
    static Color blue(){return Color([0.0f, 0.0f, 1.0f, 1.0f]);}
    static Color white(){return Color([1.0f, 1.0f, 1.0f, 1.0f]);}
    static Color black(){return Color([0.0f, 0.0f, 0.0f, 1.0f]);}

}

// need only for obstacles
struct Rect {
    int x, y, w, h;
    
    @nogc nothrow Point diag(){
        return Point(x+w, y+h);
    }
}

__gshared {
    bool quit;
    
    ubyte* keystate;

    Clock clock;
    bool pause;
    
    Hero hero;
    Dvector!Enemy enemies;

    Dvector!Point rail;
    Dvector!size_t triangles;
    Dvector!Point pVertices;
    Dvector!(Tuple!(Point, Point)) deathTrace;
    Dvector!(cpShape*) walls;
    Dvector!Obstacle obstacles;

    Dvector!(Action!Point) actions;

    Dvector!(Action!Point) sceneActions;
    
    cpSpace* space;

    float currentArea;
    float rate;
    
    MsgNode msgNode;

    bool won;
}

enum {
    COLLISION_TYPE_STATIC = 1,
    COLLISION_TYPE_DYNAMIC = 2
}

enum WALLS_ELASTICITY = 1;
enum WALLS_FRICTION = 1;

enum ENEMY_RADIUS = 25;

struct Clock {
    int last_tick_time = 0;
    int dt = 0;
    
    @nogc nothrow:
    
    void tick(){
        int tick_time = SDL_GetTicks();
        dt = tick_time - last_tick_time;
        last_tick_time = tick_time;
    }
}