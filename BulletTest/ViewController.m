//
//  ViewController.m
//  BulletTest
//
//  Created by Borna Noureddin on 2015-03-20.
//  Copyright (c) 2015 BCIT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    Renderer *myRenderer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //handles panning
    UIPanGestureRecognizer *panning =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panning];
    
    //Single tap handler
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    myRenderer = [[Renderer alloc] init];
    GLKView *view = (GLKView *)self.view;
    [myRenderer setup:view];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [myRenderer draw:rect];
}


- (void)update
{
    [myRenderer update];
}

//Camera transformations
- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint vel = [recognizer velocityInView:self.view];
    [myRenderer rotateCamera:vel.x secondDelta:vel.y];
    [myRenderer translateCameraForward:vel.x secondDelta:vel.y];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [myRenderer ApplyForce];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
