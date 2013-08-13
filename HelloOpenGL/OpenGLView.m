//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by zhanghaiwei on 13-8-7.
//  Copyright (c) 2013年 zhanghaiwei. All rights reserved.
//

#import "OpenGLView.h"
#include "CC3GLMatrix.h"

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

#define TEX_COORD_MAX   4

const Vertex Vertices[] = {
    // Front
    {{1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Back
    {{1, 1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, -1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, -1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 0, 1}, {0, 0}},
    // Left
    {{-1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}},
    // Right
    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Top
    {{1, 1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Bottom
    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, -1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

const Vertex Vertices2[] = {
    {{0.5, -0.5, 0.01}, {1, 1, 1, 1}, {1, 1}},
    {{0.5, 0.5, 0.01}, {1, 1, 1, 1}, {1, 0}},
    {{-0.5, 0.5, 0.01}, {1, 1, 1, 1}, {0, 0}},
    {{-0.5, -0.5, 0.01}, {1, 1, 1, 1}, {0, 1}},
};

const GLubyte Indices2[] = {
    1, 0, 2, 3
};

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
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)render: (CADisplayLink*)displayLink {
    glClearColor(0, 144.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
   
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    
    CC3GLMatrix *modelview = [CC3GLMatrix matrix];
    [modelview populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    _currentRotation += displayLink.duration * 90;
    [modelview rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];
    
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelview.glMatrix);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float)*3));
    
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _floorTexture);
    glUniform1i(_textureUniform, 0);
    
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/(sizeof(Indices[0])), GL_UNSIGNED_BYTE, 0);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer2);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _fishTexture);
    glUniform1i(_textureUniform, 0);
    
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelview.glMatrix);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices2)/sizeof(Indices2[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        
        _floorTexture = [self setupTexture:@"tile_floor.png"];
        _fishTexture = [self setupTexture:@"item_powerup_fish.png"];
        
        //[self render];
        [self setupDisplayLink];
        
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
    
    _projectionUniform = glGetUniformLocation(programHandler, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandler, "Modelview");
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    _texCoordSlot = glGetAttribLocation(programHandler, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _textureUniform = glGetUniformLocation(programHandler, "Texture");
}

- (void)setupVBOs{
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_vertexBuffer2);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices2), Vertices2, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer2);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer2);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices2), Indices2, GL_STATIC_DRAW);
}

- (void)setupDisplayLink {
    
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)setupDepthBuffer{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    
}

- (GLuint)setupTexture:(NSString*) fileName{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (! spriteImage) {
        NSLog(@"failed to load image %@", spriteImage);
        exit(1);
    }
    size_t width = CGImageGetWidth(spriteImage);
    size_t height =CGImageGetHeight(spriteImage);   
    
    GLubyte *spriteData = (GLubyte*)calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return texName;
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
