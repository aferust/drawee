module heroimp;

import core.stdc.stdio;

import std.math;

import bindbc.sdl;

import globals;
import gamemath;
import tween;
import railimp;

enum : uint {
    movingOntheRail,
    dead,
    cutting,
    goingBack
}

enum : uint { // motion stat
    none,
    up,
    down,
    left,
    right
}

struct Hero {
    Point pos;
    
    uint heroStat = movingOntheRail;
    uint direction = none;
    bool alive = true;

    float speed = 0.05f;
    nothrow @nogc:

    Circle circle() {
        return Circle(pos, cast(int)HERO_RADIUS);
    }

    void update(float dt){ // delta is not used here for now
        //printf("%f \n", dt);
        int s = cast(int)(grid_size * dt * speed);
        auto cpos = pos;
        auto pos_ = pos;
        
        if(!keystate[SDL_SCANCODE_SPACE] && heroStat == cutting){
            moveOnTraceBack();
        } else
        if(keystate[SDL_SCANCODE_SPACE] && heroStat != goingBack && heroStat != dead){ // go with drawing
            /* We will check if half of the grid_size falls in polygon to be sure that thin walls are not being cut wrongly*/
            s = cast(int)(ceil(cast(float)s / cast(float)grid_size) * grid_size);
            if(keystate[SDL_SCANCODE_DOWN] && pos.y <= SCREEN_HEIGHT && isPointInPolygon(Point(pos.x,pos.y+grid_size/2), rail)){
                pos.y += s;
                if( direction != down && !isPosInObstacles(roundPoint(pos, grid_size))) {
                    pVertices.pushBack(pos_);
                    direction = down; 
                }
            }else if(keystate[SDL_SCANCODE_UP] && pos.y >= 0 && isPointInPolygon(Point(pos.x,pos.y-grid_size/2), rail)) {
                pos.y -=  s;
                if( direction != up && !isPosInObstacles(roundPoint(pos, grid_size))) {
                    pVertices.pushBack(pos_);
                    direction = up;
                } 
            }else if(keystate[SDL_SCANCODE_LEFT] && pos.x >= 0 && isPointInPolygon(Point(pos.x-grid_size/2,pos.y), rail)) {
                pos.x -=  s;
                if( direction != left && !isPosInObstacles(roundPoint(pos, grid_size))) {
                    pVertices.pushBack(pos_);
                    direction = left;
                }
            }else if(keystate[SDL_SCANCODE_RIGHT] && pos.x <= SCREEN_WIDTH && isPointInPolygon(Point(pos.x+grid_size/2,pos.y), rail)) {
                pos.x +=  s;
                if( direction != right && !isPosInObstacles(roundPoint(pos, grid_size))) {
                    pVertices.pushBack(pos_);
                    direction = right;
                } 
            }
            
            if(isPointOntheTrace( pVertices, pos)){
                pos = pos_;
            }else

            if(isPointInPolygon(pos, rail) && heroStat != dead && heroStat != goingBack){
                if (!isPointOntheTrace( pVertices, pos) && !isPosInObstacles(roundPoint(pos, grid_size)) ){
                    heroStat = cutting;
                }else
                    pos = pos_;
            }
            if(heroStat == cutting && isPointOntheRail(rail, pos)){
                keystate[SDL_SCANCODE_SPACE] = false;
                doNewRail();
                heroStat = movingOntheRail;
            }
        }else if(heroStat != goingBack && heroStat != dead) {// go without drawing
            if(keystate[SDL_SCANCODE_DOWN] && ((cpos.y + s) <= SCREEN_HEIGHT)) {
                if(isPointOntheRail(rail, Point(cpos.x, cpos.y+grid_size/2))) cpos.y += s; // these conditions are for thin walls
            } else if(keystate[SDL_SCANCODE_UP] && ((cpos.y - s) >= 0)) {
                if(isPointOntheRail(rail, Point(cpos.x, cpos.y-grid_size/2))) cpos.y -= s;
            } else if(keystate[SDL_SCANCODE_LEFT] && ((cpos.x - s) >= 0)) {
                if(isPointOntheRail(rail, Point(cpos.x-grid_size/2, cpos.y))) cpos.x -= s;
            } else if(keystate[SDL_SCANCODE_RIGHT] && ((cpos.x + s) <= SCREEN_WIDTH)) {
                if(isPointOntheRail(rail, Point(cpos.x+grid_size/2, cpos.y))) cpos.x += s;
            }
            
            if(isPointOntheRail(rail, cpos) && !isPointInPolygon(cpos, rail)){
                heroStat = movingOntheRail;
                pos = roundPoint(cpos, grid_size);
            }
        }

    }

    bool isPosInObstacles(Point pos){
        auto len = obstacles.length;
        foreach(i; 0..len){
            auto rect = obstacles[i].rect;
            int offset = grid_size; // offset is not a must. just looks better
            Point[4] rect_with_offset = [Point(rect.x-offset, rect.y-offset),
                                        Point(rect.x+rect.w+offset, rect.y-offset),
                                        Point(rect.x+rect.w+offset, rect.y+rect.h+offset),
                                        Point(rect.x-offset, rect.y+rect.h+offset)
                                        ];
            
            if(isPointInPolygon(pos, rect_with_offset))
                return true;
        }
        return false;
    }

}

@nogc nothrow:

bool dieIfCollide(){
    import gamemath;
    if(enemies.length && hero.alive == true && (hero.heroStat == cutting || hero.heroStat == goingBack)){
        auto ln = enemies.length;
        while (ln--) {
            auto enemy = enemies[ln];

            bool hero_collide = hero.alive == true && enemy.circle.collides(hero.circle) && !isPointOntheRail(rail, hero.pos);
            bool trace_collide = hero.alive == true && isEnemyOnTheTrace(enemy.circle, deathTrace);

            if(hero_collide) printf("hero_collide \n".ptr);
            if(trace_collide) printf("trace_collide \n".ptr);
            
            if((hero_collide || trace_collide) && hero.heroStat != dead && pVertices.length > 0){
                hero.alive = false; hero.heroStat = dead;
                /*
                this.makePuff(pos);
                */
                
                actions.clear();
                
                auto first = makeAction(hero.pos, pVertices[0], cast(int)dist(hero.pos, pVertices[0])/grid_size);
                first.started = true;
                actions.pushBack(first);
                auto last = makeAction(&fix);
        
                actions.pushBack(last);
                //KEYS[32] = false;
                
                return true;
            }
        }
    }
    return false;
}

void moveOnTraceBack(){
    import gamemath;

    hero.heroStat = goingBack;
    if(pVertices.length>0){
        //hero.pos = pVertices[0];
        auto first = makeAction(hero.pos, pVertices[pVertices.length-1], cast(int)dist(hero.pos, pVertices[pVertices.length-1])/grid_size);
        first.started = true;
        actions.pushBack(first);
        foreach_reverse(i; 1..pVertices.length){
            actions.pushBack(makeAction(pVertices[i], pVertices[i-1], cast(int)dist(pVertices[i], pVertices[i-1])/grid_size));
        }
        
        auto last = makeAction(&fix);
        
        actions.pushBack(last);
    }
}

void fix() {
    
    //this.d_node_bt.clear();
    hero.direction = none;// cook onemli
    hero.heroStat = movingOntheRail;
    if(hero.pos != pVertices[0])
        hero.pos = pVertices[0]; 
    pVertices.free;
    if(!hero.alive)
        hero.alive = true;
}