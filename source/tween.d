module tween;

import core.stdc.math;

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
    float afterNMS;
    private int ticks;

    @disable this();
    
    @nogc nothrow:
    
    this(P start, P end, int steps){ // a linear point traveller at given steps
        this.steps = steps;
        this.start = start;
        this.end = end;
        current = start;
    }

    this(void function() @nogc nothrow runaction, float afterNMS = 0f){ // a function scheduler
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

        if(ticks < 15){
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

void proceedActions(int dt) {
    if(actions.length && actions[actions.length-1].done)
        actions.free;
    else {
        foreach(i; 0..actions.length){
            if(!actions[i].done && actions[i].started) {
                actions[i].update(dt);
                if(actions[i].runaction is null) hero.pos = actions[i].current;
                if(actions[i].done && actions.length > i+1)
                    actions[i+1].started = true;
            }
        }
    }
}