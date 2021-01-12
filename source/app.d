/** Volfied-like game with SDL and OpenGL
    ported from my cocos2dx implementation
    Work in progress!!!

    Controls: use arrow keys and space.

Copyright:
 Copyright (c) 2020, Ferhat Kurtulmuş.
 License:
   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

import bindbc.sdl;

version(WebAssembly){
    import opengl.gl4;
    import core.stdc.stdio: printf;
}else{
    import bindbc.opengl;
    import core.stdc.stdio: printf;
}

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
import msgnode;

@nogc nothrow:

extern (C) int main() {

    version(WebAssembly){
        initSDLandFriends();
    }else{
        initSDL();
        initSDLTTF();
        initSDLImage();
        initGL();        
    }

    textureIdObstacle = loadTexture("res/misslescararmblue.png");
    textureIdBg1 = loadTexture("res/bg1.png");
    textureIdFg = loadTexture("res/fg.png");
    textureIdEnemy1 = loadTexture("res/enemy1.png");
    textureIdEnemy2 = loadTexture("res/enemy2.png");

    charSetScore = initMemoryFontSet(getFontWithSize("res/Nunito-Regular.ttf", 30), Color.green);
    charSetMsg = initMemoryFontSet(getFontWithSize("res/Nunito-Regular.ttf", 60), Color.red);

    import primitives;
    shaderProgramHero = loadShaderHero();
    shaderProgramEnemy = loadShaderEnemy();
    shaderProgramPoly = loadShaderPoly();
    shaderProgramGreen = loadShaderGreen();
    shaderProgramRed = loadShaderRed();
    shaderProgramFg = loadShaderFG();
    shaderProgramEn = loadShaderEn();
    shaderProgramText = loadShaderText();
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    ortho = Mat4.ortho(0.0f, float(SCREEN_WIDTH), float(SCREEN_HEIGHT), 0.0f);

    glClearColor(0.2f, 0.2f, 1.0f, 1.0f);

    space = cpSpaceNew();

    auto ch = cpSpaceAddCollisionHandler(space, COLLISION_TYPE_STATIC, COLLISION_TYPE_DYNAMIC);
    ch.beginFunc = &collisionBegin;
    ch.postSolveFunc = &collisionPost;
    ch.preSolveFunc = &collisionPre;
    ch.separateFunc = &collisionSeparate;
    
    resetGame();

    drSCircle = GLSolidCircle(shaderProgramHero);
    drShield = GLCircle(shaderProgramGreen);
    drLine = GLLine(shaderProgramGreen);
    drPoly = GLPoly(shaderProgramPoly);
    drRect = GLRect(shaderProgramGreen);
    drText = GLText(shaderProgramText);

    drTRect = GLTexturedRect(shaderProgramEn);

    keystate = SDL_GetKeyboardState(null);

    rate = 0.0f;

    clock = Clock();

    clock.tick();

    version(WebAssembly){
        emscripten_set_main_loop_arg(&mainLoop, cast(void*)window, 0, 1);
    }else{
        while(!quit)
            mainLoop(window);
    }

    clearObstacles();
    clearEnemies();
    
    SDL_GL_DeleteContext(glcontext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}

extern(C) void mainLoop(void* _win) @nogc nothrow {
    auto win = cast(SDL_Window*)_win;

    SDL_Event event;

    while( SDL_PollEvent( &event ) != 0 ){
        if(event.type == SDL_KEYDOWN){
            switch (event.key.keysym.sym){
                case SDLK_ESCAPE:
                    cancelMainLoop();
                    break;
                case SDLK_r:
                    resetGame();
                    break;
                case SDLK_p:
                    pause = !pause;
                    break;
                default:
                    break;
            }
        }
    }

    if(!pause){
        if(hero.alive == true && hero.heroStat != dead)
            dieIfCollide();

        hero.update(clock.dt);
        
        cpSpaceStep(space, clock.dt);

        foreach (ref enemy; enemies){
            enemy.update();
        }

        proceedActions(actions, clock.dt);
    }

    proceedActions(sceneActions, clock.dt);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    drawBg();
    drawRail();
    drawForwardTrace();
    drawBackwardTrace();
    drawEnemies();
    drawHero();
    drawObstacles();
    drawScore();
    drawMsgNode();
    drawTestUTF8();

    SDL_GL_SwapWindow(window);

    clock.tick();
}

void cancelMainLoop(){

    version(WebAssembly){
        emscripten_cancel_main_loop(); // not a good idea for web
    }else{
        quit = true;
    }
}

void resetGame(){
    if(actions.length)
        actions.clear();
    if(sceneActions.length)
        sceneActions.clear();

    openCeremony();

    hero = Hero(Point(SCREEN_WIDTH/2, SCREEN_HEIGHT - FOOTER_HEIGHT));

    msgNode = MsgNode(Point(SCREEN_WIDTH/2 - 120, SCREEN_HEIGHT/3), false, "Get ready");

    rail.clear();
    rail.pushBack(Point(0, 0));
    rail.pushBack(Point(0, SCREEN_HEIGHT - FOOTER_HEIGHT));
    rail.pushBack(Point(SCREEN_WIDTH, SCREEN_HEIGHT - FOOTER_HEIGHT));
    rail.pushBack(Point(SCREEN_WIDTH, 0));

    rate = 0.0f;

    updateTriangles();
    updateWalls();

    enemies.clear();
    enemies ~= Enemy(ENEMY_RADIUS, Point(152, 190), cpVect(0.2, 0.4), 0.005f, textureIdEnemy1);
    enemies ~= Enemy(ENEMY_RADIUS, Point(202, 150), cpVect(0.4, 0.2), -0.005f, textureIdEnemy2);
    
    obstacles ~= Obstacle(Point(SCREEN_WIDTH/2, SCREEN_HEIGHT/2), 60, 60);
    
}