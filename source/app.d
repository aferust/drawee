/** Volfied-like game with SDL and OpenGL
    ported from my cocos2dx implementation
    Work in progress!!!

    Controls: use arrow keys and space.

Copyright:
 Copyright (c) 2020, Ferhat Kurtulmuş.
 License:
   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

import std.stdint;

import bindbc.sdl;
import bindbc.opengl;
import dvector;
import chipmunk;

import globals;
import boilerplate;
import railimp;
import drawobjects;
import heroimp;
import tween;
import enemyimp;
import obstacleimp;

@nogc nothrow:

extern (C) int main() {
    initSDL();
    initGL();

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    glClearColor(1,0,0,1);
    //glClear(GL_COLOR_BUFFER_BIT);

    space = cpSpaceNew();

    hero = Hero(Point(SCREEN_WIDTH/2, SCREEN_HEIGHT));
    rail.pushBack(Point(0, 0));
    rail.pushBack(Point(0, SCREEN_HEIGHT));
    rail.pushBack(Point(SCREEN_WIDTH, SCREEN_HEIGHT));
    rail.pushBack(Point(SCREEN_WIDTH, 0));

    updateTriangles();
    updateWalls();

    auto ch = cpSpaceAddCollisionHandler(space, COLLISION_TYPE_STATIC, COLLISION_TYPE_DYNAMIC);
    ch.beginFunc = &collisionBegin;
    ch.postSolveFunc = &collisionPost;
    ch.preSolveFunc = &collisionPre;
    ch.separateFunc = &collisionSeparate;
    
    enemies ~= Enemy(ENEMY_RADIUS, Point(150, 150), cpVect(0.2, 0.4));
    enemies ~= Enemy(ENEMY_RADIUS, Point(200, 150), cpVect(0.4, 0.2));

    obstacles ~= Obstacle(Point(SCREEN_WIDTH/2, SCREEN_HEIGHT/2), 60, 60);

	bool quit;

    uint64_t now = SDL_GetPerformanceCounter();
    uint64_t last = 0;
    double dt = 0;

    keystate = SDL_GetKeyboardState(null);
    
    double heroDelayer = 0.0;
    double enemyDelayer = 0.0;

    SDL_Event event;
    while (!quit){
        while( SDL_PollEvent( &event ) != 0 ){
            if(event.type == SDL_KEYDOWN){
                switch (event.key.keysym.sym){
                    case SDLK_ESCAPE:
                        quit = true;
                        break;
                    default:
                        break;
                }
            }
        }
        last = now;
        now = SDL_GetPerformanceCounter();
        dt = double(now - last)/cast(double)SDL_GetPerformanceFrequency();
        
        drawRail();
        drawHero();
        drawObstacles();

        if(hero.alive == true && hero.heroStat != dead)
            dieIfCollide();
        
        drawForwardTrace();
        drawBackwardTrace();

        /// I am having some issues with delta. this is my workaround
        heroDelayer += dt;
        if(heroDelayer > 0.018){
            hero.update(dt);
            proceedActions(dt);
            heroDelayer = 0.0;
        }
            
        cpSpaceStep(space, cast(float)dt*1000);

        foreach (ref enemy; enemies){
            enemy.update();
        }

        drawEnemies();

        SDL_GL_SwapWindow(window);
    }

    clearObstacles();
    clearEnemies();
    
    SDL_GL_DeleteContext(glcontext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}