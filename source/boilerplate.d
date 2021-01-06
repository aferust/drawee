module boilerplate;

import core.stdc.stdio;

import bindbc.sdl;
import bindbc.sdl.ttf;
import bindbc.sdl.image;

version(WebAssembly){
    import opengl.gl4;
}else{
    import bindbc.opengl;
}

import globals;

version(WebAssembly){
    alias em_arg_callback_func = extern(C) void function(void*) @nogc nothrow;
    alias em_callback_func = extern(C) void function() @nogc nothrow;
    extern(C) void emscripten_set_main_loop_arg(em_arg_callback_func func, void *arg, int fps, int simulate_infinite_loop) @nogc nothrow;
    extern(C) void emscripten_set_main_loop(em_callback_func func, int fps, int simulate_infinite_loop) @nogc nothrow;
    extern(C) void emscripten_cancel_main_loop() @nogc nothrow;

    extern(C) @nogc nothrow:

    nothrow @nogc @trusted void __assert(const(char)* exp, const(char)* file, uint line){
        // I am not linking neither druntime nor phobos
        // this is for a linker error
    }

    void logError(size_t line = __LINE__)(){
        printf("%d:%s\n", line, SDL_GetError());
    }

    void initSDLandFriends(){
        SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
        SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 0 );
        SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
        if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_EVENTS) != 0) {
            logError();
        }

        SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE, 1 );

        TTF_Init();

        SDL_Renderer* renderer;

        SDL_CreateWindowAndRenderer(SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_OPENGL, &window, &renderer);

        glcontext = SDL_GL_CreateContext(window);
    }
    
}

@nogc nothrow:

int initSDLImage(){
    int flags = IMG_INIT_JPG | IMG_INIT_PNG;
    int initted = IMG_Init(flags);
    if((initted & flags) != flags) {
        printf("IMG_Init: Failed to init required jpg and png support!\n");
        printf("IMG_Init: %s\n", IMG_GetError());

        return -1;
    }

    return 0;
}

GLuint loadTexture(string path){
    SDL_Surface* texture = IMG_Load(path.ptr);

    uint COLOR_MODEL; 
    if(texture.format.BytesPerPixel == 3)
        COLOR_MODEL = GL_RGB;
    else if (texture.format.BytesPerPixel == 4)
        COLOR_MODEL = GL_RGBA;
    
    GLuint textureId;
    glGenTextures(1, &textureId); 
    glBindTexture(GL_TEXTURE_2D, textureId);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, COLOR_MODEL, texture.w, texture.h, 0, COLOR_MODEL, GL_UNSIGNED_BYTE, texture.pixels);
    glGenerateMipmap(GL_TEXTURE_2D);

    SDL_FreeSurface(texture);

    return textureId;
}

TTF_Font* getFontWithSize(string path, int size){
    return TTF_OpenFont(path.ptr, size);
}

FontSet initMemoryFontSet(TTF_Font* ttfFont, Color color){
    FontSet chartSet;
    foreach(char a; ' '..'~'){
        auto clr = SDL_Color(cast(ubyte)(color[0]*255), cast(ubyte)(color[1]*255),cast(ubyte)(color[2]*255));
        
        char[2] buff;
        sprintf(buff.ptr, "%c\0", a);
        
        SDL_Surface* texture = TTF_RenderUTF8_Blended(ttfFont, buff.ptr, clr);

        GLuint textureId;
        glGenTextures(1, &textureId); 
        glBindTexture(GL_TEXTURE_2D, textureId);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture.w, texture.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture.pixels);
        glGenerateMipmap(GL_TEXTURE_2D);

        chartSet[a] = FontInfo(textureId, texture.w, texture.h);

        SDL_FreeSurface(texture);
    }

    return chartSet;
}

version(WebAssembly){} else :

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
    
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 4 );
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 );
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
    
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
        logSDLError("SDL_Init Error: ");
        return 1;
    }
    
    SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE, 1 );
    
    return 0;
}

int initSDLTTF(){
    version(BindSDL_Static){}else{
    	if(loadSDLTTF() != sdlTTFSupport) {
            printf("SDL_TTF error!".ptr);
            return 1;
        }

    }
    TTF_Init();

    return 0;
}

int createCtx(){
    window = SDL_CreateWindow(
        "Drawee", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, 
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