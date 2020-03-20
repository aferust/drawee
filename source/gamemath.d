module gamemath;

import core.stdc.math: powf, sqrtf;

import std.math;
import std.range;

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

/*
auto splice2(Arr)(ref Arr oarr, size_t start, size_t n){
    Arr narr;
    
    foreach(i; start..start+n)
        narr.pushBack(oarr[i]);
    foreach(i; 0..n){
        oarr.remove(start);
    }
    return narr;
}
*/

float dist(P)(P start, P end) pure {
    return sqrtf(powf(start.x - end.x, 2) + powf(start.y - end.y, 2));
}