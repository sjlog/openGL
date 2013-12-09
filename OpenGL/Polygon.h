//
//  Polygon.h
//  OpenGL
//
//  Created by sangjo_itwill on 2013. 12. 6..
//  Copyright (c) 2013년 sj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Polygon : NSObject
{
    float posX, posY, posZ;
 
    GLfloat Vertexes[12];
    GLshort textureVert[8];
    GLfloat _color[4];
    
    GLuint texture;
    
}

-(void)init_x:(float)x y:(float)y z:(float)z w:(float)w h:(float)h;


//transform
-(void)move_x:(float)x y:(float)y z:(float)z;
-(void)rotate_angle:(float)angle x:(float)x y:(float)y z:(float)z;
-(void)scale_x:(float)x y:(float)y;

-(void)setColor_red:(float)r green:(float)g blue:(float)b;

-(void)drawPolygon;

-(void)loadTexture:(NSString*)textureName;

@end
