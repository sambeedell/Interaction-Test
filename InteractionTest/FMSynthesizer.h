//
//  FMSynthesizer.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface FMSynthesizer : AKInstrument
@property (readonly) AKInstrumentProperty *vibrato;
@property (readonly) AKInstrumentProperty *timbre;
@property (readonly) AKAudio *auxilliaryOutput;
@end

@interface FMSynthesizerNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *color;
@property AKNoteProperty *pressure;

- (instancetype)initWithFrequency:(float)frequency color:(float)color;

@end
