//
//  CustomGestureRecogniser.h
//  InteractionTest
//
//  Created by Sam Beedell on 08/05/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@protocol CustomGestureRecogniserDelegate <UIGestureRecognizerDelegate>

@end

@interface CustomGestureRecogniser : UIGestureRecognizer
{
@private
    CGPoint center; // position of the users touch on screen
}

@property (strong, nonatomic) id target;
@property (nonatomic) SEL action;
@property (strong, nonatomic) NSMutableDictionary *gestureData;

@end