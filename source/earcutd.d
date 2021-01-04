  
/** D port (betterC) of the earcut polygon triangulation library.
    
    Ported from: https://github.com/mapbox/earcut.hpp

Copyright:
 Copyright (c) 2020, Ferhat Kurtulmuş.
 License:
   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

module earcutd;

version(LDC){
    pragma(LDC_no_moduleinfo);
}

import dvector;

private {
    import clib;
    import std.traits;
    //import std.math;
    //import std.stdint;
    private T min(T)(scope const T a, scope const T b) pure nothrow @nogc {
        return a < b ? a : b;
    }

    private T max(T)(scope const T a, scope const T b) pure nothrow @nogc {
        return b < a ? a : b;
    }

    alias int32_t  = int;

    extern (C) @nogc nothrow{
        double sqrt(double x);
        float sqrtf(float x);
        float fabs(float x);
        double sin(double x);
        double cos(double x);
        double acos(double x);
        double atan2(double y, double x);
        double fmod(double x, double y);
        double exp(double x);
        double pow(double x, double y);
        float powf( float base, float exponent );
        double floor(double x);
        double ceil(double x);
        double round (double a);
        float roundf (float a);
    }
}

struct Earcut(N, Polygon) {

    alias ASeq = TemplateArgsOf!Polygon;
    alias VecPoint = ASeq[0];
    alias ASeq2 = TemplateArgsOf!VecPoint;
    alias Point = ASeq2[0];

    Dvector!N indices;
    size_t vertices = 0;

    struct Node {
        
        N i;
        double x;
        double y;
        
    @nogc nothrow:
        int opCmp(Node rhs) {
            if (x < rhs.x) return -1;
            if (rhs.x < x) return 1;
            return 0;
        }

        // previous and next vertice nodes in a polygon ring
        Node* prev;
        Node* next;

        // z-order curve value
        int32_t z;

        // previous and next nodes in z-order
        Node* prevZ;
        Node* nextZ;

        // indicates whether this is a steiner point
        bool steiner = false;

        this(N index, double x_, double y_){
            i = index;
            x = x_;
            y = y_;
        }
    }

    bool hashing;
    double minX, maxX;
    double minY, maxY;
    double inv_size = 0.0;

    struct ObjectPool(T) {
        @nogc nothrow:
        public:
        this(size_t blockSize_) {
            reset(blockSize_);
        }
        ~this() {
            clear();
        }

        T* construct(N)(N i, double x, double y) {
            if (currentIndex >= blockSize) {
                currentBlock = cast(T*)malloc(blockSize*T.sizeof);
                allocations.pushBack(currentBlock);
                currentIndex = 0;
            }
            T* object = &currentBlock[currentIndex++];
            *object = T(i, x, y);
            return object;
        }
        void reset(size_t newBlockSize) {
            foreach (allocation; allocations) {
                free(allocation);
            }
            allocations.free();
            blockSize = max(1, newBlockSize);
            currentBlock = null;
            currentIndex = blockSize;
        }
        void clear() { reset(blockSize); }
        private:
        T* currentBlock = null;
        size_t currentIndex = 1;
        size_t blockSize = 1;
        Dvector!(T*) allocations;
    }

    ObjectPool!Node nodes;
    
    @nogc nothrow:

    void run(ref Polygon points){
        // reset
        indices.free;
        vertices = 0;

        if (!points.length) return;

        double x;
        double y;
        int threshold = 80;
        size_t len = 0;

        for (size_t i = 0; threshold >= 0 && i < points.length; i++) {
            threshold -= cast(int)(points[i].length);
            len += points[i].length;
        }

        //estimate size of nodes and indices
        nodes.reset(len * 3 / 2);
        indices.reserve(len + points[0].length);

        Node* outerNode = linkedList(points[0], true);
        if (!outerNode || outerNode.prev == outerNode.next) return;

        if (points.length > 1) outerNode = eliminateHoles(points, outerNode);

        // if the shape is not too simple, we'll use z-order curve hash later; calculate polygon bbox
        hashing = threshold < 0;
        if (hashing) {
            Node* p = outerNode.next;
            minX = maxX = outerNode.x;
            minY = maxY = outerNode.y;
            do {
                x = p.x;
                y = p.y;
                minX = min(minX, x);
                minY = min(minY, y);
                maxX = max(maxX, x);
                maxY = max(maxY, y);
                p = p.next;
            } while (p != outerNode);

            // minX, minY and size are later used to transform coords into integers for z-order calculation
            inv_size = max(maxX - minX, maxY - minY);
            inv_size = inv_size != .0 ? (1. / inv_size) : .0;
        }

        earcutLinked(outerNode);

        nodes.clear();        
    }

    Node* linkedList(Ring)(ref Ring points, const bool clockwise) {
        //using Point = typename Ring::value_type;
        double sum = 0;
        const size_t len = points.length;
        size_t i, j;
        Node* last = null;

        // calculate original winding order of a polygon ring
        for (i = 0, j = len > 0 ? len - 1 : 0; i < len; j = i++) {
            const p1 = points[i];
            const p2 = points[j];
            const double p20 = p2[0];
            const double p10 = p1[0];
            const double p11 = p1[1];
            const double p21 = p2[1];
            
            sum += (p20 - p10) * (p11 + p21);
        }

        // link points into circular doubly-linked list in the specified winding order
        if (clockwise == (sum > 0)) {
            for (i = 0; i < len; i++) last = insertNode(vertices + i, points[i], last);
        } else {
            for (i = len; i-- > 0;) last = insertNode(vertices + i, points[i], last);
        }

        if (last && equals(last, last.next)) {
            removeNode(last);
            last = last.next;
        }

        vertices += len;

        return last;
    }

    Node* filterPoints(Node* start, Node* end = null){
        if (!end) end = start;

        Node* p = start;
        bool again;
        do {
            again = false;

            if (!p.steiner && (equals(p, p.next) || area(p.prev, p, p.next) == 0)) {
                removeNode(p);
                p = end = p.prev;

                if (p == p.next) break;
                again = true;

            } else {
                p = p.next;
            }
        } while (again || p != end);

        return end;
    }

    void earcutLinked(Node* ear, int pass = 0){
        if (!ear) return;

        // interlink polygon nodes in z-order
        if (!pass && hashing) indexCurve(ear);

        Node* stop = ear;
        Node* prev;
        Node* next;

        int iterations = 0;

        // iterate through ears, slicing them one by one
        while (ear.prev != ear.next) {
            iterations++;
            prev = ear.prev;
            next = ear.next;

            if (hashing ? isEarHashed(ear) : isEar(ear)) {
                // cut off the triangle
                indices.pushBack(prev.i);
                indices.pushBack(ear.i);
                indices.pushBack(next.i);

                removeNode(ear);

                // skipping the next vertice leads to less sliver triangles
                ear = next.next;
                stop = next.next;

                continue;
            }

            ear = next;

            // if we looped through the whole remaining polygon and can't find any more ears
            if (ear == stop) {
                // try filtering points and slicing again
                if (!pass) earcutLinked(filterPoints(ear), 1);

                // if this didn't work, try curing all small self-intersections locally
                else if (pass == 1) {
                    ear = cureLocalIntersections(filterPoints(ear));
                    earcutLinked(ear, 2);

                // as a last resort, try splitting the remaining polygon into two
                } else if (pass == 2) splitEarcut(ear);

                break;
            }
        }

    }

    bool isEar(Node* ear) {
        Node* a = ear.prev;
        Node* b = ear;
        Node* c = ear.next;

        if (area(a, b, c) >= 0) return false; // reflex, can't be an ear

        // now make sure we don't have other points inside the potential ear
        Node* p = ear.next.next;

        while (p != ear.prev) {
            if (pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) &&
                area(p.prev, p, p.next) >= 0) return false;
            p = p.next;
        }

        return true;
    }

    bool isEarHashed(Node* ear) {
        Node* a = ear.prev;
        Node* b = ear;
        Node* c = ear.next;

        if (area(a, b, c) >= 0) return false; // reflex, can't be an ear

        // triangle bbox; min & max are calculated like this for speed
        const double minTX = min(a.x, min(b.x, c.x));
        const double minTY = min(a.y, min(b.y, c.y));
        const double maxTX = max(a.x, max(b.x, c.x));
        const double maxTY = max(a.y, max(b.y, c.y));

        // z-order range for the current triangle bbox;
        const int32_t minZ = zOrder(minTX, minTY);
        const int32_t maxZ = zOrder(maxTX, maxTY);

        // first look for points inside the triangle in increasing z-order
        Node* p = ear.nextZ;

        while (p && p.z <= maxZ) {
            if (p != ear.prev && p != ear.next &&
                pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) &&
                area(p.prev, p, p.next) >= 0) return false;
            p = p.nextZ;
        }

        // then look for points in decreasing z-order
        p = ear.prevZ;

        while (p && p.z >= minZ) {
            if (p != ear.prev && p != ear.next &&
                pointInTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y) &&
                area(p.prev, p, p.next) >= 0) return false;
            p = p.prevZ;
        }

        return true;
    }

    Node* cureLocalIntersections(Node* start) {
        Node* p = start;
        do {
            Node* a = p.prev;
            Node* b = p.next.next;

            // a self-intersection where edge (v[i-1],v[i]) intersects (v[i+1],v[i+2])
            if (!equals(a, b) && intersects(a, p, p.next, b) && locallyInside(a, b) && locallyInside(b, a)) {
                indices.pushBack(a.i);
                indices.pushBack(p.i);
                indices.pushBack(b.i);

                // remove two nodes involved
                removeNode(p);
                removeNode(p.next);

                p = start = b;
            }
            p = p.next;
        } while (p != start);

        return filterPoints(p);
    }

    void splitEarcut(Node* start) {
        // look for a valid diagonal that divides the polygon into two
        Node* a = start;
        do {
            Node* b = a.next.next;
            while (b != a.prev) {
                if (a.i != b.i && isValidDiagonal(a, b)) {
                    // split the polygon in two by the diagonal
                    Node* c = splitPolygon(a, b);

                    // filter colinear points around the cuts
                    a = filterPoints(a, a.next);
                    c = filterPoints(c, c.next);

                    // run earcut on each half
                    earcutLinked(a);
                    earcutLinked(c);
                    return;
                }
                b = b.next;
            }
            a = a.next;
        } while (a != start);
    }

    Node* eliminateHoles(Polygon)(ref Polygon points, Node* outerNode){
        const size_t len = points.length;

        Dvector!(Node*) queue;
        for (size_t i = 1; i < len; i++) {
            Node* list = linkedList(points[i], false);
            if (list) {
                if (list == list.next) list.steiner = true;
                queue.pushBack(getLeftmost(list));
            }
        }
        
        import std.algorithm.sorting;
        
        auto _q = queue.slice.sort!("a < b");

        // process holes from left to right
        for (size_t i = 0; i < queue.length; i++) {
            eliminateHole(_q[i], outerNode);
            outerNode = filterPoints(outerNode, outerNode.next);
        }

        queue.free;
        return outerNode;
    }

    void eliminateHole(Node* hole, Node* outerNode) {
        outerNode = findHoleBridge(hole, outerNode);
        if (outerNode) {
            Node* b = splitPolygon(outerNode, hole);

            // filter out colinear points around cuts
            filterPoints(outerNode, outerNode.next);
            filterPoints(b, b.next);
        }
    }

// David Eberly's algorithm for finding a bridge between hole and outer polygon
    Node* findHoleBridge(Node* hole, Node* outerNode) {
        Node* p = outerNode;
        double hx = hole.x;
        double hy = hole.y;
        double qx = -double.max;
        Node* m = null;

        // find a segment intersected by a ray from the hole's leftmost Vertex to the left;
        // segment's endpoint with lesser x will be potential connection Vertex
        do {
            if (hy <= p.y && hy >= p.next.y && p.next.y != p.y) {
            double x = p.x + (hy - p.y) * (p.next.x - p.x) / (p.next.y - p.y);
            if (x <= hx && x > qx) {
                qx = x;
                if (x == hx) {
                    if (hy == p.y) return p;
                    if (hy == p.next.y) return p.next;
                }
                m = p.x < p.next.x ? p : p.next;
            }
            }
            p = p.next;
        } while (p != outerNode);

        if (!m) return null;

        if (hx == qx) return m; // hole touches outer segment; pick leftmost endpoint

        // look for points inside the triangle of hole Vertex, segment intersection and endpoint;
        // if there are no points found, we have a valid connection;
        // otherwise choose the Vertex of the minimum angle with the ray as connection Vertex

        Node* stop = m;
        double tanMin = double.max;
        double tanCur = 0;

        p = m;
        double mx = m.x;
        double my = m.y;

        do {
            if (hx >= p.x && p.x >= mx && hx != p.x &&
                pointInTriangle(hy < my ? hx : qx, hy, mx, my, hy < my ? qx : hx, hy, p.x, p.y)) {

                tanCur = fabs(hy - p.y) / (hx - p.x); // tangential

                if (locallyInside(p, hole) &&
                    (tanCur < tanMin || (tanCur == tanMin && (p.x > m.x || sectorContainsSector(m, p))))) {
                    m = p;
                    tanMin = tanCur;
                }
            }

            p = p.next;
        } while (p != stop);

        return m;
    }

    bool sectorContainsSector(Node* m, Node* p) {
        return area(m.prev, m, p.prev) < 0 && area(p.next, m, m.next) < 0;
    }

    void indexCurve(Node* start) {
        assert(start);
        Node* p = start;

        do {
            p.z = p.z ? p.z : zOrder(p.x, p.y);
            p.prevZ = p.prev;
            p.nextZ = p.next;
            p = p.next;
        } while (p != start);

        p.prevZ.nextZ = null;
        p.prevZ = null;

        sortLinked(p);
    }

    Node* sortLinked(Node* list) {
        assert(list);
        Node* p;
        Node* q;
        Node* e;
        Node* tail;
        int i, numMerges, pSize, qSize;
        int inSize = 1;

        for (;;) {
            p = list;
            list = null;
            tail = null;
            numMerges = 0;

            while (p) {
                numMerges++;
                q = p;
                pSize = 0;
                for (i = 0; i < inSize; i++) {
                    pSize++;
                    q = q.nextZ;
                    if (!q) break;
                }

                qSize = inSize;

                while (pSize > 0 || (qSize > 0 && q)) {

                    if (pSize == 0) {
                        e = q;
                        q = q.nextZ;
                        qSize--;
                    } else if (qSize == 0 || !q) {
                        e = p;
                        p = p.nextZ;
                        pSize--;
                    } else if (p.z <= q.z) {
                        e = p;
                        p = p.nextZ;
                        pSize--;
                    } else {
                        e = q;
                        q = q.nextZ;
                        qSize--;
                    }

                    if (tail) tail.nextZ = e;
                    else list = e;

                    e.prevZ = tail;
                    tail = e;
                }

                p = q;
            }

            tail.nextZ = null;

            if (numMerges <= 1) return list;

            inSize *= 2;
        }
    }

    int32_t zOrder(const double x_, const double y_) {
        // coords are transformed into non-negative 15-bit integer range
        int32_t x = cast(int32_t)(32767.0 * (x_ - minX) * inv_size);
        int32_t y = cast(int32_t)(32767.0 * (y_ - minY) * inv_size);

        x = (x | (x << 8)) & 0x00FF00FF;
        x = (x | (x << 4)) & 0x0F0F0F0F;
        x = (x | (x << 2)) & 0x33333333;
        x = (x | (x << 1)) & 0x55555555;

        y = (y | (y << 8)) & 0x00FF00FF;
        y = (y | (y << 4)) & 0x0F0F0F0F;
        y = (y | (y << 2)) & 0x33333333;
        y = (y | (y << 1)) & 0x55555555;

        return x | (y << 1);
    }
    
    Node* getLeftmost(Node* start) {
        Node* p = start;
        Node* leftmost = start;
        do {
            if (p.x < leftmost.x || (p.x == leftmost.x && p.y < leftmost.y))
                leftmost = p;
            p = p.next;
        } while (p != start);

        return leftmost;
    }
    
    bool pointInTriangle(double ax, double ay, double bx, double by, double cx, double cy, double px, double py) const {
        return (cx - px) * (ay - py) - (ax - px) * (cy - py) >= 0 &&
            (ax - px) * (by - py) - (bx - px) * (ay - py) >= 0 &&
            (bx - px) * (cy - py) - (cx - px) * (by - py) >= 0;
    }

    bool isValidDiagonal(Node* a, Node* b) {
        return a.next.i != b.i && a.prev.i != b.i && !intersectsPolygon(a, b) && // dones't intersect other edges
            ((locallyInside(a, b) && locallyInside(b, a) && middleInside(a, b) && // locally visible
                (area(a.prev, a, b.prev) != 0.0 || area(a, b.prev, b) != 0.0)) || // does not create opposite-facing sectors
                (equals(a, b) && area(a.prev, a, a.next) > 0 && area(b.prev, b, b.next) > 0)); // special zero-length case
    }

    double area(Node* p, Node* q, Node* r) const {
        return (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
    }

    bool equals(Node* p1, Node* p2) {
        return p1.x == p2.x && p1.y == p2.y;
    }

    bool intersects(Node* p1, Node* q1, Node* p2, Node* q2) {
        int o1 = sign(area(p1, q1, p2));
        int o2 = sign(area(p1, q1, q2));
        int o3 = sign(area(p2, q2, p1));
        int o4 = sign(area(p2, q2, q1));

        if (o1 != o2 && o3 != o4) return true; // general case

        if (o1 == 0 && onSegment(p1, p2, q1)) return true; // p1, q1 and p2 are collinear and p2 lies on p1q1
        if (o2 == 0 && onSegment(p1, q2, q1)) return true; // p1, q1 and q2 are collinear and q2 lies on p1q1
        if (o3 == 0 && onSegment(p2, p1, q2)) return true; // p2, q2 and p1 are collinear and p1 lies on p2q2
        if (o4 == 0 && onSegment(p2, q1, q2)) return true; // p2, q2 and q1 are collinear and q1 lies on p2q2

        return false;
    }

    bool onSegment(Node* p, Node* q, Node* r) {
        return q.x <= max(p.x, r.x) &&
            q.x >= min(p.x, r.x) &&
            q.y <= max(p.y, r.y) &&
            q.y >= min(p.y, r.y);
    }

    int sign(double val) {
        return (0.0 < val) - (val < 0.0);
    }

    bool intersectsPolygon(Node* a, Node* b) {
        Node* p = a;
        do {
            if (p.i != a.i && p.next.i != a.i && p.i != b.i && p.next.i != b.i &&
                    intersects(p, p.next, a, b)) return true;
            p = p.next;
        } while (p != a);

        return false;
    }

    bool locallyInside(Node* a, Node* b) {
        return area(a.prev, a, a.next) < 0 ?
            area(a, b, a.next) >= 0 && area(a, a.prev, b) >= 0 :
            area(a, b, a.prev) < 0 || area(a, a.next, b) < 0;
    }

    bool middleInside(Node* a, Node* b) {
        Node* p = a;
        bool inside = false;
        double px = (a.x + b.x) / 2;
        double py = (a.y + b.y) / 2;
        do {
            if (((p.y > py) != (p.next.y > py)) && p.next.y != p.y &&
                    (px < (p.next.x - p.x) * (py - p.y) / (p.next.y - p.y) + p.x))
                inside = !inside;
            p = p.next;
        } while (p != a);

        return inside;
    }
    
    Node* splitPolygon(Node* a, Node* b) {
        Node* a2 = nodes.construct(a.i, a.x, a.y);
        Node* b2 = nodes.construct(b.i, b.x, b.y);
        Node* an = a.next;
        Node* bp = b.prev;

        a.next = b;
        b.prev = a;

        a2.next = an;
        an.prev = a2;

        b2.next = a2;
        a2.prev = b2;

        bp.next = b2;
        b2.prev = bp;

        return b2;
    }

    Node* insertNode(size_t i, ref Point pt, Node* last) {
        Node* p = nodes.construct(cast(N)i, pt[0], pt[1]);

        if (!last) {
            p.prev = p;
            p.next = p;

        } else {
            assert(last);
            p.next = last.next;
            p.prev = last;
            last.next.prev = p;
            last.next = p;
        }
        return p;
    }

    void removeNode(Node* p) {
        p.next.prev = p.prev;
        p.prev.next = p.next;

        if (p.prevZ) p.prevZ.nextZ = p.nextZ;
        if (p.nextZ) p.nextZ.prevZ = p.prevZ;
    }

}

// those are optional. You can just use Tuple!(int, int)
struct Pair(T){
    T x;
    T y;
    @nogc nothrow:
    inout(T) opIndex(size_t index) inout {
        T[2] tmp = [x, y];
        return tmp[index];
    }

    void opIndexAssign(T)(T value, size_t index){
        T*[2] tmp = [&x, &y];
        *tmp[i] = value;
    }
}

struct Pair2(T){
    T[2] coord;

    alias coord this;

    this(T x, T y,){
        coord[0] = x;
        coord[1] = y;
    }
}