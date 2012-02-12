//
//  RoboViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#define kGlobalVolume 0.5f

#define kParadiseStartTime 0.295f
#define kParadiseIntroTime 30.293f
#define kParadiseDropTime 60.7943f
#define kParadiseBridgeTime 90.290f

#define kSayStartTime 0.123f
#define kSayIntroTime 30.122f

#import "RoboViewController.h"

#import <AVFoundation/AVFoundation.h>

typedef enum {
    RDJSectionTypeStart = 0,
    RDJSectionTypeIntro,
    RDJSectionTypeOutro
} RDJSectionType;

@interface RDJSection : NSObject

@property (nonatomic) RDJSectionType type;
@property (nonatomic) NSTimeInterval startTime;

-(id)initWithType:(RDJSectionType)aType startTime:(NSTimeInterval)aStartTime;

@end

@implementation RDJSection

@synthesize type = _type;
@synthesize startTime = _startTime;

-(id)initWithType:(RDJSectionType)aType startTime:(NSTimeInterval)aStartTime
{
    self = [super init];
    if (self) {
        self.type = aType;
        self.startTime = aStartTime;
    }
    return self;
}

@end

@interface RoboViewController ()

@property (nonatomic, retain) AVAudioPlayer* audioPlayerA;
@property (nonatomic, retain) AVAudioPlayer* audioPlayerB;

@property (nonatomic, retain) NSDictionary* audioPlayerASections;
@property (nonatomic, retain) NSDictionary* audioPlayerBSections;

@end

@implementation RoboViewController
@synthesize volumeALabel = _volumeALabel;
@synthesize volumeBLabel = _volumeBLabel;
@synthesize mixerSlider = _mixerSlider;

@synthesize audioPlayerA = _audioPlayerA;
@synthesize audioPlayerB = _audioPlayerB;

@synthesize audioPlayerASections = _audioPlayerASections;
@synthesize audioPlayerBSections = _audioPlayerBSections;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.audioPlayerA = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Paradise" withExtension:@"mp3"] error:nil];
    self.audioPlayerASections = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[RDJSection alloc] initWithType:RDJSectionTypeStart startTime:kParadiseStartTime], 
                                 nil];
    self.audioPlayerB = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Say" withExtension:@"mp3"] error:nil];
    
    [self.audioPlayerA setVolume:kGlobalVolume];
    [self.audioPlayerB setVolume:kGlobalVolume];
    
    [self.audioPlayerA prepareToPlay];
    [self.audioPlayerB prepareToPlay];
    
    self.mixerSlider.value = 0.5f;
}

- (void)viewDidUnload
{
    [self setMixerSlider:nil];
    [self setVolumeALabel:nil];
    [self setVolumeBLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)mixerSliderValueChanged:(id)sender {
    Float32 audioPlayerAVolume;
    Float32 audioPlayerBVolume;
    
    Float32 sliderValue;
    // power ( steep in ease out ( ease out ) 
    sliderValue = self.mixerSlider.value;
    audioPlayerAVolume =( 1 - ((1-cos((sliderValue + 0.5f)*M_PI*2))/2)   ) * kGlobalVolume;
    if ( sliderValue < 0.5f ) {
        audioPlayerAVolume = kGlobalVolume;
    }
    audioPlayerBVolume = ( (1-cos(sliderValue*M_PI*2))/2   ) * kGlobalVolume;
    if ( sliderValue > 0.5 ) {
        audioPlayerBVolume = kGlobalVolume;
    }
    
    if ( audioPlayerAVolume > kGlobalVolume ) {
        audioPlayerAVolume = kGlobalVolume;
    }
    if ( audioPlayerBVolume > kGlobalVolume ) {
        audioPlayerBVolume = kGlobalVolume;
    }
    
    
    [self.audioPlayerA setVolume:audioPlayerAVolume];
    [self.audioPlayerB setVolume:audioPlayerBVolume];
    
    self.volumeALabel.text = [NSString stringWithFormat:@"%.4f", audioPlayerAVolume];
    self.volumeBLabel.text = [NSString stringWithFormat:@"%.4f", audioPlayerBVolume];
}

- (IBAction)curveTypeSegmentedControlValueChanged:(id)sender {
}

- (IBAction)playIntrosSyncedButtonPressed:(id)sender {
    NSTimeInterval playTimeA = kParadiseIntroTime;
    NSTimeInterval playTimeB = kSayIntroTime;
    
    [self.audioPlayerA setCurrentTime:playTimeA];
    [self.audioPlayerB setCurrentTime:playTimeB];
    NSLog(@"playTimeA: %f, playTimeB: %f", playTimeA, playTimeB);
    
    NSTimeInterval shortStartDelay = 0.01;
    [self.audioPlayerA playAtTime:self.audioPlayerA.deviceCurrentTime + shortStartDelay];
    [self.audioPlayerB playAtTime:self.audioPlayerA.deviceCurrentTime + shortStartDelay];
}

- (IBAction)playAButtonPressed:(id)sender {
    [self.audioPlayerA playAtTime:0];
    
}

- (IBAction)playBButtonPressed:(id)sender {
    [self.audioPlayerB playAtTime:0];
}

- (IBAction)stopAButtonPressed:(id)sender {
    [self.audioPlayerA pause];
}

- (IBAction)stopBButtonPressed:(id)sender {
    [self.audioPlayerB pause];
}
@end
