module drawobjects;

import std.typecons: Tuple, tuple;

import globals;
import primitives;
import heroimp;

@nogc nothrow:

void drawHero() {
    filledCircle(hero.pos.x, hero.pos.y, cast(int)(HERO_RADIUS), Color!float(0,0,1));
    if(hero.heroStat == movingOntheRail)
        hollowCircle(hero.pos.x, hero.pos.y, cast(int)(8 + HERO_RADIUS), Color!float(0,1,0));
}

void drawEnemies(){
    foreach (ref enemy; enemies)
        filledCircle(enemy.pos.x, enemy.pos.y, ENEMY_RADIUS*2, Color!float(0.0f, 0.0f, 0.0f));
}

void drawForwardTrace() {
    deathTrace.clear();
    if(hero.heroStat == cutting && hero.alive){
        const len = pVertices.length;
        const color = Color!float(1,0,0);
        if(len==1){
            auto start_point = pVertices[0];
            line(start_point, hero.pos, color);
            
            deathTrace.pushBack(tuple(start_point, hero.pos));

        }else if(len>1){
            for(size_t i = 0; i<len-1; i++){
                line(pVertices[i], pVertices[i+1], color);
                deathTrace.pushBack(tuple(pVertices[i], pVertices[i+1]));
            }
            line(pVertices[len-1], hero.pos, color);
            deathTrace.pushBack(tuple(pVertices[len-1], hero.pos));
        }
        
    }
}

void drawBackwardTrace() {
    import gamemath;

    if(hero.heroStat == goingBack && hero.alive){
        const size_t len = pVertices.length;
        size_t ind = 0;
        const color = Color!float(0,1,0);
        if(len==1){
            line(pVertices[0], hero.pos, color);
        }else if(len>1){
            for(auto i = 0; i<len-1; i++){
                if (!isPointOntheTrace(pVertices, hero.pos)){
                    line(pVertices.back, hero.pos, color);
                    ind = len;
                    break;
                }else if (isPointInSegment(pVertices[i], pVertices[i+1], hero.pos )){
                    line(pVertices[i], hero.pos, color);
                    ind = i+1;
                    break;
                    
                }
            }
            while(ind--)
                if(ind != 0)
                    line(pVertices[ind], pVertices[ind-1], color);
        }
    }
}

void drawRail(){
    drawPolygon();
}

void drawObstacles(){
    foreach(ref obstacle; obstacles){
        auto w = obstacle.rect.w;
        auto h = obstacle.rect.h;
        drawRect(obstacle.rect, Color!float(0.5f, 0.2f, 0.6f));
        line(Point(obstacle.rect.x, obstacle.rect.y),
            Point(obstacle.rect.diag.x, obstacle.rect.diag.y), Color!float(1.0f, 0.0f, 0.0f));
        line(Point(obstacle.rect.x+w, obstacle.rect.y),
            Point(obstacle.rect.x, obstacle.rect.y+h), Color!float(1.0f, 0.0f, 0.0f));
    }
}