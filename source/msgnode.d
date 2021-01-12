module msgnode;

import globals;
import tween;

struct MsgNode {

    Point pos;

    bool visible;

    dstring message;
}

@nogc nothrow:

void openCeremony(){
    won = false;
    
    enum act1 = () @nogc nothrow {
        msgNode.message = "Get ready! 3";
        msgNode.visible = true;
        pause = true;
    };

    // todo: use a compile time loop
    enum act2 = () @nogc nothrow {
        msgNode.message = "Get ready! 2";
    };

    enum act3 = () @nogc nothrow {
        msgNode.message = "Get ready! 1";
    };

    enum act4 = () @nogc nothrow {
        msgNode.message = "Get ready! 0";
    };

    enum act5 = () @nogc nothrow {
        msgNode.visible = false;
        pause = false;
    };

    auto a1 = makeAction(act1, 0);
    a1.started = true;

    auto a2 = makeAction(act2, 1000);
    auto a3 = makeAction(act3, 1000);
    auto a4 = makeAction(act4, 1000);

    auto a5 = makeAction(act5, 1000);

    sceneActions ~= a1;
    sceneActions ~= a2;
    sceneActions ~= a3;
    sceneActions ~= a4;
    sceneActions ~= a5;

}

void youWon(){
    enum freeze = () @nogc nothrow {
        msgNode.message = "You won!";
        msgNode.visible = true;
        pause = true;

    };

    auto first = makeAction(freeze, 0);
    first.started = true;

    import app: resetGame;
    auto last = makeAction(&resetGame, 3000);

    sceneActions ~= first;
    sceneActions ~= last;

}