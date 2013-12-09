//
//  EAGLView.m
//  OpenGL
//
//  Created by sangjo_itwill on 2013. 12. 6..
//  Copyright (c) 2013년 sj. All rights reserved.
//

#import "EAGLView.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

@implementation EAGLView

@synthesize context, animationTimer;

+(Class)layerClass
{
    return [CAEAGLLayer class];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*)self.layer;          //레이어 생성
        
        eaglLayer.opaque = YES;                                     //투명 레이어
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
        
        rota = 0.0;

        [self setupView];
        
        poly = [Polygon alloc];
        [poly init_x:0.0 y:0.0 z:0.0 w:1.0 h:1.0];
        [poly loadTexture:@"checkerplate.png"];
        
        fly = [Polygon alloc];
        [fly init_x:0.0 y:0.0 z:0.0 w:1.0 h:1.0];
        [fly loadTexture:@"fly.png"];
        
        ground = [Polygon alloc];
        [ground init_x:0.0 y:0.0 z:0.0 w:100 h:100];
        [ground loadTexture:@"floor.png"];
        
        
        currentMovement = MT_None;
        
        //camera pos
        
        eye[0] = 0.0;
        eye[1] = 2.0;
        eye[2] = 4.0;
        
        //see pos
        center[0] = center[1] = center[2] = 0.0;
        
        bUpDown = 1.0;
        
        
    }
    return self;
}

-(void)startAnimation
{
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval
                                                      target:self
                                                    selector:@selector(drawView)
                                                    userInfo:nil
                                                     repeats:YES];
    
}

-(void)stopAnimation
{
    animationTimer = nil;
    
}

