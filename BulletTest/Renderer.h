
#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#include "ShaderLoader.h"

@interface Renderer : GLKViewController 

@property bool _spotlightToggle;
@property bool _fogToggle;
@property bool _fogUseExp;
@property bool _isDay;


- (void)setup:(GLKView *)view;
- (void)setupShaders;
- (void)update;
- (void)reset;
- (void)rotateCamera:(float)xDelta secondDelta:(float)zDelta;
- (void)translateCameraForward:(float)xDelta secondDelta:(float)zDelta;
- (void)draw:(CGRect)drawRect;
- (void)ApplyForce;

@end

#endif /* Renderer_h */
