module gamemath;


version(WebAssembly){
    import clib;
}else{
    import core.stdc.math: powf, sqrtf, fabs;
}
import std.math;
import std.range;
import std.typecons;

import bindbc.sdl;
import dvector;

import globals;

@nogc nothrow:

auto roundPoint(Point p, int N) pure {
    p.x = cast(int)(round(float(p.x)/float(N))*N);
    p.y = cast(int)(round(float(p.y)/float(N))*N);
    return p;
}

import std.algorithm;
bool isPointInSegment(Point r, Point p, Point q) pure {
    return q.x <= max(p.x, r.x) &&
            q.x >= min(p.x, r.x) &&
            q.y <= max(p.y, r.y) &&
            q.y >= min(p.y, r.y);
}

bool isPointOntheRail(R)(ref R rail, Point point) pure {
    if(rail.length){
        for(int i = 0; i < rail.length-1; i++){
            if(isPointInSegment(rail[i], rail[i+1], point)){
                return true;
            }
        }
        
        if(isPointInSegment(rail[rail.length-1], rail[0], point)){
             return true;
        }
    }
    return false;
}


bool isPointInPolygon(R)(Point point, ref R polygon) pure {
    auto prev = polygon.back;
    
    bool oddNodes = false;
    foreach (i; 0..polygon.length){
        auto cur = polygon[i];
        if (isPointInSegment(prev, cur, point))
            return false;
        
        if (cur.y < point.y && prev.y >= point.y || prev.y < point.y
                && cur.y >= point.y) 
        {
            if (cur.x + (point.y - cur.y) / (prev.y - cur.y)
                    * (prev.x - cur.x) < point.x) 
            {
                oddNodes = !oddNodes;
            }
        }
        prev = cur;
    }
    return oddNodes;
}

bool isPointOntheTrace(R)(ref R Rail, Point point) pure {
    if(!Rail.length)
        return false;
    bool res = false;
    for(size_t i=0; i<Rail.length-1; i++)
        if(isPointInSegment(Rail[i], Rail[i+1], point))
            res = true;
    return res;
}

int belongWhichSegment(R)(ref R Rail, Point point) pure {
    for(size_t i=0; i<Rail.length-1; i++){
        if(isPointInSegment(Rail[i], Rail[i+1], point)){
            return cast(int)i;
        }
    }
    
    if(isPointInSegment(Rail[Rail.length-1], Rail[0], point)){
        return cast(int)Rail.length-1;
    }
    
    return -1;
}

float polygonArea(R)(ref R vertices) pure { 
    float area = 0;
    for (size_t i = 0; i < vertices.length; i++) {
        auto j = (i + 1) % vertices.length;
        area += float(vertices[i].x * vertices[j].y);
        area -= float(vertices[j].x * vertices[i].y);
    }
    return area / 2.0f;
}

bool is_clockwise(R)(ref R vertices) pure {
    return polygonArea(vertices) > 0;
} 

void removeDuplicateVertices(R)(ref R Rail, ref R vertices) pure { // very stupid
    Dvector!size_t to_be_removed;
    for (size_t i=0; i<vertices.length; i++){
        for (size_t ri=0; ri<Rail.length; ri++){
            if(Rail[ri].x == vertices[i].x &&  Rail[ri].y == vertices[i].y){
                to_be_removed.pushBack(ri);
            }
        }
    }
    if (to_be_removed.length > 0){
        for (size_t i = to_be_removed.length -1; i >= 0; i--)
            Rail.remove(to_be_removed[i], 1);
    }
    to_be_removed.free;
}

bool inPoly(P, R)(P point, ref R Rail){
    
    foreach(ref rp; Rail){
        if(rp.x == point.x && rp.y == point.y)
            return true;
    }
    return false;
}

float dist(P)(P start, P end) {
    return sqrtf(powf(start.x - end.x, 2) + powf(start.y - end.y, 2));
}

bool isEnemyOnTheTrace(const Circle c, ref Dvector!(Tuple!(Point, Point)) lines) {
    foreach(i; 0..lines.length){
        immutable l1 = lines[i][0];
        immutable l2 = lines[i][1];
        immutable ret = islineCircleCollision(
                                cast(float)l1.x, cast(float)l1.y,
                                cast(float)l2.x, cast(float)l2.y,
                                cast(float)c.pos.x, cast(float)c.pos.y, cast(float)c.radius);
        if(ret) return true;
    }
    return false;
}

private {
bool islineCircleCollision(in float x1, in float y1, in float x2, in float y2, in float cx, in float cy, in float r) {
    bool inside1 = pointCircle(x1,y1, cx,cy,r);
    bool inside2 = pointCircle(x2,y2, cx,cy,r);
    if (inside1 || inside2)
        return true;

    float distX = x1 - x2;
    float distY = y1 - y2;
    float len = sqrtf( (distX*distX) + (distY*distY) );

    float dot = ( ((cx-x1)*(x2-x1)) + ((cy-y1)*(y2-y1)) ) / (len*len);

    float closestX = x1 + (dot * (x2-x1));
    float closestY = y1 + (dot * (y2-y1));

    bool onSegment = linePoint(x1, y1, x2, y2, closestX, closestY);
    if (!onSegment)
        return false;

    distX = closestX - cx;
    distY = closestY - cy;
    float distance = sqrtf( (distX*distX) + (distY*distY) );

    if (distance <= r)
        return true;
    return false;
}

bool pointCircle(in float px, in float py, in float cx, in float cy, in float r) {
    float distX = px - cx;
    float distY = py - cy;
    float distance = sqrtf( (distX*distX) + (distY*distY) );

    if (distance <= r)
        return true;
    return false;
}

bool linePoint(in float x1, in float y1, in float x2, in float y2, in float px, in float py) {
    float d1 = sqrtf(cast(float)(powf(px-x1, 2) + powf(py-y1, 2)));
    float d2 = sqrtf(cast(float)(powf(px-x2, 2) + powf(py-y2, 2)));

    float lineLen = sqrtf(cast(float)(powf(x1-x2, 2) + powf(y1-y2, 2)));

    float buffer = 0.1;

    if (d1 + d2 >= lineLen-buffer && d1+d2 <= lineLen + buffer)
        return true;
    return false;
}
}

bool collides(Circle circle1, Circle circle2) {

    const dx = circle1.pos.x - circle2.pos.x;
    const dy = circle1.pos.y - circle2.pos.y;
    const distance = sqrtf(cast(float)(dx * dx + dy * dy));

    if(distance < circle1.radius + circle2.radius)
        return true;
    
    return false;
}