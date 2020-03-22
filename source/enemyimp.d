module enemyimp;

import core.stdc.stdio;

import chipmunk;

import globals;

// enemy motion is controlled by chipmunk physics

struct Enemy {
    Point pos;

    cpBody *_body;
    cpShape *shape;
    
    @nogc nothrow:

    Circle circle() {
        return Circle(pos, ENEMY_RADIUS);
    }

    this(int radius, Point p, cpVect velocity){
        pos = p;
        _body = cpBodyNew(1, cpMomentForCircle (0.5, 0, radius, cpVect(0, 0)));
        cpBodySetPosition(_body, cpVect(p.x, p.y));
        cpBodySetVelocity(_body, velocity);

        shape = cpCircleShapeNew(_body, radius, cpVect(0, 0));

        //auto filter = cpShapeFilterNew(1, 1, 1);
        //cpShapeSetFilter(shape, filter);

        cpShapeSetElasticity(shape, 1);
        cpSpaceAddBody(space, _body);
        cpSpaceAddShape(space, shape);
    }

    void update(/*double dt*/){
        auto bp = cpBodyGetPosition(_body);
        pos = Point(cast(int)bp.x, cast(int)bp.y);
    }
}

@nogc nothrow:

void killCapturedEnemies(){
    import gamemath;
    if(enemies.length){
        auto ln = enemies.length;
        while (ln--) {
            const pos = enemies[ln].pos;
            if(!isPointInPolygon(pos, rail)){
                if(cpSpaceContainsShape(space, enemies[ln].shape)){
                    cpSpaceRemoveBody(space, enemies[ln]._body);
                    cpSpaceRemoveShape(space, enemies[ln].shape);
                    enemies.remove(ln);

                    // makePuff(pos);
                }
            }
        }
        if(!enemies.length && !won){
            won = true;
            //winLevel();
            printf("You won!");
        } 
    }
}

void clearEnemies(){
    if(enemies.length){
        auto ln = enemies.length;
        while (ln--) {
            if(cpSpaceContainsShape(space, enemies[ln].shape)){
                cpSpaceRemoveBody(space, enemies[ln]._body);
                cpSpaceRemoveShape(space, enemies[ln].shape);
                
                auto pos = enemies[ln].pos;
                enemies.remove(ln);

                // makePuff(pos);
            } 
        }
    }
}


nothrow @nogc extern (C){
    ubyte collisionBegin(cpArbiter* arbiter, cpSpace* space, void* data){
        cpShape* a, b;
        cpArbiterGetShapes(arbiter, &a, &b);
        
        if (a.filter.group == 1 && b.filter.group == 1)
            return false;
            
        return true;
    }
    ubyte collisionPre(cpArbiter* arbiter, cpSpace* space, void* data){return true;}
    void collisionPost(cpArbiter* arbiter, cpSpace* space, void* data){}
    void collisionSeparate(cpArbiter* arbiter, cpSpace* space, void* data){}
}