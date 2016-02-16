//
//  EffectsProcessor.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//  Adapted by Sam Beedell

#import "EffectsProcessor.h"

@implementation EffectsProcessor

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT CONTROL ==================================================
        _reverb = [self createPropertyWithValue:0.0   minimum:0.0  maximum:1.0];
        _cutoff = [self createPropertyWithValue:100   minimum:1000 maximum:6000];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKReverb *reverb = [[AKReverb alloc] initWithInput:audioSource
                                                  feedback:_reverb
                                           cutoffFrequency:_cutoff ];

        // AUDIO OUTPUT ========================================================
        
        [self setAudioOutput:reverb];
 
        // RESET INPUTS ========================================================
        [self resetParameter:audioSource];
    }
    return self;
}

@end
