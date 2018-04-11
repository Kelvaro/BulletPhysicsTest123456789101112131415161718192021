//
//  BulletPhysics.h
//  BulletTest
//
//  Created by Borna Noureddin on 2015-03-20.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "btBulletDynamicsCommon.h"

@interface BulletPhysics: NSObject
@property btVector3 sphereTransform;
@property btVector3 cubeTransform;
@property btVector3 cameraTransform;

-(void)Update:(float)elapsedTime;
-(void)UpdateCamera:(float)x _y:(float)y _z:(float) z;
-(void)ApplyForce;

@end
