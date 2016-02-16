//
//  AppDelegate.h
//  InteractionTest
//
//  Created by Sam Beedell on 18/03/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionManagerObject.h"

@class MotionManagerObject;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *window;
    MotionManagerObject *theMMDataObject;
}
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) MotionManagerObject *theMMDataObject;

@end

