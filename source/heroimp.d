module heroimp;

import core.stdc.stdio;

import std.math;

import bindbc.sdl;

import globals;
import gamemath;
import tween;
import app;

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
    
    //int speed = 50;
    uint heroStat = movingOntheRail;
    uint direction = none;
    bool alive = true;

    nothrow @nogc:

    Circle circle() {
        return Circle(pos, cast(int)HERO_RADIUS);
    }

    void update(double dt){ // delta is not used here for now
        //if(actions.length)
        //    return;
        //printf("%f \n", dt);
        int s = 5;
        auto cpos = pos;
        auto pos_ = pos;
        import std.algorithm.searching: canFind;
        
        if(!keystate[SDL_SCANCODE_SPACE] && heroStat == cutting){
            moveOnTraceBack();
        } else
        if(keystate[SDL_SCANCODE_SPACE] && heroStat != goingBack && heroStat != dead){ // go with drawing
            /* We will check if half of the grid_size falls in polygon to be sure that thin walls are not being cut wrongly*/
            if(keystate[SDL_SCANCODE_DOWN] && pos.y <= SCREEN_HEIGHT && isPointInPolygon(Point(pos.x,pos.y+grid_size/2), rail)){
                pos.y += s;
                if( direction != down /*&& !this.isPosInObstacles(roundPoint(pos, grid_size))*/) {
                    pVertices.pushBack(pos_);
                    direction = down; 
                }
            }else if(keystate[SDL_SCANCODE_UP] && pos.y >= 0 && isPointInPolygon(Point(pos.x,pos.y-grid_size/2), rail)) {
                pos.y -=  s;
                if( direction != up /*&& !this.isPosInObstacles(roundPoint(pos, grid_size))*/) {
                    pVertices.pushBack(pos_);
                    direction = up;
                } 
            }else if(keystate[SDL_SCANCODE_LEFT] && pos.x >= 0 && isPointInPolygon(Point(pos.x-grid_size/2,pos.y), rail)) {
                pos.x -=  s;
                if( direction != left /*&& !this.isPosInObstacles(roundPoint(pos, grid_size))*/) {
                    pVertices.pushBack(pos_);
                    direction = left;
                }
            }else if(keystate[SDL_SCANCODE_RIGHT] && pos.x <= SCREEN_WIDTH && isPointInPolygon(Point(pos.x+grid_size/2,pos.y), rail)) {
                pos.x +=  s;
                if( direction != right /* && !this.isPosInObstacles(roundPoint(pos, grid_size))*/) {
                    pVertices.pushBack(pos_);
                    direction = right;
                } 
            }
            
            if(isPointOntheTrace( pVertices, pos)){
                pos = pos_;
            }else

            if(isPointInPolygon(pos, rail) && heroStat != dead && heroStat != goingBack){
                if (!isPointOntheTrace( pVertices, pos)/* && !this.isPosInObstacles(roundPoint(pos, grid_size))*/ ){
                    heroStat = cutting;
                    //pos = roundPoint(pos, grid_size);// I am not sure if round is needed here
                    //direction = none;
                    
                    /*
                    var isThinWall = false;
                    if (MG.pVertices.length > 0 && cc.pDistance(MG.pVertices[MG.pVertices.length-1], roundPoint(pos, grid_size)) <= grid_size){
                        isThinWall = true; // hope this will resolve thin walls issue
                    }
                    */
                }else
                    pos = pos_;
            }
            if(heroStat == cutting && isPointOntheRail(rail, pos)){
                //doNewRail(); //??? js de bu var
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
            
            //if( MG.heroStat == 'goingBack') MG.pVertices = MG.pVertices.reverse();
            if((hero_collide || trace_collide) && hero.heroStat != dead && pVertices.length > 0){
                hero.alive = false; hero.heroStat = dead;
                /*
                this.d_node_bt.clear();
                this.d_node_ft.clear();
                this.makePuff(pos);
                */
                
                actions.clear(); // this.mhero.stopActionByTag(999);
                
                auto first = makeAction(hero.pos, pVertices[0], cast(int)dist(hero.pos, pVertices[0])/5);
                first.started = true;
                actions.pushBack(first);
                auto last = makeAction(&fix);
        
                actions.pushBack(last);
                //MG.KEYS["32"] = false;
                
                return true;
            }
        }
    }
    return false;
}