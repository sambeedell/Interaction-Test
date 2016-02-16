//
//  MotionManagerObject.h
//  InteractionTest
//
//  Created by Sam Beedell on 01/04/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "CMDelegateProtocol.h"

@interface MotionManagerObject : NSObject

@property (nonatomic, retain) CMMotionManager *motionManager; //'retain' is used instead of 'assign' becasue ARC is active

@end

