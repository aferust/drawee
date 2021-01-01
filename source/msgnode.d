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

    enum switchMsg = () @nogc nothrow {
        msgNode.visible = !msgNode.visible;
        pause = !pause;
    };

    auto first = makeAction(switchMsg, 0);
    first.started = true;
    auto last = makeAction(switchMsg, 3000);

    sceneActions ~= first;
    sceneActions ~= last;

}