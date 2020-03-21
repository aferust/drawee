module globals;

import bindbc.sdl;
import bindbc.opengl;
import dvector;
import chipmunk;

import heroimp;
import tween;

__gshared {
    SDL_GLContext glcontext;
    SDL_Window *window;

    int SCREEN_WIDTH  = 800;
    int SCREEN_HEIGHT = 600;

    float b_width = 19.0f;
    int grid_size = 5;
}

struct Point {
    int x;
    int y;

    bool opEqual(in ref Point other) const {
        return x == other.x && y == other.y;
    }
}

struct Color(T){
    T r, g, b;
}

__gshared {
    ubyte* keystate;
    
    Hero hero;

    Dvector!Point rail;
    Dvector!size_t triangles;
    Dvector!Point pVertices;
    Dvector!(cpShape*) walls;

    Dvector!(Action!Point) actions;
    
    cpSpace* space;
}

enum {
    COLLISION_TYPE_STATIC = 1,
    COLLISION_TYPE_DYNAMIC = 2
}

enum WALLS_ELASTICITY = 1;
enum WALLS_FRICTION = 1;

enum ENEMY_SIZE = 15;
