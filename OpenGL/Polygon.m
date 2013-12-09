//
//  Polygon.m
//  OpenGL
//
//  Created by sangjo_itwill on 2013. 12. 6..
//  Copyright (c) 2013년 sj. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "Polygon.h"

@implementation Polygon

-(void)init_x:(float)x y:(float)y z:(float)z w:(float)w h:(float)h
{
    float tempW = w / 2.0;
    float tempH = h / 2.0;
    
    //polygon pos
    GLfloat _poly[] = {
        x - tempW, y + tempH, z,
        x + tempW, y + tempH, z,
        x + tempW, y - tempH, z,
        x - tempW, y - tempH, z,
    };
    
    for (int i = 0 ; i < 12; i++) {
        Vertexes[i] = _poly[i];
    }
    
    //texture pos
    GLshort _tex[] = {
        0, 1,
        1, 1,
        1, 0,
        0, 0,
    };
    
    for (int i=0; i<8; i++) {
        textureVert[i] = _tex[i];
    }
    
    glVertexPointer(3, GL_FLOAT, 0, Vertexes);
    glTexCoordPointer(2, GL_SHORT, 0, textureVert);
    
    posX = x;
    posY = y;
    posZ = z;
}


//transform
-(void)move_x:(float)x y:(float)y z:(float)z
{
    posX = x;
    posY = y;
    posZ = z;
    
    glTranslatef(posX, posY, posZ);
    
}
-(void)rotate_angle:(float)angle x:(float)x y:(float)y z:(float)z
{
    glRotatef(angle, x, y, z);
}
-(void)scale_x:(float)x y:(float)y
{
    glScalef(x, y, 1.0);
}

-(void)setColor_red:(float)r green:(float)g blue:(float)b
{
    _color[0] = r;
    _color[1] = g;
    _color[2] = b;
    _color[3] = 1.0;
}

-(void)drawPolygon
{
//    glEnable(GL_CULL_FACE);         //반대쪽 면을 그리지 않음
    
    glColor4f(_color[0], _color[1], _color[2], 1.0);
    glVertexPointer(3, GL_FLOAT, 0, Vertexes);
    glTexCoordPointer(2, GL_SHORT, 0, textureVert);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glEnable(GL_TEXTURE_2D);

    glBindTexture(GL_TEXTURE_2D, texture);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    
//    glDisable(GL_CULL_FACE);
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
	glEnable(GL_TEXTURE_2D);
}



@end
