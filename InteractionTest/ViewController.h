//
//  ViewController.h
//  InteractionTest
//
//  Created by Sam Beedell on 18/03/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionManagerObject.h"
#import "FMSynthesizer.h"
#import "EffectsProcessor.h"
#import "AKTools.h"

#define kNumSamples 4 // this is the amount of Device Motion (DM) samples stored at any given point. It is set to 4 becasue there are 100 samples per second being fed out of the hardware sensors (this is can be defined in the MotionManagerObject), therefore 0.04 seconds of data is in the array at any given point. This is enough to capture a tap impulse. this time was determined by temporally measuring the length of a tap gesture at different velocities using a microphone.

// Unfortunately there was considerable lag when the pressure sens was functioning, this was due to the method of captiuring not being simultaneous to the main queue. also, the amount of NSLog statements will inevitably slow down the processor!

#define kPressureScale 15 // this is a scaling factor for the pressure value. it should be possible for the user to define this amount to adjust for their current location and playing preference

