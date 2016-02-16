//
//  MotionManagerObject.m
//  InteractionTest
//
//  Created by Sam Beedell on 01/04/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import "MotionManagerObject.h"

#define kUpdateFrequency 100.0f // 70 - 100 must be used for high-frequency motion

@implementation MotionManagerObject
@synthesize motionManager;

- (instancetype)init
{
    self = [super init];
    
    if (!self.motionManager){ // If the Motion Manager has not be initialised already...
        //Initialize Motion Manager - this must only be done once in an application
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval = 1.0f / kUpdateFrequency;
        if (self.motionManager.deviceMotionAvailable){ //Check the sensors exist in the device
            NSLog(@"DeviceMotion ON");
        } else
            NSLog(@"DeviceMotion not available");
//        [self.delegate getDeviceMotionMessage:@"DeviceMotion not available"];
    }
    return self;
}

//    // Useful methods to calculate the mean and standard deviation on an array. These function return an NSNumber
//
//- (NSNumber *)meanOf:(NSArray *)arrayIn
//{
//    double runningTotal = 0.0;
//    
//    for(NSNumber *number in arrayIn)
//    {
//        runningTotal += [number doubleValue];
//    }
//    
//    return [NSNumber numberWithDouble:(runningTotal / [arrayIn count])];
//}
//
//- (NSNumber *)standardDeviationOf:(NSArray *)arrayIn
//{
//    if(![arrayIn count]) return nil;
//    
//    double mean = [[self meanOf:arrayIn] doubleValue];
//    double sumOfSquaredDifferences = 0.0;
//    
//    for(NSNumber *number in arrayIn)
//    {
//        double valueOfNumber = [number doubleValue];
//        double difference = valueOfNumber - mean;
//        sumOfSquaredDifferences += difference * difference;
//    }
//    
//    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [arrayIn count])];
//}

@end
