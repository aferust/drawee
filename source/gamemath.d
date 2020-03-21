module gamemath;

import core.stdc.math: powf, sqrtf;

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

float dist(P)(P start, P end) pure {
    return sqrtf(powf(start.x - end.x, 2) + powf(start.y - end.y, 2));
}

bool isEnemyOnTheTrace(SDL_Rect rect, ref Dvector!(Tuple!(Point, Point)) lines){
    foreach(i; 0..lines.length){
        if(lineIntersectsRect(lines[i][0], lines[i][1], rect)){
            return true;
        }
    }
    return false;
}
bool lineIntersectsRect(Point p1, Point p2, SDL_Rect r){
    auto sdlp1 = SDL_Point(p1.x, p1.y);
    auto sdlp2 = SDL_Point(p2.x, p2.y);
    return lineIntersectsLine(p1, p2, Point(r.x, r.y), Point(r.x + r.w, r.y)) ||
            lineIntersectsLine(p1, p2, Point(r.x + r.w, r.y), Point(r.x + r.w, r.y + r.h)) ||
            lineIntersectsLine(p1, p2, Point(r.x + r.w, r.y + r.h), Point(r.x, r.y + r.h)) ||
            lineIntersectsLine(p1, p2, Point(r.x, r.y + r.h), Point(r.x, r.y)) ||
            (SDL_PointInRect( &sdlp1, &r) && SDL_PointInRect(&sdlp2, &r));
}

bool lineIntersectsLine(Point l1p1, Point l1p2, Point l2p1, Point l2p2){
    auto q = (l1p1.y - l2p1.y) * (l2p2.x - l2p1.x) - (l1p1.x - l2p1.x) * (l2p2.y - l2p1.y);
    auto d = (l1p2.x - l1p1.x) * (l2p2.y - l2p1.y) - (l1p2.y - l1p1.y) * (l2p2.x - l2p1.x);

    if( d == 0 )
    {
        return false;
    }

    const r = q / d;

    q = (l1p1.y - l2p1.y) * (l1p2.x - l1p1.x) - (l1p1.x - l2p1.x) * (l1p2.y - l1p1.y);
    const s = q / d;

    if( r < 0 || r > 1 || s < 0 || s > 1 )
    {
        return false;
    }

    return true;
}