- (void)setAnimationTimer:(NSTimer *)newTimer
{
    [animationTimer invalidate];
    
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)animationInterval
{
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)checkGLError:(BOOL)visibleCheck {           //error message
    GLenum error = glGetError();
    
    switch (error) {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        case GL_NO_ERROR:
            if (visibleCheck) {
                NSLog(@"No GL Error");
            }
            break;
        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}


-(void)drawView
{
    
    
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    glViewport(0, 0, backingWidth, backingHeight);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    

    // Drawing

    glLoadIdentity();

    
    [self handleTouches];
    
    gluLookAt(eye[0], eye[1], eye[2],
              center[0], center[1], center[2],
              0.0, 1.0, 0.0);
 
 
    //checkerplate
    glPushMatrix();
    {
        rota += 1.0;
        
        [poly move_x:-1.0 y:0.0 z:-3.0];
        [poly rotate_angle:0.0 x:0.0 y:1.0 z:0.0];
        [poly scale_x:1.0 y:1.0];

        [poly setColor_red:1.0 green:1.0 blue:1.0];
        
        [poly drawPolygon];
    }
    glPopMatrix();
  

    //fly
    glPushMatrix();
    {
        GLfloat mat[16];
        
        
        
        rota += 1.0;
        
        [fly move_x:1.0 y:0.0 z:-3.0];
        [fly rotate_angle:0.0 x:0.0 y:0.0 z:1.0];
        [fly scale_x:1.0 y:1.0];
        
        [fly setColor_red:1.0 green:1.0 blue:1.0];

        glGetFloatv(GL_MODELVIEW_MATRIX, mat);
        

        /*
         mat[0], mat[1], mat[2], mat[3],
         mat[4], mat[5], mat[6], mat[7],
         mat[8], mat[9], mat[10], mat[11],
         mat[12], mat[13], mat[14], mat[15],
         
         1  0   0   --
         0  1   0   --
         0  0   1   --
         -- --  --
         
         */

        mat[0] = mat[5] = mat[10] = 1.0;
        
        mat[1] = mat[2] = mat[4] = mat[6] = mat[8] = mat[9] = 0.0;
        
        glLoadMatrixf(mat);
        
        GLfloat m[16], l;
        
        glGetFloatv(GL_MODELVIEW_MATRIX, m);
        
        // Z축
        m[8] = -m[12];
        m[9] = -m[13];
        m[10] = -m[14];
        
        l = sqrt(m[8] * m[8] + m[9] * m[9] + m[10] * m[10]);
        
        m[8] /= l;
        m[9] /= l;
        m[10] /= l;
        
        // X축
        m[0] = -m[14];
        m[1] = 0.0;
        m[2] = m[12];
        
        l = sqrt(m[0] * m[0] + m[1] * m[1] + m[2] * m[2]);
        
        m[0] /= l;
        m[1] /= l;
        m[2] /= l;
        
        m[4] = m[9] * m[2] - m[10] * m[1];
        m[5] = m[10] * m[0] - m[8] * m[2];
        m[6] = m[8] * m[1] - m[9] * m[0];
        
        glLoadMatrixf(m);
        
        
        //        glEnable(GL_BLEND);
        //        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        //        glColor4f(1.0, 1.0, 1.0, 0.5);
        
        [fly drawPolygon];
        
        //        glDisable(GL_BLEND);
    }
    glPopMatrix();
  
    //ground
    glPushMatrix();
    {
        [ground move_x:0.0 y:-3.0 z:0.0];
        [ground rotate_angle:90.0 x:1.0 y:0.0 z:0.0];
        [ground scale_x:10.0 y:10.0];
        
        [ground setColor_red:1.0 green:1.0 blue:1.0];
        
        [ground drawPolygon];
    }
    glPopMatrix();
    
    /*
    GLfloat squareVerts[] = {
        -1.0, 1.0, 0.0,
        -1.0, -1.0,  0.0,
        1.0, 1.0,  0.0,
        1.0, -1.0,  0.0,
    };
    //    x,   y,   z,
    
    GLfloat squareColors[] = {
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.5, 0.5, 0.5, 1.0,
    };
    
    GLshort squareTextureCods[] = { // UV 좌표
        0, 1,
        0, 0,
        1, 1,
        1, 0,
    };
    
    glMatrixMode(GL_MODELVIEW);
    
    rota += 1.0;
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glVertexPointer(3, GL_FLOAT, 0, squareVerts);
    glColorPointer(4, GL_FLOAT, 0, squareColors);
    
    glTexCoordPointer(2, GL_SHORT, 0, squareTextureCods);
    
    glPushMatrix();
    {
        // transform (move, rotation, scale)
        // move
        glTranslatef(0.0, 0.0, -5.0);
        
        //rotation
        glRotatef(rota, 0.0, 1.0, 0.0);
        
        // scale
        glEnable(GL_TEXTURE_2D);
        
        glScalef(1.0, 1.0, 1.0);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
        
//        glShadeModel(GL_SMOOTH);            //default
        glShadeModel(GL_FLAT);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        glDisable(GL_TEXTURE_2D);
        
    }
    glPopMatrix();
    
    */
     
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES,
                          viewRenderbuffer);
    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    [self checkGLError:NO];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [[touches allObjects]objectAtIndex:0];
    
    CGPoint touchPos = [t locationInView:t.view];
    
    if (touchPos.y < 160) {  //up == go
        
        currentMovement = MT_WalkForword;
        
    }
    else if(touchPos.y > 320){  //down == back

        currentMovement = MT_WalkBackword;
        
    }
    else if(touchPos.x < 160){  //left == rotation
        
        currentMovement = MT_TurnLeft;
        
    }
    
    else{                       //right
        
        currentMovement = MT_TurnRight;
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentMovement = MT_None;
}

-(void)handleTouches{

    GLfloat vector[3];
    
    
    vector[0] = center[0] - eye[0];
    vector[1] = center[1] - eye[1];
    vector[2] = center[2] - eye[2];
    
    switch (currentMovement) {

        case MT_None:
            return;
            break;
            
        case MT_WalkForword:
            
            eye[0] += vector[0] * WALK_SPEED;
            eye[2] += vector[2] * WALK_SPEED;
            
            center[0] += vector[0] * WALK_SPEED;
            center[2] += vector[2] * WALK_SPEED;

            break;
            
        case MT_WalkBackword:
            
            eye[0] -= vector[0] * WALK_SPEED;
            eye[2] -= vector[2] * WALK_SPEED;
            
            center[0] -= vector[0] * WALK_SPEED;
            center[2] -= vector[2] * WALK_SPEED;

            break;
            
        case MT_TurnLeft:
            
            center[0] = eye[0] + cos(-TURN_SPEED) * vector[0]
            - sin(-TURN_SPEED) * vector[2];
            center[2] = eye[2] + sin(-TURN_SPEED) * vector[0]
            + cos(-TURN_SPEED) * vector[2];
            
            break;
            
        case MT_TurnRight:
            
            center[0] = eye[0] + cos(TURN_SPEED) * vector[0]
            - sin(TURN_SPEED) * vector[2];
            center[2] = eye[2] + sin(TURN_SPEED) * vector[0]
            + cos(TURN_SPEED) * vector[2];
            
            break;
    
    }
    
    
}

static void nomalize(float v[3])        //vector -> 0 || 1
{
    float r;
    
    r = sqrtf(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (r == 0.0) {
        return;
    }
    
    v[0] /= r;
    v[1] /= r;
    v[2] /= r;

}

static void gluMakeIdentity(GLfloat m[16])      // matrix
{
    m[0 + 4 * 0] = 1;    m[0 + 4 * 1] = 0;    m[0 + 4 * 2] = 0;    m[0 + 4 * 3] = 0;
    m[1 + 4 * 0] = 0;    m[1 + 4 * 1] = 1;    m[1 + 4 * 2] = 0;    m[1 + 4 * 3] = 0;
    m[2 + 4 * 0] = 0;    m[2 + 4 * 1] = 0;    m[2 + 4 * 2] = 1;    m[2 + 4 * 3] = 0;
    m[3 + 4 * 0] = 0;    m[3 + 4 * 1] = 0;    m[3 + 4 * 2] = 0;    m[3 + 4 * 3] = 1;

}

static void cross(float v1[3], float v2[3], float result[3])    // result[] == 외적
{
    result[0] = v1[1] * v2[2] - v1[2] * v2[1];
    result[1] = v1[2] * v2[0] - v1[0] * v2[2];
    result[2] = v1[0] * v2[1] - v1[1] * v2[0];
}


void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
			   GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
			   GLfloat upz)
{
    float forward[3], side[3], up[3];
    GLfloat m[4][4];
	
    forward[0] = centerx - eyex;
    forward[1] = centery - eyey;
    forward[2] = centerz - eyez;
	
    up[0] = upx;
    up[1] = upy;
    up[2] = upz;
	
    nomalize(forward);
	
    /* Side = forward x up */
    cross(forward, up, side);
    nomalize(side);
	
    /* Recompute up as: up = side x forward */
    cross(side, forward, up);
	
    gluMakeIdentity(&m[0][0]);
    m[0][0] = side[0];
    m[1][0] = side[1];
    m[2][0] = side[2];
	
    m[0][1] = up[0];
    m[1][1] = up[1];
    m[2][1] = up[2];
	
    m[0][2] = -forward[0];
    m[1][2] = -forward[1];
    m[2][2] = -forward[2];
	
    glMultMatrixf(&m[0][0]);
    glTranslatef(-eyex, -eyey, -eyez);
}



-(void)layoutSubviews                   //frame buffer create
{
    [EAGLContext setCurrentContext:context];
    
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

-(void)setupView                        //camera, projection setting
{
    GLfloat zNear = 0.1;                //보이기 시작하는 위치
    GLfloat zFar = 1000.0;              //어디까지 보이는지
    GLfloat fieldOfView = 60.0;         //camera angle
    GLfloat size;
    
    glEnable(GL_DEPTH_TEST);
    
    glMatrixMode(GL_PROJECTION);        //world, projection
    
    size = zNear *tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    
    CGRect rect = self.bounds;
    
    glFrustumf(-size, size,
               -size / (rect.size.width / rect.size.height),
               size /(rect.size.width / rect.size.height),
               zNear, zFar);
    
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
  
}



- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

-(void)loadTexture:(NSString*)textureName
{
    CGImageRef textureImage = [UIImage imageNamed:textureName].CGImage;

    if (textureImage == nil) {
        NSLog(@"image load fail");
    }
    
    NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
                                                        texWidth, texHeight,
                                                        8, texWidth * 4,
                                                        CGImageGetColorSpace(textureImage),
                                                        (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
    
    
    
    
    
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}











@end