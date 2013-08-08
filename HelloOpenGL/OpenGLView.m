//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by zhanghaiwei on 13-8-7.
//  Copyright (c) 2013年 zhanghaiwei. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)setupLayer{
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if(!_context)
    {
        NSLog(@"Failed to initialize OpenGLES2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to setCurrent context");
        exit(1);
    }
}

- (void)setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)render{
    glClearColor(0, 144.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self render];
        
    }
    return self;
}

- (GLuint)compileShader:(NSString*) shaderName withType:(GLenum)shaderType{
    
    NSString* shaderpath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderpath encoding:NSUTF8StringEncoding error:&error];
    if (! shaderString) {
        NSLog(@"Error load shader %@", shaderName);
        exit(1);
    }
    //create shader handler
    GLuint shaderHandler = glCreateShader(shaderType);
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    //add shader source
    glShaderSource(shaderHandler, 1, &shaderStringUTF8, &shaderStringLength);
    //compile shader
    glCompileShader(shaderHandler);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar msg[256];
        glGetShaderInfoLog(shaderHandler, sizeof(msg), 0 , msg);
        NSLog(@"%s", msg);
        exit(1);
    }
    return shaderHandler;
}

- (void)compileShaders{
    
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandler = glCreateProgram();
    glAttachShader(programHandler, vertexShader);
    glAttachShader(programHandler, fragmentShader);
    glLinkProgram(programHandler);
    
    GLint linkSuccess;
    glGetProgramiv(programHandler,GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        char msg[256];
        glGetProgramInfoLog(programHandler, sizeof(msg), 0, msg);
        NSLog(@"%s", msg);
        exit(1);
    }
    
    glUseProgram(programHandler);
    
    _positionSlot = glGetAttribLocation(programHandler, "Position");
    _colorSlot = glGetAttribLocation(programHandler, "SourceColor");
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)dealloc{
    [_context release];
    _context = nil;
    [super dealloc];
}
@end
