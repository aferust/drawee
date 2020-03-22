/** Volfied-like game with SDL and OpenGL
    ported from my cocos2dx implementation
    Work in progress!!!

    Controls: use arrow keys and space.

Copyright:
 Copyright (c) 2020, Ferhat Kurtulmuş.
 License:
   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

import std.stdio;
import std.stdint;
import std.typecons;

import bindbc.sdl;
import bindbc.opengl;
import dvector;
import earcutd;
import chipmunk;

import globals;
import boilerplate;
import drawobjects;
import heroimp;
import enemyimp;

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

    enemies ~= Enemy(ENEMY_RADIUS*2, Point(150, 150), cpVect(0.2, 0.4));
    enemies ~= Enemy(ENEMY_RADIUS*2, Point(200, 150), cpVect(0.4, 0.2));

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

    SDL_GL_DeleteContext(glcontext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}

void updateTriangles(){
    
    alias Point = Tuple!(int, int);

    Dvector!(Dvector!(Point)) polygon;
    Dvector!(Point) p1;
    foreach(i; 0..rail.length){
        p1.pushBack(Point(rail[i].x, rail[i].y));
    }
    polygon.pushBack(p1);

    Earcut!(size_t, Dvector!(Dvector!(Point))) earcut;

    earcut.run(polygon);

    triangles.free;
    triangles.insert(earcut.indices, 0);

    earcut.indices.free;
    p1.free;
    polygon.free;
}

void fix() @nogc nothrow{
    
    //this.d_node_bt.clear();
    hero.direction = none;// cook onemli
    hero.heroStat = movingOntheRail;
    if(hero.pos != pVertices[0])
        hero.pos = pVertices[0]; 
    pVertices.free;
    if(!hero.alive)
        hero.alive = true;
}

import tween;

void moveOnTraceBack(){
    import gamemath;

    hero.heroStat = goingBack;
    if(pVertices.length>0){
        //hero.pos = pVertices[0];
        auto first = makeAction(hero.pos, pVertices[pVertices.length-1], cast(int)dist(hero.pos, pVertices[pVertices.length-1])/5);
        first.started = true;
        actions.pushBack(first);
        foreach_reverse(i; 1..pVertices.length){
            actions.pushBack(makeAction(pVertices[i], pVertices[i-1], cast(int)dist(pVertices[i], pVertices[i-1])/5));
        }
        
        auto last = makeAction(&fix);
        
        actions.pushBack(last);
    }
}

void doNewRail(){
    processRail();
    updateTriangles();
    updateWalls();
    /*
    var percent = Math.round(100-100*this.currentArea/this.totalArea);
    if(percent >= 80 && this.won == false){
        this.won = true;
        this.winLevel();
    }
    */
}

void processRail(){
    import std.math;
    import gamemath;
    
    pVertices.pushBack(roundPoint(hero.pos, grid_size)); // the last point of polygon

    auto start_ind = belongWhichSegment(rail, pVertices[0]);
    auto end_ind = belongWhichSegment(rail, pVertices[pVertices.length-1]);
    
    if((start_ind==0 && end_ind == rail.length-1) || (start_ind== rail.length-1 && end_ind == 0)){
        foreach(i; 0..rail.length/2){
            auto f0 = rail[0]; rail.remove(0); rail.pushBack(f0);
        }
        
        start_ind = belongWhichSegment(rail, pVertices[0]);
        end_ind = belongWhichSegment(rail, pVertices[pVertices.length-1]);
    }
        
    if(start_ind == end_ind){
        if (!is_clockwise(pVertices)){
            foreach(i; 0..pVertices.length)
                if(!inPoly(pVertices[i], rail)) rail.insert(pVertices[i], end_ind + 1);
        }else{
            import std.range;
            auto inverted = pVertices.reversed_copy;
            foreach(e; inverted)
                if(!inPoly(e, rail)) rail.insert(e, start_ind + 1);
            inverted.free;
        }
        
    }else{ // some vertices will be removed

        // with this approach there may be redundant intermediate points
        // but they are not problem.
        
        if(start_ind < end_ind){
            //printf("duz \n".ptr);

            auto altRail = rail.splice(start_ind+1, end_ind - start_ind);

            auto reversed = pVertices.reversed_copy;
            foreach(e; reversed)
                if(!inPoly(e, rail)) rail.insert(e, start_ind + 1);
            reversed.free;

            auto A1 = fabs(polygonArea(rail));

            foreach(e; pVertices)
                if(!inPoly(e, altRail)) altRail.insert(e, 0);

            auto A2 = fabs(polygonArea(altRail));
            if(A2 > A1) {
                rail.free;
                rail = altRail;
            }else
                altRail.free;
            
        }else{
            //printf("ters \n".ptr);
            
            auto altRail = rail.splice(end_ind + 1, start_ind - end_ind);

            foreach(i; 0..pVertices.length)
                if(!inPoly(pVertices[i], rail)) rail.insert(pVertices[i], end_ind + 1);

            auto A1 = fabs(polygonArea(rail));

            auto reversed = pVertices.reversed_copy;
            pVertices.free;
            foreach(e; reversed)
                if(!inPoly(e, altRail)) altRail.insert(e, 0);
            reversed.free;

            auto A2 = fabs(polygonArea(altRail));
            if(A2 > A1) {
                rail.free;
                rail = altRail;
            } else 
                altRail.free;
            
        }
        
    }
    // printf("len of poly: %d \n", rail.length);
    pVertices.free;
    hero.direction = none;
    
    /*
    this.draw_rail();
    this.updateWalls();
    */
    
    currentArea = fabs(polygonArea(rail));
    float rate = currentArea / totalArea;
    printf("%.2f%% \n", 100.0f*(1.0f - rate));
    /*
    if(1-rate >= 0.8f){
        enemies.clear();
        printf("You won!");
    }
    */
}

void updateWalls(){
    // clear old walls
    auto ln = walls.length;
    while (ln--) {
        if(cpShapeGetCollisionType(walls[ln]) == COLLISION_TYPE_STATIC){
            if(cpSpaceContainsShape(space, walls[ln])){
                cpSpaceRemoveShape(space, walls[ln]);
                walls[ln] = null;
                walls.remove(ln);
            } 
        }
    }

    // clear old obstacles
    // this.clearObstacles();

    // create new walls
    auto len = rail.length;
    auto staticBody = cpSpaceGetStaticBody(space);
    for(auto i=0; i<len-1; i++){
        auto a_wall = cpSegmentShapeNew(staticBody, cpVect(rail[i].x, rail[i].y), cpVect(rail[i+1].x, rail[i+1].y), 10);
        cpShapeSetCollisionType(a_wall, COLLISION_TYPE_STATIC);
        cpShapeSetElasticity(a_wall, WALLS_ELASTICITY);
        cpShapeSetFriction(a_wall, WALLS_FRICTION);
        
        walls.pushBack(a_wall);
        cpSpaceAddShape(space, a_wall);
    }
    auto last_wall = cpSegmentShapeNew(staticBody, cpVect(rail[len-1].x, rail[len-1].y), cpVect(rail[0].x, rail[0].y), 10);
    
    cpShapeSetCollisionType(last_wall, COLLISION_TYPE_STATIC);
    cpShapeSetElasticity(last_wall, WALLS_ELASTICITY);
    cpShapeSetFriction(last_wall, WALLS_FRICTION);
    walls.pushBack(last_wall);
    cpSpaceAddShape(space, last_wall);

    // create new obstacles
    // this.spawnObstacles();

    killCapturedEnemies();
}



