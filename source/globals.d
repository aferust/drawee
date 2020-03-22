module globals;

import std.typecons;

import bindbc.sdl;
import bindbc.opengl;
import dvector;
import chipmunk;

import heroimp;
import enemyimp;
import tween;

__gshared {
    SDL_GLContext glcontext;
    SDL_Window *window;

    enum SCREEN_WIDTH  = 800;
    enum SCREEN_HEIGHT = 600;
    enum totalArea = SCREEN_WIDTH * SCREEN_HEIGHT;

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

__gshared {
    ubyte* keystate;
    
    Hero hero;
    Dvector!Enemy enemies;

    Dvector!Point rail;
    Dvector!size_t triangles;
    Dvector!Point pVertices;
    Dvector!(Tuple!(Point, Point)) deathTrace;
    Dvector!(cpShape*) walls;

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
