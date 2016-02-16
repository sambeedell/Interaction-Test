//
//  FMSynthesizer.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//  Adapted by Sam

#import "FMSynthesizer.h"

@implementation FMSynthesizer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Instrumnet property definition
        _vibrato = [self createPropertyWithValue:0.0 minimum:-10 maximum:10];
        _timbre  = [self createPropertyWithValue:0.0 minimum:-1  maximum:1];
        
        // Note Instance
        FMSynthesizerNote *note = [[FMSynthesizerNote alloc] init];
        
        // Envelope Definition
        AKADSREnvelope *envelope = [[AKADSREnvelope alloc] initWithAttackDuration:akp(0.05)
                                                                    decayDuration:note.pressure
                                                                     sustainLevel:akp(0.3)
                                                                  releaseDuration:akp(0.3)
                                                                            delay:akp(0)];
        
        // FM Oscillator Defition
        AKFMOscillator *oscillator = [AKFMOscillator oscillator];
        oscillator.baseFrequency        = [note.frequency plus:_vibrato];
//        oscillator.carrierMultiplier    = [note.color scaledBy:akp(2)];
//        oscillator.modulatingMultiplier = [note.color scaledBy:akp(3)];
        oscillator.modulationIndex      = [[note.color scaledBy:akp(10)] plus:_timbre];
        oscillator.amplitude            = [envelope   scaledBy:akp(0.5)];
        [self setAudioOutput:oscillator];
        
        // Output to global effects processing
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:oscillator];
}
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - FMSynthesizer Note
// -----------------------------------------------------------------------------


@implementation FMSynthesizerNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note property definitions
        _frequency = [self createPropertyWithValue:440 minimum:100 maximum:20000];
        _color     = [self createPropertyWithValue:0.0 minimum:0   maximum:1];
        _pressure  = [self createPropertyWithValue:0.5 minimum:0   maximum:1];
//        self.duration.value = 0.2; //this is used for testing
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency color:(float)color
{
    self = [self init];
    if (self) {
        // update properties
        _frequency.value = frequency;
        _color.value = color;
    }
    return self;
}

@end
