//
//  SpotifyViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "SpotifyViewController.h"

#import "CocoaLibSpotify.h"
#import "SPPlaybackManager.h"

@interface SpotifyViewController () <SPSessionDelegate, SPSessionPlaybackDelegate>

@property (nonatomic, retain) SPPlaybackManager* playbackManager;
@property (nonatomic, retain) SPTrack *track;
@property (nonatomic, retain) SPSearch *search;

@property (nonatomic, retain) NSMutableArray *songsInSearchQueue;

@property (nonatomic, retain) NSMutableArray *songsPlaylist;

- (void)performSearch;

- (void)playNextSongInQueue;

- (void)playTrack;

@end

@implementation SpotifyViewController

@synthesize playbackManager = _playbackManager;
@synthesize track = _track;
@synthesize search = _search;

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize loginStatusLabel = _loginStatusLabel;
@synthesize queueTextView = _queueTextView;
@synthesize currentSongLabel = _currentSongLabel;

@synthesize songsInSearchQueue = _songsInSearchQueue;
@synthesize songsPlaylist = _songsPlaylist;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//spotify:track:22WbYJtuWEHpNmTJnYGpIw
	
	const uint8_t g_appkey[] = {
		0x01, 0xC3, 0x18, 0x7F, 0x78, 0x39, 0x5F, 0x0A, 0x47, 0xCF, 0x91, 0x83, 0x0A, 0x90, 0xC2, 0xD2,
		0x2F, 0xBD, 0xAC, 0x87, 0xE6, 0x76, 0x7D, 0xD0, 0xC4, 0x40, 0xF1, 0xF9, 0xE5, 0x2D, 0x52, 0x09,
		0x79, 0xCA, 0xF9, 0x03, 0xD8, 0x08, 0x5A, 0x94, 0x01, 0xF9, 0x15, 0x3E, 0xDC, 0x65, 0x5D, 0x1B,
		0xEC, 0x6F, 0xC6, 0x39, 0x5B, 0xA3, 0x83, 0xCE, 0x34, 0x95, 0xE2, 0x8E, 0xB8, 0x6E, 0x56, 0xC2,
		0xFB, 0x64, 0x31, 0x6A, 0x19, 0xE4, 0xD1, 0x69, 0x03, 0x6F, 0x14, 0x9F, 0x35, 0x81, 0xC7, 0x0B,
		0x46, 0xA7, 0x9E, 0x22, 0x5E, 0xDB, 0x79, 0x7F, 0x9C, 0x44, 0x39, 0xE9, 0xCA, 0x83, 0xD8, 0xA4,
		0xCB, 0x2C, 0xA6, 0x1A, 0xE1, 0xDE, 0x49, 0x85, 0x0A, 0x9E, 0xFE, 0x03, 0x6C, 0x45, 0x99, 0x1F,
		0x37, 0x6C, 0x38, 0x93, 0xB9, 0x16, 0x24, 0xDF, 0xE9, 0x5F, 0xBB, 0xEC, 0x5E, 0x37, 0x16, 0x46,
		0x4C, 0x72, 0x83, 0x3E, 0xAD, 0x75, 0xB4, 0x61, 0xDD, 0xB7, 0xAA, 0xAF, 0x5D, 0xD9, 0xC6, 0x44,
		0x7E, 0xC4, 0xFE, 0xFA, 0x5F, 0xD8, 0xB0, 0xA1, 0x3A, 0xA7, 0x55, 0x1A, 0x8E, 0x5E, 0x7A, 0x76,
		0x11, 0x3D, 0x86, 0x53, 0x2F, 0xCC, 0xDA, 0xE6, 0xCE, 0x96, 0xC8, 0x30, 0xC4, 0x43, 0x9F, 0xBE,
		0x66, 0x04, 0xEF, 0x4E, 0x37, 0x66, 0x9E, 0xD8, 0x80, 0xDB, 0x50, 0xB5, 0x96, 0x3E, 0x5C, 0x94,
		0x3B, 0x39, 0x02, 0xBF, 0xAE, 0x5F, 0x11, 0x06, 0x68, 0x4E, 0x78, 0x05, 0xD8, 0xE3, 0xC4, 0x67,
		0xC6, 0x07, 0x22, 0x0B, 0x7F, 0x0A, 0x96, 0x40, 0xFF, 0x72, 0x34, 0x36, 0x1E, 0xBB, 0x67, 0xEB,
		0x35, 0xB3, 0x67, 0xAE, 0x75, 0xD6, 0xBD, 0x35, 0xB0, 0x48, 0x51, 0x20, 0x10, 0xB3, 0x88, 0x58,
		0xB1, 0x91, 0x26, 0xAD, 0xC1, 0x9A, 0x9C, 0x6B, 0x9D, 0xCF, 0xC5, 0x2F, 0xCB, 0x28, 0x7E, 0x68,
		0x57, 0x30, 0xA4, 0xF0, 0x22, 0xCC, 0xF5, 0x91, 0xE6, 0x32, 0x29, 0xAE, 0x0B, 0x71, 0x7C, 0x84,
		0x74, 0xD2, 0xB7, 0x8D, 0x4F, 0x97, 0x59, 0x4B, 0x6B, 0x33, 0x01, 0x62, 0xA1, 0xA0, 0x02, 0x2F,
		0x41, 0x06, 0xA7, 0x58, 0xDA, 0x6E, 0xA9, 0x4B, 0xDB, 0xFE, 0xAB, 0x2C, 0xB6, 0xDD, 0x96, 0x4C,
		0xE4, 0xD6, 0x1D, 0xF8, 0xA3, 0xC9, 0xDA, 0xC2, 0x99, 0xFA, 0xE9, 0x91, 0x57, 0x8B, 0x11, 0xC7,
		0xA6,
	};
	const size_t g_appkey_size = sizeof(g_appkey);
    
	if (![SPSession sharedSession]) {
		[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
												   userAgent:@"com.westinnewell.RobotDJ"
													   error:nil];
	}
    
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    
    NSURL *trackURL = [NSURL URLWithString:@"spotify:track:2f5PEKVrNEHL1X0dtMNgYu"];
    self.track = [[SPSession sharedSession] trackForURL:trackURL];
    
    self.songsInSearchQueue = [NSMutableArray array];
    [self.songsInSearchQueue addObject:@"n8chur anglerfish"];
    [self.songsInSearchQueue addObject:@"n8chur gasps and fissure"];
    [self.songsInSearchQueue addObject:@"datsik swagga"];
    [self.songsInSearchQueue addObject:@"neon steve hello"];
    [self.songsInSearchQueue addObject:@"Knife Party"];
    
    self.songsPlaylist = [NSMutableArray array];
	
	[[SPSession sharedSession] setDelegate:self];
    
    [self.search addObserver:self forKeyPath:@"searchInProgress" options:NSKeyValueObservingOptionNew context:nil];

	[[NSUserDefaults standardUserDefaults] synchronize];
    self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"Spotify.UserName"];
    self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"Spotify.Password"];
    
    [self performSearch];
}

