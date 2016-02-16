//
//  EffectsProcessor.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//  Adapted by Sam Beedell

#import "AKFoundation.h"

@interface EffectsProcessor : AKInstrument 

- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

@property AKInstrumentProperty *reverb;
@property AKInstrumentProperty *cutoff;

@end
