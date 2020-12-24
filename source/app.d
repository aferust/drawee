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
    initSDLTTF();
    initGL();

    import primitives;
    loadShaderHero();
    loadShaderEnemy();
    loadShaderPoly();
    loadShaderGreen();
    loadShaderRed();

    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    ortho = Mat4.ortho(0.0f, float(SCREEN_WIDTH), float(SCREEN_HEIGHT), 0.0f);

    glClearColor(1.0f, 0.0f, 0.0f, 0.0f);

    space = cpSpaceNew();

    auto ch = cpSpaceAddCollisionHandler(space, COLLISION_TYPE_STATIC, COLLISION_TYPE_DYNAMIC);
    ch.beginFunc = &collisionBegin;
    ch.postSolveFunc = &collisionPost;
    ch.preSolveFunc = &collisionPre;
    ch.separateFunc = &collisionSeparate;
    
    resetGame();

    drHero = GLSolidCircle(shaderProgramHero);
    drShield = GLCircle(shaderProgramGreen);
    drLine = GLLine(shaderProgramGreen);
    drPoly = GLPoly(shaderProgramPoly);
    drRect = GLRect(shaderProgramGreen);

	bool quit;

    keystate = SDL_GetKeyboardState(null);
    
    float dt = 0;
    int gTimer;
    
    sleepMS(500);

    SDL_Event event;
    while (!quit){
        while( SDL_PollEvent( &event ) != 0 ){
            if(event.type == SDL_KEYDOWN){
                switch (event.key.keysym.sym){
                    case SDLK_ESCAPE:
                        quit = true;
                        break;
                    case SDLK_r:
                        resetGame();
                        break;
                    default:
                        break;
                }
            }/* else if(event.type == SDL_KEYUP){
                switch (event.key.keysym.sym){
                    case SDLK_SPACE:
                        break;
                    default:
                        break;
                }
            }*/
        }

        dt = SDL_GetTicks() - gTimer;

        if(dt >= FRAME_RATE){ // game logic is limited to fixed FPS

            if(hero.alive == true && hero.heroStat != dead)
                dieIfCollide();

            hero.update(dt);
            proceedActions();

            foreach (ref enemy; enemies){
                enemy.update();
            }
            if(dt < FPS + 1) // a workaround against a bug at start up
                cpSpaceStep(space, dt);

            gTimer = SDL_GetTicks();
        }

        glClear(GL_COLOR_BUFFER_BIT);
        
        drawRail();
        drawForwardTrace();
        drawBackwardTrace();
        drawEnemies();
        drawHero();
        drawObstacles();
        //drawAreaRate();

        SDL_GL_SwapWindow(window);
    }

    clearObstacles();
    clearEnemies();
    
    SDL_GL_DeleteContext(glcontext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}

void resetGame(){
    hero = Hero(Point(SCREEN_WIDTH/2, SCREEN_HEIGHT));

    rail.clear();
    rail.pushBack(Point(0, 0));
    rail.pushBack(Point(0, SCREEN_HEIGHT));
    rail.pushBack(Point(SCREEN_WIDTH, SCREEN_HEIGHT));
    rail.pushBack(Point(SCREEN_WIDTH, 0));

    rate = 0.0f;

    updateTriangles();
    updateWalls();

    
    enemies.clear();
    enemies ~= Enemy(ENEMY_RADIUS, Point(152, 190), cpVect(0.2, 0.4));
    enemies ~= Enemy(ENEMY_RADIUS, Point(202, 150), cpVect(0.4, 0.2));
    
    obstacles ~= Obstacle(Point(SCREEN_WIDTH/2, SCREEN_HEIGHT/2), 60, 60);
    
}