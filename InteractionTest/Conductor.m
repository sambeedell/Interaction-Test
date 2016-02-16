//
//  Conductor.m
//  InteractionTest
//
//  Created by Sam Beedell on 27/05/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import "Conductor.h"
#import "FMSynthesizer.h"
#import "EffectsProcessor.h"

@implementation Conductor
{
    FMSynthesizer *fmSynthesizer;
    FMSynthesizerNote *note;
    EffectsProcessor *effect;
    
    NSInteger index;
    uint  currentPressureValueIndex;    // the index used for the array above
    BOOL  ready;                        // This boolean is YES when a touch is recognised on the screen and allows for the pressure calculation to begin
    float   pressure;   // pressure calculation
    NSMutableDictionary *frequency;
    NSMutableDictionary *currentNotes;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Init variables & array
        index = 0;
        pressure = 0.0f;
        frequency = [NSMutableDictionary dictionary];
        [frequency setObject:[NSNumber numberWithFloat:440] forKey:@0];
        [frequency setObject:[NSNumber numberWithFloat:494] forKey:@1];
        currentPressureValueIndex = 0;
        ready = NO;
        
        // Start AK oscillator
        fmSynthesizer = [[FMSynthesizer alloc] init];
        [AKOrchestra addInstrument:fmSynthesizer];
        // Start effects
        effect = [[EffectsProcessor alloc] initWithAudioSource:fmSynthesizer.auxilliaryOutput];
        [AKOrchestra addInstrument:effect];
        [effect start];
    }
    return self;
}

- (void)keyPressed:(id)sender
{
    UILabel *key = (UILabel *)sender;
    index = [key tag];
    //    NSLog(@"index : %d",index);
    
    // Accurate pressure sensitivity = 0.1s of lag
    // if the pressure calculation happened here also, how could this affect the results?
    currentPressureValueIndex = 0;
    ready = YES;
    
    // Not so accurate sensitivity = 0.001s lag -> would work if the sensor data was updated on a different thread
    //    pressure = [[array valueForKeyPath:@"@max.self"] floatValue];
}

- (void)noteOn
{
    // GET PRESSURE
    _modSlider.value = pressure + 0.1;
    
    //this note is seperated from 'play'  so that it doesnt get called outside of the UIImageView frames.
    //Start Note - same as synth project
    float hz = [[frequency objectForKey:[NSNumber numberWithInt:(int)index]] floatValue];
    note = [[FMSynthesizerNote alloc] initWithFrequency:hz color:_modSlider.value];
    [AKTools setProperty:note.pressure withSlider:_modSlider];
    [fmSynthesizer playNote:note];
    
    // Print how long it took from the first touch
    //    NSTimeInterval latest = [[NSDate date] timeIntervalSince1970];
    //    NSLog(@"Note is sent here: %f", latest - currentTime);
    
    [currentNotes setObject:note forKey:[NSNumber numberWithInt:(int)index]]; //save note
}

- (void)keyReleased:(id)sender
{
    UILabel *key = (UILabel *)sender;
    NSInteger kIndex = [key tag];
    //    NSLog(@"release");
    FMSynthesizerNote *noteToRelease = [currentNotes objectForKey:[NSNumber numberWithInt:(int)kIndex]];
    
    [fmSynthesizer stopNote:noteToRelease];
    
    [currentNotes removeObjectForKey:[NSNumber numberWithInt:(int)kIndex]];
}

- (void)handleContinuousGestures
{
    // THIS IS WHAT MAKES IT UNSTABLE!
    // Currently using the AKInstrumentPropertys for continuous gestures, they are independant of the note played and affect the oscillators settings as apposed to the note. This causes the proceedings taps to be incorrect becasue the instrumnet is not in its defaults state when the note is played.
//    fmSynthesizer.vibrato.value = customTouch1->movement.x / 20;
//    fmSynthesizer.timbre.value  = customTouch1->movement.y / 60;
    
    // Unfortunately this doesn't work. it causes the frequency of the note to be updated but in doing so the note is also re-triggered causing an unpleasant stuttered sound.
    // If this did work it would make the continuous gestures fucntion
    //    FMSynthesizerNote *noteToChange = [currentNotes objectForKey:[NSNumber numberWithInt:keyIndex]];
    //    [note.frequency setValue: 440 + customTouch->movement.x];
    
    
    // update location of the image - used for testing purposes
    //    self.imageView.center = location;
}



@end
