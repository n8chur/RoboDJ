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

#import "RDJSong.h"

@interface RoboViewController ()

@property (nonatomic, retain) AVAudioPlayer* audioPlayerA;
@property (nonatomic, retain) AVAudioPlayer* audioPlayerB;

@property (nonatomic, retain) NSTimer* audioPlayerATimeCheckTimer;
@property (nonatomic, retain) NSTimer* audioPlayerBTimeCheckTimer;

@property (nonatomic, retain) NSTimer* transitionTimer;

@property (nonatomic, retain) RDJSong* songA;
@property (nonatomic, retain) RDJSong* songB;

@property (nonatomic) BOOL transitionInProgress;

@property (nonatomic) Float32 mixAmount;

@property (nonatomic) NSTimeInterval timeToPlayNextTrack;

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

@synthesize songA = _songA;
@synthesize songB = _songB;

@synthesize transitionInProgress = _transitionInProgress;

@synthesize mixAmount = _mixAmount;

@synthesize timeToPlayNextTrack = _timeToPlayNextTrack;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	self.songA = [[RDJSong alloc] init];
//    self.songA.sectionIntro =  [[RDJSection alloc] initWithType:RDJSectionTypeIntro startTime:kParadiseStartTime];
//    self.songA.sectionBuildUp = [[RDJSection alloc] initWithType:RDJSectionTypeBuildUp startTime:kParadiseIntroTime];
//    self.songA.sectionOutro = [[RDJSection alloc] initWithType:RDJSectionTypeOutro startTime:kParadiseOutroTime];
    
    self.songA = [RDJSong parseJSONURL:[[NSBundle mainBundle] URLForResource:@"Paradise" withExtension:@"json"]];
    
    NSLog(@"songA: %@", self.songA);
    
    self.songB = [[RDJSong alloc] init];
    self.songB.sectionIntro =  [[RDJSection alloc] initWithType:RDJSectionTypeIntro startTime:kSayStartTime];
    self.songB.sectionBuildUp = [[RDJSection alloc] initWithType:RDJSectionTypeBuildUp startTime:kSayIntroTime];
    self.songB.sectionOutro = [[RDJSection alloc] initWithType:RDJSectionTypeOutro startTime:kSayOutroTime];
    
    self.audioPlayerA = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Paradise" withExtension:@"mp3"] error:nil];
    self.audioPlayerB = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Say" withExtension:@"mp3"] error:nil];
    
    [self.audioPlayerA setVolume:kGlobalVolume];
    [self.audioPlayerB setVolume:kGlobalVolume];
    
//    self.audioPlayerA.
    
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
        self.mixAmount += (1.0f/60.0f)/20;
    }
    else {
        self.mixAmount = 1.0f;
        [self.transitionTimer invalidate];
        self.transitionInProgress = NO;
        
//        self.audioPlayerBTimeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(audioPlayerBCheckTime) userInfo:nil repeats:YES];
    }
}

- (void)transitionToB
{
    [self.audioPlayerB playAtTime:self.timeToPlayNextTrack];
    self.timeToPlayNextTrack = self.timeToPlayNextTrack + self.songB.sectionOutro.startTime - self.songB.sectionBuildUp.startTime;
    self.transitionInProgress = YES;
    self.transitionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(transition) userInfo:nil repeats:YES];
}

- (void)audioPlayerACheckTime
{
    if ( self.transitionInProgress == NO ) {
        NSTimeInterval delay = 1.0f;
        if ( self.audioPlayerA.currentTime >= self.songA.sectionOutro.startTime - delay) {
            [self transitionToB];
            [self.audioPlayerATimeCheckTimer invalidate];
        }
    }
}

- (void)playAudioPlayerA
{
    NSTimeInterval secondsBeforeOutro = self.songA.sectionOutro.startTime - 2.0f;
    [self.audioPlayerA setCurrentTime:secondsBeforeOutro];
    [self.audioPlayerA prepareToPlay];
    NSTimeInterval startTime = self.audioPlayerA.deviceCurrentTime + 0.2f;
    self.timeToPlayNextTrack = startTime + 2.0f;
    [self.audioPlayerA playAtTime:startTime];
    
    [self.audioPlayerB setCurrentTime:self.songB.sectionBuildUp.startTime];
    [self.audioPlayerB prepareToPlay];
    
    self.audioPlayerATimeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(audioPlayerACheckTime) userInfo:nil repeats:YES];
}

- (void)audioPlayerBCheckTime
{
//    if ( self.transitionInProgress == NO ) {
//        RDJSection* startSection = [self.audioPlayerASections objectAtIndex:1];
//        if ( self.audioPlayerA.currentTime >= startSection.startTime ) {
//            NSLog(@"entering outro at: %f", self.audioPlayerA.currentTime);
//            self.transitionInProgress = YES;
//        }
//    }
}

- (void)playAudioPlayerB
{
//    RDJSection* startSection = [self.audioPlayerASections objectAtIndex:2];
//    NSTimeInterval secondBeforeOutro = startSection.startTime - 1;
//    [self.audioPlayerA setCurrentTime:secondBeforeOutro];
//    [self.audioPlayerA prepareToPlay];
//    [self.audioPlayerA play];
//    
//    self.audioPlayerATimeCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(audioPlayerACheckTime) userInfo:nil repeats:YES];
}

@end
