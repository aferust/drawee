module msgnode;

import globals;
import tween;

struct MsgNode {

    Point pos;

    bool visible;

    string message;
}

@nogc nothrow:

void openCerenomy(){

    enum act1 = () @nogc nothrow {
        msgNode.message = "Get ready!";
        msgNode.visible = true;
        pause = true;
    };

    enum act2 = () @nogc nothrow {
        msgNode.visible = false;
        pause = false;
    };

    auto first = makeAction(act1, 0);
    first.started = true;
    auto last = makeAction(act2, 3000);

    sceneActions ~= first;
    sceneActions ~= last;

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