- (void)viewDidUnload
{
    [self.search removeObserver:self forKeyPath:@"searchInProgress"];
    
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginStatusLabel:nil];
    
    [self setQueueTextView:nil];
    [self setCurrentSongLabel:nil];
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

- (void)performSearch
{
    if ( [self.songsInSearchQueue count] != 0 ) {
        self.search = [SPSearch searchWithSearchQuery:[self.songsInSearchQueue objectAtIndex:0] inSession:[SPSession sharedSession]];
        [self.songsInSearchQueue removeObjectAtIndex:0];
    }
}

- (void)playNextSongInQueue
{
    SPTrack* track = [self.songsPlaylist objectAtIndex:0];
    [self.songsPlaylist removeObject:track];
    self.track = [SPTrack trackForTrackURL:track.spotifyURL inSession:[SPSession sharedSession]];
    [self playTrack];
    
    self.currentSongLabel.text = [NSString stringWithFormat:@"%@ - %@", [(SPArtist*)[track.artists objectAtIndex:0] name], [track name]];
    self.queueTextView.text = [NSString stringWithFormat:@"%@",self.songsPlaylist];
}

- (void)playTrack
{
	// Invoked by clicking the "Play" button in the UI.
    SPTrack *track = [[SPSession sharedSession] trackForURL:self.track.spotifyURL];
    
    if (track != nil) {
        
        if (!track.isLoaded) {
            // Since we're trying to play a brand new track that may not be loaded, 
            // we may have to wait for a moment before playing. Tracks that are present 
            // in the user's "library" (playlists, starred, inbox, etc) are automatically loaded
            // on login. All this happens on an internal thread, so we'll just try again in a moment.
            [self performSelector:@selector(playTrack:) withObject:nil afterDelay:0.1];
            return;
        }
        
        NSError *error = nil;
        
        if (![self.playbackManager playTrack:track error:&error]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        self.track = track;
        return;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
													message:@"Please enter a track URL"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"searchInProgress"]) {
        NSLog(@"searchInProgress: %i", self.search.searchInProgress);
        if ( self.search.searchInProgress == NO ) {
            NSLog(@"Session did change meta data. tracks in search: %@", self.search.tracks);
            if ( [self.search.tracks count] > 0 ) {
                [self.songsPlaylist addObject:[self.search.tracks objectAtIndex:0]];
                if ( !self.playbackManager.isPlaying ) {
                    [self playNextSongInQueue];
                }
            }
            else {
                NSLog(@"Done finding tracks!");
            }
            
            if ( [self.songsInSearchQueue count] > 0 ) {
                [self performSearch];
            }
            self.queueTextView.text = [NSString stringWithFormat:@"%@",self.songsPlaylist];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == self.usernameTextField ) {
        [self.passwordTextField becomeFirstResponder];
    }
    else {
		[[NSUserDefaults standardUserDefaults] setValue:self.usernameTextField.text forKey:@"Spotify.UserName"];
		[[NSUserDefaults standardUserDefaults] setValue:self.passwordTextField.text forKey:@"Spotify.Password"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
        [[SPSession sharedSession] attemptLoginWithUserName:self.usernameTextField.text password:self.passwordTextField.text rememberCredentials:YES];
        
        [textField resignFirstResponder];
        if ( !self.search.searchInProgress ) {
            [self performSearch];
        }
    }
    return NO;
}

#pragma mark - SPSessionDelegate Protocol

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession
{
	NSLog(@"Successfull login");
    
    self.loginStatusLabel.text = @"Login Success!";
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error
{
	NSLog(@"Error login: %@", [error localizedDescription]);
}

- (void)sessionDidChangeMetadata:(SPSession *)aSession
{
    NSLog(@"Metadata changed.");
}

- (void)sessionDidLosePlayToken:(SPSession *)aSession
{
	NSLog(@"sessionDidLosePlayToken");
}

- (void)sessionDidEndPlayback:(SPSession *)aSession
{
	NSLog(@"sessionDidEndPlayback");
    
    [self playNextSongInQueue];
}

- (NSInteger)session:(SPSession *)aSession shouldDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount format:(const sp_audioformat *)audioFormat
{
	NSLog(@"shouldDeliverAudioFrames: %d", frameCount);
	return frameCount;
}

- (void)session:(SPSession *)aSession didEncounterStreamingError:(NSError *)error
{
	NSLog(@"didEncounterStreamingError");	
}

@end
