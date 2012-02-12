//
//  ListenViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "ListenViewController.h"
#import "CocoaLibSpotify.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SPPlaybackManager.h"

@interface ListenViewController () <SPSessionDelegate, SPSessionPlaybackDelegate>

@property (nonatomic, retain) SPPlaybackManager* playbackManager;
@property (nonatomic, retain) SPTrack *currentTrack;

@property (nonatomic, retain) NSMutableArray *songsPlaylist;

@property (nonatomic, retain) NSMutableArray *clientUserSongs;

- (void)playNextSongInQueue;
- (void)playTrack;

- (void)shuffleMutableArray:(NSMutableArray*)mutableArray;

@end

@implementation ListenViewController

@synthesize currentTimeLabel;
@synthesize totalTimeLabel;
@synthesize progressView;
@synthesize contributorsLabel;
@synthesize likesLabel;
@synthesize dislikesLabel;
@synthesize tableView;
@synthesize songNameLabel;

@synthesize playbackManager = _playbackManager;
@synthesize currentTrack = _currentTrack;
@synthesize songsPlaylist = _songsPlaylist;
@synthesize clientUserSongs = _clientUserSongs;

@synthesize serverPeerID = _serverPeerID;
@synthesize session = _session;

- (void)shuffleMutableArray:(NSMutableArray*)mutableArray
{
    static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom(time(NULL));
    }
    
    NSUInteger count = [mutableArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

#pragma mark - View lifecycle

- (void)sendDataToServer:(NSString*)type object:(NSObject*)object
{
	NSError *error = NULL;

	NSDictionary *dataToSend = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type", object, @"object", nil];
	
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataToSend options:0 error:&error];
	
	if (jsonData) {
		NSLog(@"Data (%@) successfully JSONed: size: %d", type, [jsonData length]);
	}
	else {
		NSLog(@"Data (%@) non JSONed. Failed.", type);
		return;
	}
	
	if ([self.session sendData:jsonData toPeers:[NSArray arrayWithObject:self.serverPeerID] withDataMode:GKSendDataReliable error:&error]) {
		NSLog(@"Data (%@) successfully sent", type);
	}
	else {
		NSLog(@"Fail to send data (%@): %@", type, [error localizedDescription]);
	}
}

- (void)sendClientLibrary
{
	[self sendDataToServer:@"clientLibrary" object:self.clientUserSongs];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	self.session = appDelegate.session;
	self.serverPeerID = appDelegate.serverPeerID;
	
	self.session.delegate = self;
	
	NSLog(@"Listen with session: %@ and server: %@ (%@)", self.session, self.serverPeerID, [self.session displayNameForPeer:self.serverPeerID]);
	
	[self.session connectToPeer:self.serverPeerID withTimeout:10.0f];
    
    self.songsPlaylist = [NSMutableArray array];
    
    MPMediaQuery* mediaQuery = [MPMediaQuery songsQuery];
    
    self.clientUserSongs = [NSMutableArray array];
    
    NSArray* tempArray = [mediaQuery items];
    for ( MPMediaItem* mediaItem in tempArray ) {
        NSString* song = [NSString stringWithFormat:@"%@ - %@", [mediaItem valueForProperty:MPMediaItemPropertyArtist], [mediaItem valueForProperty:MPMediaItemPropertyTitle]];
        [self.clientUserSongs addObject:song];
    }
    
    [self shuffleMutableArray:self.clientUserSongs];
    
    [self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:NSKeyValueObservingOptionNew context:nil];
    
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    [[SPSession sharedSession] setDelegate:self];
    
    self.currentTimeLabel.text = @"0:00";
    self.totalTimeLabel.text = @"0:00";
    self.contributorsLabel.text = @"0";
    self.likesLabel.text = @"0";
    self.dislikesLabel.text = @"0";
    self.progressView.progress = 0.0f;
    self.songNameLabel.text = @"Loading...";
    
    // TODO: (connect to host and send) send songs to host
	
	[self.session setDataReceiveHandler:self withContext:NULL];
	
	[self performSelector:@selector(sendClientLibrary) withObject:nil afterDelay:1.0f];
}

- (void)viewDidUnload
{
    [self setContributorsLabel:nil];
    [self setLikesLabel:nil];
    [self setDislikesLabel:nil];
    [self setProgressView:nil];
    [self setCurrentTimeLabel:nil];
    [self setTotalTimeLabel:nil];
    [self setSongNameLabel:nil];
    [self setTableView:nil];
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

- (void)playNextSongInQueue
{
    SPTrack* track = [self.songsPlaylist objectAtIndex:0];
    [self.songsPlaylist removeObject:track];
    self.currentTrack = [SPTrack trackForTrackURL:track.spotifyURL inSession:[SPSession sharedSession]];
    [self playTrack];
    
    long nearestSecond = lroundf( (Float32)self.playbackManager.currentTrack.duration );
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", nearestSecond / 60, nearestSecond % 60];
    
    [self.tableView reloadData];
    
    self.songNameLabel.text = [NSString stringWithFormat:@"%@ - %@", [(SPArtist*)[track.artists objectAtIndex:0] name], [track name]];
}

- (void)playTrack
{
	// Invoked by clicking the "Play" button in the UI.
    SPTrack *track = [[SPSession sharedSession] trackForURL:self.currentTrack.spotifyURL];
    
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
        self.currentTrack = track;
        return;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
													message:@"Please enter a track URL"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark - UITableView stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = @"Song Title";
    cell.detailTextLabel.text = @"Artist Name";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}


- (IBAction)likeButtonPressed:(id)sender {
	[self sendDataToServer:@"likeSong" object:[NSNumber numberWithBool:YES]];
}

- (IBAction)dislikeButtonPressed:(id)sender {
	[self sendDataToServer:@"dislikeSong" object:[NSNumber numberWithBool:YES]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

}

#pragma mark - Data Handler

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	NSLog(@"Received data from %@ (%@) size %d", peer, [session displayNameForPeer:peer], [data length]);
}


#pragma mark - GKSessionDelegate Protocol

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	NSLog(@"DidChangeState");
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSLog(@"didReceiveConnectionRequestFromPeer: %@ (%@)", peerID, [self.session displayNameForPeer:peerID]);
	NSError *error = NULL;
	if ([self.session acceptConnectionFromPeer:peerID error:&error]) {
		NSLog(@"Connection to peer successfull");
	}
	else {
		NSLog(@"Connection to peer fail: %@", [error localizedDescription]);
	}
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError");
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"connectionWithPeerFailed");
}

@end
