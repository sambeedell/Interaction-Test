//
//  ViewController.m
//  InteractionTest
//
//  Created by Sam Beedell on 18/03/2015.
//  Copyright (c) 2015 Sam Beedell. All rights reserved.
//

#import "ViewController.h"
#import "CustomGestureRecogniser.h"

@interface ViewController : UIViewController <CustomGestureRecogniserDelegate, UIGestureRecognizerDelegate>
{
    float   x;          // x-axis of the gravity property
    float   y;          // y-axis of the gravity property
    float   pressure;   // pressure calculation
    int     keyIndex;   // used to index which virtual key has been pressed
    
    NSMutableArray *array;              // this array is used to store the sensor data
    uint  currentPressureValueIndex;    // the index used for the array above
    BOOL  ready;                        // This boolean is YES when a touch is recognised on the screen and allows for the pressure calculation to begin
   
    //This is used for latency testing
    NSTimeInterval currentTime;
    float number;
    
    
    IBOutlet UIButton *gestureOFF;
    IBOutlet UIButton *motionOFF;
    FMSynthesizer *fmSynthesizer;
    FMSynthesizerNote *note;
    EffectsProcessor *effect;
    CustomGestureRecogniser *customTouch;
//    CustomGestureRecogniser *customTouch2;
    NSMutableDictionary *frequency;
    NSInteger index;
    float color;
    NSMutableDictionary *currentNotes;
//    NSMutableDictionary *touchData;
}

//---------------------------------------------------------------------
// IBOutlet properties - links the view to the controller
//---------------------------------------------------------------------
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIImageView *waveform;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UISlider *modSlider;
@property (strong, nonatomic) UISlider *effSlider;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *tap1;
@property (strong, nonatomic) IBOutlet UIButton *tap2;
@property (strong, nonatomic) IBOutlet UIView *gestureReciever;

@end

@implementation ViewController

- (MotionManagerObject *)theMMDataObject {
    id<CMDelegateProtocol> theDelegate = (id<CMDelegateProtocol>) [UIApplication sharedApplication].delegate;
    MotionManagerObject* theDataObject = (MotionManagerObject*) theDelegate.theMMDataObject;
    return theDataObject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSMutableSet *buttons = [[NSMutableSet alloc] init];
    [buttons addObject: self.tap1];
    [buttons addObject: self.tap2];
    for(UIButton *button in buttons){
        customTouch = [[CustomGestureRecogniser alloc] initWithTarget:self action:@selector(handleCustomGesture:)];
        [customTouch setDelegate:self];
//        [self.gestureReciever addGestureRecognizer:customTouch];
        [button addGestureRecognizer:customTouch];
    }

//    customTouch1 = [[CustomGestureRecogniser alloc] initWithTarget:self action:@selector(handleCustomGesture:)];
//    customTouch2 = [[CustomGestureRecogniser alloc] initWithTarget:self action:@selector(handleCustomGesture:)];
//    [customTouch1 setDelegate:self];
//    [customTouch2 setDelegate:self];
//    [self.tap1 addGestureRecognizer:customTouch1];
//    [self.tap2 addGestureRecognizer:customTouch2];
    

    currentNotes = [NSMutableDictionary dictionary];
    
    
    //INIT PRESSURE USAGE
    [self.view setMultipleTouchEnabled:YES];
    
    // Init variables & array
    pressure = 0.0f;
    frequency = [NSMutableDictionary dictionary];
    [frequency setObject:[NSNumber numberWithFloat:440] forKey:@0];
    [frequency setObject:[NSNumber numberWithFloat:494] forKey:@1];
    keyIndex = 0;
    currentPressureValueIndex = 0;
    ready = NO;
    array = [[NSMutableArray alloc] initWithCapacity:kNumSamples+1];
    for (int i = 0; i < kNumSamples; i++) {
        [array insertObject:[NSNumber numberWithFloat:0] atIndex:i];
    }
    self.effSlider = [[UISlider alloc] init];
    
    // update UI
//    gestureOFF.selected = !gestureOFF.selected;
    
    // Start AK oscillator
    fmSynthesizer = [[FMSynthesizer alloc] init];
    [AKOrchestra addInstrument:fmSynthesizer];
    // Start effects
    effect = [[EffectsProcessor alloc] initWithAudioSource:fmSynthesizer.auxilliaryOutput];
    [AKOrchestra addInstrument:effect];
    [effect start];
    
    //Start updates from the MMDataObject
    [self startUpdates];
    
    // Used for testing
    number = 0;
}

