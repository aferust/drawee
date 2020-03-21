module enemyimp;

import chipmunk;

import globals;

// enemy motion is controlled by chipmunk physics

struct Enemy {
    Point pos;

    cpBody *_body;
    cpShape *shape;
    
    @nogc nothrow:
    this(int sz, Point p){
        pos = p;
        _body = cpBodyNew(1, cpMomentForCircle (0.5, 0, sz/2, cpVect(0, 0)));
        cpBodySetPosition(_body, cpVect(p.x, p.y));
        cpBodySetVelocity(_body, cpVect(0.2, 0.4));

        shape = cpCircleShapeNew(_body, sz/2, cpVect(0, 0));
        cpShapeSetElasticity(shape, 1);
        cpSpaceAddBody(space, _body);
        cpSpaceAddShape(space, shape);
    }

    void update(/*double dt*/){
        auto bp = cpBodyGetPosition(_body);
        pos = Point(cast(int)bp.x, cast(int)bp.y);
    }
}