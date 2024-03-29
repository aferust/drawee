module drawobjects;

import std.typecons: Tuple, tuple;

import globals;
import primitives;
import heroimp;

@nogc nothrow:


void drawBg(){
    drTRect.set(Rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT - FOOTER_HEIGHT), textureIdBg1, 0.0f);
    drTRect.draw();
}

void drawHero() {
    
    drSCircle.set(hero.pos.x, hero.pos.y, float(HERO_RADIUS), Color.blue);
    drSCircle.draw();
    if(hero.heroStat == movingOntheRail){
        drShield.set(hero.pos.x, hero.pos.y, float(8.0f + HERO_RADIUS), Color.green);
        drShield.draw();
    }
        
}

void drawEnemies(){
    foreach (ref enemy; enemies){            
        drTRect.set(Rect(enemy.pos.x-ENEMY_RADIUS, enemy.pos.y-ENEMY_RADIUS, ENEMY_RADIUS*2, ENEMY_RADIUS*2), enemy.textureId, enemy.angle);
        drTRect.draw();
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

    version(WebAssembly){
        import opengl.gl4;
    }else{
        import bindbc.opengl;
    }
    
    if (won)
        return;

    glClear(GL_DEPTH_BUFFER_BIT);
    glEnable(GL_STENCIL_TEST);
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    glDepthMask(GL_FALSE);
    glStencilFunc(GL_NEVER, 1, 0xFF);
    glStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);

    glStencilMask(0xFF);
    glClear(GL_STENCIL_BUFFER_BIT);

    drPoly.set(Color.white);
    drPoly.draw();

    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_TRUE);
    glStencilMask(0x00);
    
    glStencilFunc(GL_EQUAL, 0, 0xFF);
    glStencilFunc(GL_EQUAL, 1, 0xFF);

    drTRect.set(Rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT),textureIdFg, 0);
    drTRect.draw();

    glDisable(GL_STENCIL_TEST);    
}

void drawObstacles(){
    foreach(ref obstacle; obstacles){
        drTRect.set(obstacle.rect, textureIdObstacle, 0.0f);
        drTRect.draw();
    }
}


import core.stdc.stdio: sprintf;


import std.exception: assumeUnique;

void drawScore(){
    char[10] buffer;
    sprintf(buffer.ptr, "%0.2f %% \0", rate);
    
    import dvector;
    Dvector!dchar dc;
    foreach(char c; buffer){
        dc ~= cast(dchar)c;
    }

    dstring dstr = assumeUnique(dc[]);
    drawText(dstr, charSetScore, 20, SCREEN_HEIGHT - FOOTER_HEIGHT + 20);
    dc.free();
}


void drawText(ref dstring str, ref FontSet fs, int x, int y){

    int accumW;
    foreach (dchar c; str){
        
        auto cimg = fs[c];

        drText.set(Rect(x + accumW, y, cimg.w, cimg.h), cimg.textureId, 0f);
        drText.draw();

        accumW += cimg.w;
    }

}

void drawMsgNode(){
    if(msgNode.visible)
        drawText(msgNode.message, charSetMsg, msgNode.pos.x, msgNode.pos.y);
}

void drawTestUnicode(){
    auto testStr = "test unicode: ığüşiöçĞÜİŞÇÖ"d;
    drawText(testStr, charSetScore, 150, SCREEN_HEIGHT - FOOTER_HEIGHT + 20);
}