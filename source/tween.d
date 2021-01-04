module tween;

version(WebAssembly){
    import clib;
}else{
    import core.stdc.math;
}

import std.traits;

import globals;

/+
An action can be either of a function scheduler or a linear point traveller at given steps
depending on constructor used.
+/

struct Action(P) {
    
    int steps;
    P start;
    P end;
    P current;
    int counter;
    bool started = false;
    bool done = false;

    @nogc nothrow void function() runaction;
    int afterNMS;
    private int ticks;

    @disable this();
    
    @nogc nothrow:
    
    this(P start, P end, int steps){ // a linear point traveller at given steps
        this.steps = steps;
        this.start = start;
        this.end = end;
        current = start;
    }

    this(void function() @nogc nothrow runaction, int afterNMS = 0){ // a function scheduler
        this.afterNMS = afterNMS;
        this.runaction = runaction;
    }

    float distance(){
        return sqrtf(powf(start.x - end.x, 2) + powf(start.y - end.y, 2));
    }

    void update(int dt){
        if(!started)
            return;
        if(runaction !is null){
            if(ticks <= afterNMS){
                ticks += dt;
                return;
            }
            ticks = 0;

            runaction();
            
            done = true;
            return;
        }

        enum traceDelayer = 15;

        if(ticks < traceDelayer){
            ticks += dt;
            return;
        }
        ticks = 0;

        double step = distance / steps;

        double n = (step * counter++);
        
        current = P(
            cast(int)(start.x + (end.x - start.x)*n/distance),
            cast(int)(start.y + (end.y - start.y)*n/distance)
        );
        
        if(counter == steps){
            current = end;
            done = true;
        }
    }
}

@nogc nothrow:

auto makeAction(P = Point, Args...)(Args args){
    static if(args.length)
        return Action!P(args);
}

void proceedActions(A)(ref A acts, int dt) {
    if(acts.length && acts[acts.length-1].done)
        acts.free;
    else {
        foreach(i; 0..acts.length){
            if(!acts[i].done && acts[i].started) {
                acts[i].update(dt);
                if(acts[i].runaction is null) hero.pos = acts[i].current;
                if(acts[i].done && acts.length > i+1)
                    acts[i+1].started = true;
            }
        }
    }
}