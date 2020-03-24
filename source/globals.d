module globals;

import std.typecons;

import bindbc.sdl;
import bindbc.opengl;
import dvector;
import chipmunk;

import heroimp;
import enemyimp;
import obstacleimp;
import tween;

__gshared {
    SDL_GLContext glcontext;
    SDL_Window *window;

    enum SCREEN_WIDTH  = 800;
    enum SCREEN_HEIGHT = 600;
    enum totalArea = SCREEN_WIDTH * SCREEN_HEIGHT;

    enum FPS = 50;
    enum FRAME_RATE = 1000/FPS;

    enum HERO_RADIUS = 9.5f;
    int grid_size = 5;
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

struct Color(T){
    T r, g, b;
}

// need only for obstacles
struct Rect {
    int x, y, w, h;
    
    @nogc nothrow Point diag(){
        return Point(x+w, y+h);
    }
}

__gshared {
    ubyte* keystate;
    
    Hero hero;
    Dvector!Enemy enemies;

    Dvector!Point rail;
    Dvector!size_t triangles;
    Dvector!Point pVertices;
    Dvector!(Tuple!(Point, Point)) deathTrace;
    Dvector!(cpShape*) walls;
    Dvector!Obstacle obstacles;

    Dvector!(Action!Point) actions;
    
    cpSpace* space;

    float currentArea;
    bool won;
}

enum {
    COLLISION_TYPE_STATIC = 1,
    COLLISION_TYPE_DYNAMIC = 2
}

enum WALLS_ELASTICITY = 1;
enum WALLS_FRICTION = 1;

enum ENEMY_RADIUS = 10;

void sleepMS(T)(T dur){
    version(Windows){
        import core.sys.windows.windows;
        Sleep(dur);
    }else{
        import core.sys.posix.unistd;
        sleep(dur/1000);
    }
}