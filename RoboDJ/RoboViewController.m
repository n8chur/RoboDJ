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
#define kParadiseDropTime 60.7943f // off?
#define kParadiseBridgeTime 90.290f // off?
#define kParadiseOutroTime 270.294f

#define kSayStartTime 0.123f
#define kSayIntroTime 30.122f
#define kSayDropTime 60.122f
#define kSayBridgeTime 90.123f
#define kSayOutroTime 331.998f //off?

#import "RoboViewController.h"

#import <AVFoundation/AVFoundation.h>

typedef enum {
    RDJSectionTypeStart = 0,
    RDJSectionTypeIntro,
    RDJSectionTypeDrop,
    RDJSectionTypeBridge,
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

@interface RoboViewController () <AVAudioPlayerDelegate>

@property (nonatomic, retain) AVAudioPlayer* audioPlayerA;
@property (nonatomic, retain) AVAudioPlayer* audioPlayerB;

@property (nonatomic, retain) NSTimer* audioPlayerATimeCheckTimer;
@property (nonatomic, retain) NSTimer* audioPlayerBTimeCheckTimer;

@property (nonatomic, retain) NSTimer* transitionTimer;

@property (nonatomic) RDJSectionType audioPlayerACurrentSection;
@property (nonatomic) RDJSectionType audioPlayerBCurrentSection;

@property (nonatomic, retain) NSArray* audioPlayerASections;
@property (nonatomic, retain) NSArray* audioPlayerBSections;

@property (nonatomic) BOOL transitionInProgress;

@property (nonatomic) Float32 mixAmount;

- (void)playAudioPlayerA;
- (void)playAudioPlayerB;

@end

@implementation RoboViewController
@synthesize volumeALabel = _volumeALabel;
@synthesize volumeBLabel = _volumeBLabel;
@synthesize mixerSlider = _mixerSlider;

@synthesize audioPlayerA = _audioPlayerA;
@synthesize audioPlayerB = _audioPlayerB;

@synthesize audioPlayerATimeCheckTimer = _audioPlayerATimeCheckTimer;
@synthesize audioPlayerBTimeCheckTimer = _audioPlayerBTimeCheckTimer;

@synthesize transitionTimer = _transitionTimer;

@synthesize audioPlayerACurrentSection = _audioPlayerACurrentSection;
@synthesize audioPlayerBCurrentSection = _audioPlayerBCurrentSection;

@synthesize audioPlayerASections = _audioPlayerASections;
@synthesize audioPlayerBSections = _audioPlayerBSections;

@synthesize transitionInProgress = _transitionInProgress;

@synthesize mixAmount = _mixAmount;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.audioPlayerA = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Paradise" withExtension:@"mp3"] error:nil];
    self.audioPlayerA.delegate = self;
    self.audioPlayerASections = [NSArray arrayWithObjects:
                                 [[RDJSection alloc] initWithType:RDJSectionTypeStart startTime:kParadiseStartTime],
                                 [[RDJSection alloc] initWithType:RDJSectionTypeIntro startTime:kParadiseIntroTime],
                                 [[RDJSection alloc] initWithType:RDJSectionTypeOutro startTime:kParadiseOutroTime],
                                 nil];
    self.audioPlayerACurrentSection = RDJSectionTypeStart;
    
    
    self.audioPlayerB = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Say" withExtension:@"mp3"] error:nil];
    self.audioPlayerB.delegate = self;
    self.audioPlayerBSections = [NSArray arrayWithObjects:
                                 [[RDJSection alloc] initWithType:RDJSectionTypeStart startTime:kSayStartTime],
                                 [[RDJSection alloc] initWithType:RDJSectionTypeIntro startTime:kSayIntroTime],
                                 [[RDJSection alloc] initWithType:RDJSectionTypeOutro startTime:kSayOutroTime],
                                 nil];
    self.audioPlayerBCurrentSection = RDJSectionTypeStart;
    
    [self.audioPlayerA setVolume:kGlobalVolume];
    [self.audioPlayerB setVolume:kGlobalVolume];
    
    [self.audioPlayerA prepareToPlay];
    [self.audioPlayerB prepareToPlay];
    
    self.mixerSlider.value = 0.0f;
    self.mixAmount = 0.0f;
    
    self.transitionInProgress = NO;
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
    
    [self.audioPlayerA stop];
    [self.audioPlayerB stop];
    
    [self.audioPlayerATimeCheckTimer invalidate];
    [self.audioPlayerBTimeCheckTimer invalidate];
    
    [self.transitionTimer invalidate];
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

- (void)setMixAmount:(Float32)amount
{
    
    Float32 audioPlayerAVolume;
    Float32 audioPlayerBVolume;
    
    Float32 sliderValue;
    // power ( steep in ease out ( ease out ) 
    sliderValue = amount;
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
    
    self.mixerSlider.value = amount;
    
    _mixAmount = amount;
}

- (IBAction)startButtonPressed:(id)sender 
{
    [self playAudioPlayerA];    
}

- (void)transition
{
    if ( self.mixAmount < 0.99f ) {
        self.mixAmount += (1.0f/60.0f)/10;
    }
    else {
        self.mixAmount = 1.0f;
        [self.transitionTimer invalidate];
        self.transitionInProgress = NO;
        
//        self.audioPlayerBTimeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(audioPlayerBCheckTime) userInfo:nil repeats:YES];
    }
}

- (void)transitionToBAtTime:(NSTimeInterval)startTime
{
    self.transitionInProgress = YES;
    
    RDJSection* introSection = [self.audioPlayerBSections objectAtIndex:1];
    [self.audioPlayerB setCurrentTime:introSection.startTime];
    [self.audioPlayerB prepareToPlay];
    NSTimeInterval timeTillTransition = startTime - self.audioPlayerA.currentTime;
    [self.audioPlayerB playAtTime:self.audioPlayerB.deviceCurrentTime + timeTillTransition];
    
    self.transitionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(transition) userInfo:nil repeats:YES];
}