- (void)handleCustomGesture:(id)sender /// <- what can i get from this sender? EVERYTHING
{
    if([(CustomGestureRecogniser*)sender state] == UIGestureRecognizerStateCancelled) {
        [fmSynthesizer stop];
        return;
    }
    
    if([(CustomGestureRecogniser*)sender state] == UIGestureRecognizerStateBegan) {     // touchesBegan
        [self keyPressed:[(CustomGestureRecogniser*)sender view]];
    }
    
    if([(CustomGestureRecogniser*)sender state] == UIGestureRecognizerStateChanged) {   // touchesMoved
        if (!gestureOFF.selected) {
            [self handleContinuousGestures:[(CustomGestureRecogniser*)sender view]];
        }
    }
    
    if([(CustomGestureRecogniser*)sender state] == UIGestureRecognizerStateEnded) {     // touchesEnded
        [self keyReleased:[(CustomGestureRecogniser*)sender view]];
    }
    
//    NSLog(@"%@",customTouch.gestureData);
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
    
    if (motionOFF.selected) {
        [self noteOn];
    }
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

- (void)handleContinuousGestures:(id)sender
{
    // THIS IS WHAT MAKES IT UNSTABLE!
    // Currently using the AKInstrumentPropertys for continuous gestures, they are independant of the note played and affect the oscillators settings as apposed to the note. This causes the proceedings taps to be incorrect becasue the instrumnet is not in its defaults state when the note is played.
    CGPoint movement = [[customTouch.gestureData objectForKey:[[NSString alloc] initWithFormat:@"movement%d",index]] CGPointValue];
    fmSynthesizer.vibrato.value = movement.x / 20;
    fmSynthesizer.timbre.value  = movement.y / 60;
    
    // Unfortunately this doesn't work. it causes the frequency of the note to be updated but in doing so the note is also re-triggered causing an unpleasant stuttered sound.
    // If this did work it would make the continuous gestures fucntion
//    FMSynthesizerNote *noteToChange = [currentNotes objectForKey:[NSNumber numberWithInt:keyIndex]];
//    [note.frequency setValue: 440 + customTouch->movement.x];
    
    
    // update location of the image - used for testing purposes
//    self.imageView.center = location;
}

- (void)startUpdates // this is needed here instead of the gesture recogniser because you cannot have multiple the touches methods. if you do then you can only delay the gesture subclass, not in the
{
    MotionManagerObject* motionManagerObject = [self theMMDataObject];
    CMMotionManager* motionManager = motionManagerObject.motionManager;
    if (!motionManager.deviceMotionActive){ //Check to see if the CMManager is already active
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
            
            // set current pressure value
            float accel    = data.userAcceleration.z; // tap velocity into the touchscreen
//            double rotation = data.rotationRate.y;     // rotation rate of device when landscape
//            double attitude = data.attitude.roll;      // rotation of device when landscape
            
            double input = (fabsf(accel));// + rotation) * attitude) * 2;
            
            [array replaceObjectAtIndex:currentPressureValueIndex withObject:[NSNumber numberWithFloat:input]];

            effect.reverb.value = [self normaliseData:data.gravity.x minimum:-1 maximum:1];
            _effSlider.value    = [self normaliseData:data.gravity.y minimum:-1 maximum:1];
            [AKTools setProperty:effect.cutoff withSlider:_effSlider];
            
            currentPressureValueIndex++;
            if (currentPressureValueIndex > kNumSamples-1) {
                currentPressureValueIndex = 0; //wrap index
                
                // Draw the input DM data as a graph.
                {
                    // Get the size of the UIImageView used to hold the waveform
                    CGSize size = self.waveform.bounds.size;
                    
                    // Initialize the bitmap-based graphics bounds for the current context
                    UIGraphicsBeginImageContext(size);
                    
                    // Create a path to map the data points to
                    UIBezierPath *waveformPath = [UIBezierPath bezierPath];
                    
                    // Length of buffer
                    NSUInteger waveformLength = kNumSamples;
                    
                    // Scale the x-axis to the size of the UIImageView with the lenght of buffer points.
                    float xScale = size.width / waveformLength;
                    
                    // Loop around all sample values in the buffer
                    for (int i = 0; i < waveformLength; i++) {
                        float x1 = xScale * i;
                        float y1 = [[array objectAtIndex:i] floatValue] * size.height + (size.height/2);
                        if (i == 0) { // Give instruction to the CGContext
                            [waveformPath moveToPoint:CGPointMake(x1, y1)];
                        } else {
                            [waveformPath addLineToPoint:CGPointMake(x1, y1)];
                        }
                    }
                    waveformPath.lineWidth = 0.5f;
                    [[UIColor blackColor] setStroke]; //colour of the path
                    [waveformPath stroke]; //draw the path
                    
                    // Get the CGContext and assign it the UIImageView
                    self.waveform.image = UIGraphicsGetImageFromCurrentImageContext();
                    // Remove the bitmap-based graphics from the current CGContext
                    UIGraphicsEndImageContext();
                }
                
                if (ready == YES) {
                    pressure = [[array valueForKeyPath:@"@max.self"] floatValue];
                    pressure = [self normaliseData:pressure minimum:0 maximum:8.1];
                    float radius = [[customTouch.gestureData objectForKey:[[NSString alloc] initWithFormat:@"radius%d",index]] floatValue];
                    radius = [self normaliseData:radius minimum:0 maximum:200];
                    pressure *= (radius * kPressureScale);
                    
                    // multiply //
                    //Table	 0.0128 -> 0.255	approx
                    //Hand	 0.0192 -> 1.275	approx
                    //   add    //
                    //Table	 0.138  -> 0.355	approx
                    //Hand	 0.143  -> 0.755	approx
                    
                    self.label1.text = [[NSString alloc] initWithFormat:@"%f",pressure];
//                    // Print how long it took from the first touch
//                    NSTimeInterval latest = [[NSDate date] timeIntervalSince1970];
//                    NSLog(@"Calculation      : %f", latest - currentTime);
                    ready = NO;
                    [self noteOn];
                }
            }
        }];
    }
}

- (float)normaliseData:(float)data minimum:(float)min maximum:(float)max
{
    // This function is used to normalise any value, if its minimum and maximum values are known.
    // this make data more flexible and can be integrated into ANY system .
    // once the data is normalised it can be scaled to a new range.
    // http://stats.stackexchange.com/questions/70801/how-to-normalize-data-to-0-1-range
    // zi = xi − min(x) / max(x) − min(x)
    
    float   normalisedData = (data - min) / (max - min);
    return  normalisedData;
}

- (IBAction)off:(UIButton*)sender
{
    // Toggle on and off the device motion updates
    ready = NO;
    motionOFF.selected = !motionOFF.selected;
    if (!motionOFF.selected) {
        [self startUpdates];
    } else {
        MotionManagerObject* motionManagerObject = [self theMMDataObject];
        CMMotionManager* motionManager = motionManagerObject.motionManager;
        [motionManager stopDeviceMotionUpdates];
    }
    
}

- (IBAction)motionTouched:(id)sender
{
    // Toggle continuous gestures
    gestureOFF.selected = !gestureOFF.selected;
    NSLog(@"motion off");
}






@end
