# A Volfied-like game
- My hobby game for own understanding.
- Work in progress!!!
- No engine used. Just SDL and OpenGL
- betterC
- implements some concepts from scratch.
- It uses [@skoppe's druntime fork](https://github.com/skoppe/druntime/tree/wasm) for webaasembly. Probably betterC is not a must now if I link druntime.

## Controls
- Use arrow keys to move the hero
- Start shrinking the polygon using SPACE + arrow keys
- use key P for pause and R for restart

- the game is playable [here](https://aferust.github.io/drawee/)

## WASM build with emscripten
- There is a postBuildCommands in dub.json compiling with emscripten.
- `dub build --config=wasm --compiler=ldc2 --build=release --build-mode=allAtOnce --combined --arch=wasm32-unknown-unknown-wasm -v`

![](demo.gif)