- (void)audioPlayerACheckTime
{
    if ( self.transitionInProgress == NO ) {
        RDJSection* startSection = [self.audioPlayerASections objectAtIndex:1];
        NSTimeInterval delay = 0.2f;
        if ( self.audioPlayerA.currentTime >= startSection.startTime - delay) {
            NSLog(@"entering outro at: %f", self.audioPlayerA.currentTime);
            [self transitionToBAtTime:startSection.startTime];
            [self.audioPlayerATimeCheckTimer invalidate];
        }
    }
}

- (void)playAudioPlayerA
{
    RDJSection* startSection = [self.audioPlayerASections objectAtIndex:2];
    NSTimeInterval secondBeforeOutro = startSection.startTime - 2;
    [self.audioPlayerA setCurrentTime:secondBeforeOutro];
    [self.audioPlayerA prepareToPlay];
    [self.audioPlayerA play];
    
    self.audioPlayerATimeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(audioPlayerACheckTime) userInfo:nil repeats:YES];
}

- (void)audioPlayerBCheckTime
{
    if ( self.transitionInProgress == NO ) {
        RDJSection* startSection = [self.audioPlayerASections objectAtIndex:1];
        if ( self.audioPlayerA.currentTime >= startSection.startTime ) {
            NSLog(@"entering outro at: %f", self.audioPlayerA.currentTime);
            self.transitionInProgress = YES;
        }
    }
}

- (void)playAudioPlayerB
{
    RDJSection* startSection = [self.audioPlayerASections objectAtIndex:2];
    NSTimeInterval secondBeforeOutro = startSection.startTime - 1;
    [self.audioPlayerA setCurrentTime:secondBeforeOutro];
    [self.audioPlayerA prepareToPlay];
    [self.audioPlayerA play];
    
    self.audioPlayerATimeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(audioPlayerACheckTime) userInfo:nil repeats:YES];
}

@end
