//
//  CustomGestureRecogniser.m
//  InteractionTest
//
//  Created by Sam Beedell on 08/05/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import "CustomGestureRecogniser.h"
#import "MotionManagerObject.h"

@interface CustomGestureRecogniser (private)

@end

@implementation CustomGestureRecogniser

@synthesize gestureData;

#pragma mark -
#pragma mark instance methods

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self != nil) {
        self.target = target;
        self.action = action;
        [self setup];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSLog(@"custom GR setup");
    gestureData = [NSMutableDictionary dictionary];
    self.state = UIGestureRecognizerStatePossible;
}

#pragma -
#pragma MotionManager methods

- (MotionManagerObject *)theMMDataObject {
    id<CMDelegateProtocol> theDelegate = (id<CMDelegateProtocol>) [UIApplication sharedApplication].delegate;
    MotionManagerObject* theDataObject = (MotionManagerObject*) theDelegate.theMMDataObject;
    return theDataObject;
}

- (void)startDeviceMotionUpdates
{
    // calculate device motion
    
    // End this method by calling the following recognition if a success
    self.state = UIGestureRecognizerStateRecognized;
}

#pragma -
#pragma UIGestureRecognizer subclass methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //Get the time of the touch
//    currentTime = [[NSDate date] timeIntervalSince1970];
    
//    NSLog(@"touch %d", self.view.tag);
    
    // Regular multitouch handling.
    [super touchesBegan:touches withEvent:event];
    
    // Enumerate over all the touches
    for (UITouch *touch in touches)
    {
        center = [touch locationInView:self.view]; 
        [gestureData setObject:[NSValue valueWithCGPoint:center] forKey:[[NSString alloc] initWithFormat:@"center%d",self.view.tag]];
        
        // radius of the users touch (finger tip) in mm
        // 12.8, 21.5, 38.3, 51, 63.8, 76.6, 89.3, 102.1, 114.9,
        CGFloat radius = [touch majorRadius]; // NEEDS NORMALISING (min=0,max=200)
        [gestureData setObject:[NSNumber numberWithFloat:radius] forKey:[[NSString alloc] initWithFormat:@"radius%d",self.view.tag]];
    }
    {
        
        // --------------------- testing purposes ---------------------
        //    self.imageView = nil;
        //    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle.png"]];
        //    [self.view addSubview:self.imageView];
        //    self.imageView.center = center;
        //
    }
    
    if (touches.count > 1) {
        self.state = UIGestureRecognizerStateFailed;
        NSLog(@"failed");
        return;
    }
    
    // PLAY NOTE
    [super setState:UIGestureRecognizerStateBegan];
    
    // Accurate pressure sensitivity = 0.1s of lag
    // if the pressure calculation happened here also, how could this affect the results?
//    currentPressureValueIndex = 0;
//    ready = YES;
    
    // Not so accurate sensitivity = 0.001s lag -> would work if the sensor data was updated on a different thread
    //    pressure = [[array valueForKeyPath:@"@max.self"] floatValue];
    
    

}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    // Enumerate over all the touches
    for (UITouch *touch in touches)
    {
        // deviation of the touch from the initial point (center)
        // make sure the movement starts at 0 so the deviation is from the center position of touch
        CGPoint movement = CGPointMake(0, 0);
        CGPoint initialPoint = [[gestureData objectForKey:[[NSString alloc] initWithFormat:@"center%d",self.view.tag]] CGPointValue];
        movement.x = ([touch locationInView:self.view].x - initialPoint.x);
        movement.y = ([touch locationInView:self.view].y - initialPoint.y);

        [gestureData setObject:[NSValue valueWithCGPoint:movement] forKey:[[NSString alloc] initWithFormat:@"movement%d",self.view.tag]];
    }
    
    [super setState:UIGestureRecognizerStateChanged];
//    NSLog(@"moved");
//    if ([self.target respondsToSelector:self.action]) {
//        [self.target performSelector:self.action withObject:self];
//    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    for (UITouch *touch in touches)
    {
        [gestureData removeObjectForKey:[[NSString alloc] initWithFormat:@"center%d",(int)touch]];
        [gestureData removeObjectForKey:[[NSString alloc] initWithFormat:@"radius%d",(int)touch]];
        [gestureData removeObjectForKey:[[NSString alloc] initWithFormat:@"movement%d",(int)touch]];
    }
    [super setState:UIGestureRecognizerStateEnded];
//    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"touch cancelled");
    [super setState:UIGestureRecognizerStateCancelled];
}

- (void)reset //automatically called when gesture state is ENDED/RECOGNISED
{
//    NSLog(@"reset");
    self.state = UIGestureRecognizerStatePossible;
    // This class will have to call the note on method in the conductor
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
