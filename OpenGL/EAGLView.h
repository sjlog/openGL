//
//  EAGLView.h
//  OpenGL
//
//  Created by sangjo_itwill on 2013. 12. 6..
//  Copyright (c) 2013년 sj. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Polygon.h"



#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

#define WALK_SPEED 0.005
#define TURN_SPEED 0.01

typedef enum _MOVEMENT_TYPE
{
    MT_None,
    MT_WalkForword,
    MT_WalkBackword,
    MT_TurnLeft,
    MT_TurnRight,
}MovementType;


@interface EAGLView : UIView
{
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLuint depthRenderbuffer;
    
    __weak NSTimer *animationTimer;
    
    NSTimeInterval animationInterval;

    GLfloat rota;
    
    Polygon *poly, *fly;
    
    Polygon *ground;
    
    MovementType currentMovement;
    
    float bUpDown;
    GLfloat eye[3], center[3];
    
    
    GLuint texture;
}

//@property NSTimeInterval animationInterval;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, weak) NSTimer *animationTimer;

-(void)loadTexture:(NSString*)textureName;

-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;

-(void)setupView;
-(void)checkGLError:(BOOL)visibleCheck;

-(void)handleTouches; //터치된 순간부터 계속 호출될 method

@end

@interface EAGLView (buffer)

-(BOOL)createFramebuffer;
-(void)destroyFramebuffer;


@end