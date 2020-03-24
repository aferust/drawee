module boilerplate;

import core.stdc.stdio;

import bindbc.sdl;
import bindbc.opengl;

import globals;

@nogc nothrow:

void logSDLError(string msg) nothrow @nogc{
	printf("%s: %s \n", msg.ptr, SDL_GetError());
}

int initSDL(){
    version(BindSDL_Static){
    	 // todo: some stuff
    }else{
    	SDLSupport ret = loadSDL();
        if(ret == SDLSupport.noLibrary){
            printf("noLibrary \n".ptr);
            return 1;
        }

    }
    //Use OpenGL 3.1 core
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 );
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
    
    if (SDL_Init(SDL_INIT_VIDEO) != 0){
        logSDLError("SDL_Init Error: ");
        return 1;
    }
    
    return 0;
}

int createCtx(){
    window = SDL_CreateWindow(
        "SDL2/OpenGL Demo", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, 
        SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);
    
    glcontext = SDL_GL_CreateContext(window);
    return 0;
}

int initGL(){
    
    createCtx();
    //openGLContextVersion.writeln;

    GLSupport retVal = loadOpenGL();
    if(retVal == GLSupport.gl41) {
        printf("configure renderer for OpenGL 4.1 \n".ptr);
    }
    else if(retVal == GLSupport.gl32) {
        printf("configure renderer for OpenGL 3.2 \n".ptr);
    }
    else {
        // Error
    }
    
    //writeln(retVal);
    return 0;
}