module drawobjects;

import std.typecons: Tuple, tuple;

import globals;
import primitives;
import heroimp;

@nogc nothrow:

void drawHero() {
    
    drHero.set(hero.pos.x, hero.pos.y, float(HERO_RADIUS), Color.blue);
    drHero.draw();
    if(hero.heroStat == movingOntheRail){
        drShield.set(hero.pos.x, hero.pos.y, float(8.0f + HERO_RADIUS), Color.green);
        drShield.draw();
    }
        
}

void drawEnemies(){
    foreach (ref enemy; enemies){
        drHero.set(enemy.pos.x, enemy.pos.y, float(ENEMY_RADIUS), Color.black);
        drHero.draw();
    }
}

void line(Point p1, Point p2, Color color){
    drLine.set(p1, p2, color);
    drLine.draw();
}

void drawForwardTrace() {
    deathTrace.clear();
    if(hero.heroStat == cutting && hero.alive){
        const len = pVertices.length;
        if(len==1){
            auto start_point = pVertices[0];
            line(start_point, hero.pos, Color.red);
            
            deathTrace.pushBack(tuple(start_point, hero.pos));

        }else if(len>1){
            for(size_t i = 0; i<len-1; i++){
                line(pVertices[i], pVertices[i+1], Color.red);
                deathTrace.pushBack(tuple(pVertices[i], pVertices[i+1]));
            }
            line(pVertices[len-1], hero.pos, Color.red);
            deathTrace.pushBack(tuple(pVertices[len-1], hero.pos));
        }
        
    }
}

void drawBackwardTrace() {
    import gamemath;

    if(hero.heroStat == goingBack && hero.alive){
        const size_t len = pVertices.length;
        size_t ind = 0;
        
        if(len==1){
            line(pVertices[0], hero.pos, Color.green);
        }else if(len>1){
            for(auto i = 0; i<len-1; i++){
                if (!isPointOntheTrace(pVertices, hero.pos)){
                    line(pVertices.back, hero.pos, Color.green);
                    ind = len;
                    break;
                }else if (isPointInSegment(pVertices[i], pVertices[i+1], hero.pos )){
                    line(pVertices[i], hero.pos, Color.green);
                    ind = i+1;
                    break;
                    
                }
            }
            while(ind--)
                if(ind != 0)
                    line(pVertices[ind], pVertices[ind-1], Color.green);
        }
    }
}

void drawRail(){
    drPoly.set(Color.white);
    drPoly.draw();
}

void drawObstacles(){
    foreach(ref obstacle; obstacles){
        auto w = obstacle.rect.w;
        auto h = obstacle.rect.h;
        
        drRect.set(obstacle.rect, Color.green);
        drRect.draw();
        line(Point(obstacle.rect.x, obstacle.rect.y),
            Point(obstacle.rect.diag.x, obstacle.rect.diag.y), Color.red);
        line(Point(obstacle.rect.x+w, obstacle.rect.y),
            Point(obstacle.rect.x, obstacle.rect.y+h), Color.red);
    }
}