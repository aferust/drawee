module obstacleimp;

import globals;
import chipmunk;

struct Obstacle {
    // a square box

    cpShape* shp_left;
    cpShape* shp_top;
    cpShape* shp_right;
    cpShape* shp_bottom;
    cpBody* sbody;

    Point pos;
    int w, h;

    @nogc nothrow:

    Rect rect(){
        return Rect(pos.x, pos.y, w, h);
    }

    this(Point p, int w, int h) {
        this.w = w;
        this.h = h;
        pos = Point(p.x - w/2, p.y - h/2); // set anchor to the center

        sbody = cpSpaceGetStaticBody(space);
        shp_left = cpSegmentShapeNew(sbody, cpVect(rect.x, rect.y), cpVect(rect.x, rect.y+rect.h), 10);      
        shp_top = cpSegmentShapeNew(sbody, cpVect(rect.x, rect.y+rect.h), cpVect(rect.x+rect.w, rect.y+rect.h), 10);
        shp_right = cpSegmentShapeNew(sbody, cpVect(rect.x+rect.w, rect.y+rect.h), cpVect(rect.x+rect.w, rect.y), 10);
        shp_bottom = cpSegmentShapeNew(sbody, cpVect(rect.x+rect.w, rect.y), cpVect(rect.x, rect.y), 10);
        
        cpShape*[4] shps = [shp_left, shp_top, shp_right, shp_bottom];
        foreach(ref shp; shps){
            cpShapeSetCollisionType(shp, COLLISION_TYPE_STATIC);
            cpShapeSetElasticity(shp, WALLS_ELASTICITY);
            cpShapeSetFriction(shp, WALLS_FRICTION);

            cpSpaceAddShape(space, shp);
        }

    }
}

@nogc nothrow:

void clearObstacles(){
        auto lno = obstacles.length;
        if(lno){
            while (lno--) {
                cpSpaceRemoveShape(space, obstacles[lno].shp_left);
                cpSpaceRemoveShape(space, obstacles[lno].shp_top);
                cpSpaceRemoveShape(space, obstacles[lno].shp_right);
                cpSpaceRemoveShape(space, obstacles[lno].shp_bottom);

                obstacles.remove(lno);
            }
        }
    }
