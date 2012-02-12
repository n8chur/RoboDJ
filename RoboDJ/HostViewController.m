//
//  HostViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "HostViewController.h"
#import "CocoaLibSpotify.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SPPlaybackManager.h"

@interface HostViewController () <SPSessionDelegate, SPSessionPlaybackDelegate>

- (void)shuffleMutableArray:(NSMutableArray*)mutableArray;

@property (nonatomic, retain) SPPlaybackManager* playbackManager;
@property (nonatomic, retain) SPTrack *currentTrack;
@property (nonatomic, retain) SPSearch *search;

@property (nonatomic, retain) NSMutableArray *songsInSearchQueue;

@property (nonatomic, retain) NSMutableArray *songsPlaylist;

@property (nonatomic, retain) NSMutableArray *hostsUserSongs;

@property (nonatomic, retain) NSCountedSet *combinedSongs;

@property (nonatomic, retain) NSMutableDictionary *likesAndDislikes;

@property (nonatomic, retain) NSMutableSet *previouslySearchedTracks;

@property (nonatomic, retain) NSMutableSet *previouslyQueuedTracks;

@property (nonatomic, retain) NSString* lastSearch;

- (void)playNextSongInQueue;
- (void)performSearch;
- (void)playTrack;

- (void)combineListAndRequestNewPlaylist:(NSArray*)newClientList;

- (void)newFeedbackRecieved:(BOOL)isGood;

@end

@implementation HostViewController
@synthesize songNameLabel;
@synthesize progressView;
@synthesize currentTimeLabel;
@synthesize totalTimeLabel;
@synthesize contributorsLabel;
@synthesize likesLabel;
@synthesize dislikesLabel;
@synthesize tableView;

@synthesize playbackManager = _playbackManager;
@synthesize currentTrack = _currentTrack;
@synthesize search = _search;

@synthesize songsInSearchQueue = _songsInSearchQueue;
@synthesize songsPlaylist = _songsPlaylist;
@synthesize hostsUserSongs = _hostsUserSongs;
@synthesize combinedSongs = _combinedSongs;
@synthesize likesAndDislikes = _likesAndDislikes;
@synthesize previouslySearchedTracks = _previouslySearchedTracks;
@synthesize session = _session;
@synthesize lastSearch = _lastSearch;
@synthesize previouslyQueuedTracks = _previouslyQueuedTracks;

- (void)sendDataToClients:(NSString*)type object:(NSObject*)object
{
	NSError *error = NULL;
	
	NSDictionary *dataToSend = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type", object, @"object", nil];
	
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataToSend options:0 error:&error];
	
	if (jsonData) {
	}
	else {
		NSLog(@"Data (%@) non JSONed. Failed.", type);
		return;
	}
	
	if ([self.session sendDataToAllPeers:jsonData withDataMode:GKSendDataReliable error:&error]) {
	}
	else {
		NSLog(@"Fail to send data (%@): %@", type, [error localizedDescription]);
	}
}

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

- (void)sendPlaylist
{
	NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:[self.songsPlaylist count]];
	for (SPTrack* track in self.songsPlaylist) {
		NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:track.name, @"name", [(SPArtist*)[track.artists objectAtIndex:0] name], @"artist", nil];
		[tracks addObject:trackDict];
	}
	
	NSDictionary *playlist = [NSDictionary dictionaryWithObjectsAndKeys:tracks, @"tracks", nil];
	
	[self sendDataToClients:@"playlist" object:playlist];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.songsInSearchQueue = [NSMutableArray array];
    self.songsPlaylist = [NSMutableArray array];
    self.previouslySearchedTracks = [NSMutableSet set];
    self.previouslyQueuedTracks = [NSMutableSet set];
    
    self.likesAndDislikes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithUnsignedInteger:0], @"likes", 
                             [NSNumber numberWithUnsignedInteger:0], @"dislikes",
                             nil];
    
    MPMediaQuery* mediaQuery = [MPMediaQuery songsQuery];
    
    self.hostsUserSongs = [NSMutableArray array];
    
    NSArray* tempArray = [mediaQuery items];
    for ( MPMediaItem* mediaItem in tempArray ) {
        NSString* song = [NSString stringWithFormat:@"%@ - %@", [mediaItem valueForProperty:MPMediaItemPropertyArtist], [mediaItem valueForProperty:MPMediaItemPropertyTitle]];
        [self.hostsUserSongs addObject:song];
    }
    [self shuffleMutableArray:self.hostsUserSongs];
    
    [self addObserver:self forKeyPath:@"search.searchInProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:NSKeyValueObservingOptionNew context:nil];
    
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    [[SPSession sharedSession] setDelegate:self];
    
    for ( NSUInteger i = 0; i < 25; i++ ) {
        [self.songsInSearchQueue addObject:[self.hostsUserSongs objectAtIndex:i]];
    }
    [self shuffleMutableArray:self.hostsUserSongs];
    
    self.combinedSongs = [NSCountedSet set];
    NSMutableSet* set = [NSMutableSet set];
    for ( NSString* string in self.hostsUserSongs ) {
        [set addObject:string];
    }
    [self.combinedSongs addObject:set];
    
    self.currentTimeLabel.text = @"0:00";
    self.totalTimeLabel.text = @"0:00";
    self.contributorsLabel.text = @"0";
    self.likesLabel.text = @"0";
    self.dislikesLabel.text = @"0";
    self.progressView.progress = 0.0f;
    self.songNameLabel.text = @"Loading...";
    
    [self performSelectorInBackground:@selector(performSearch) withObject:nil];
	
	self.session = [[GKSession alloc] initWithSessionID:@"_robotDJ.tcp." displayName:[[UIDevice currentDevice] name] sessionMode:GKSessionModeServer];
	self.session.delegate = self;
	self.session.available = YES;
	
	NSLog(@"session: %@", self.session);
	NSLog(@"name: %@", self.session.displayName);
	NSLog(@"peedID: %@", self.session.peerID);
	NSLog(@"sessionID: %@", self.session.sessionID);
	NSLog(@"mode: %d", self.session.sessionMode);
	
	[self.session setDataReceiveHandler:self withContext:NULL];
}

- (void)viewDidUnload
{
    [self removeObserver:self forKeyPath:@"search.searchInProgress"];
    [self removeObserver:self forKeyPath:@"playbackManager.trackPosition"];
    
    [self setProgressView:nil];
    [self setCurrentTimeLabel:nil];
    [self setTotalTimeLabel:nil];
    [self setContributorsLabel:nil];
    [self setLikesLabel:nil];
    [self setDislikesLabel:nil];
    [self setSongNameLabel:nil];
    self.hostsUserSongs = nil;
    self.songsPlaylist = nil;
    self.songsInSearchQueue = nil;
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

- (IBAction)skipButtonPressed:(id)sender {
    [self.playbackManager setIsPlaying:NO];
    [self playNextSongInQueue];
}

- (void)newFeedbackRecieved:(BOOL)isGood
{
    if ( isGood ) {
        NSNumber* likes = [self.likesAndDislikes objectForKey:@"likes"];
        likes = [NSNumber numberWithUnsignedInteger:[likes unsignedIntegerValue]+1];
		[self.likesAndDislikes setValue:likes forKey:@"likes"];
		[self.likesLabel setText:[NSString stringWithFormat:@"%d", [likes integerValue]]];
    }
    else {
        NSNumber* dislikes = [self.likesAndDislikes objectForKey:@"dislikes"];
        dislikes = [NSNumber numberWithUnsignedInteger:[dislikes unsignedIntegerValue]+1];
		[self.likesAndDislikes setValue:dislikes forKey:@"dislikes"];
		[self.dislikesLabel setText:[NSString stringWithFormat:@"%d", [dislikes integerValue]]];
    }
    
}

- (void)addSearches
{
    for (id object in self.combinedSongs) { 
        [self.songsInSearchQueue addObject:object];        
//        for (NSUInteger i = 0; i < [self.combinedSongs countForObject:object]; i++) {
//            
//         }
    }
    [self performSelectorInBackground:@selector(performSearch) withObject:nil];
}

- (void)combineListAndRequestNewPlaylist:(NSArray*)newClientList
{
    // add newClientList to self.combinedSongs (update keys to reflect number inside)
    // compare self.hostsUserSongs with newClientList
    // return 
    NSLog(@"count before: %i", [self.combinedSongs count]);
    NSLog(@"Combining with new library (%d songs)", [newClientList count]);
    
    NSLog(@"newClientList: %@", newClientList);    
    for ( NSString* string in newClientList ) {
        [self.combinedSongs addObject:string];
    }
    
    NSLog(@"count after: %i", [self.combinedSongs count]);
    [self addSearches];
}

- (void)performSearch
{
    if ( self.search.searchInProgress ) {
        [self performSelector:@selector(performSearch) withObject:nil afterDelay:2.0f];
    }
    else {
        if ( [self.songsInSearchQueue count] != 0 ) {
            NSString* searchString = [self.songsInSearchQueue objectAtIndex:0];
            NSLog(@"searchString: %@", searchString);
            if ( searchString != self.lastSearch ) {
                if ( searchString ) {
                    if ( [self.previouslySearchedTracks containsObject:searchString] == NO ) {
                        [self.previouslySearchedTracks addObject:searchString];
                        self.search = [SPSearch searchWithSearchQuery:searchString inSession:[SPSession sharedSession]];
                        NSLog(@"new search");
                        [self.songsInSearchQueue removeObjectAtIndex:0];
                    }
                    else {
                        [self.songsInSearchQueue removeObjectAtIndex:0];
                        [self performSearch];
                        NSLog(@"already searched");
                    }
                }
                else {
                    [self.songsInSearchQueue removeObjectAtIndex:0];
                    [self performSearch];
                    NSLog(@"Search string invalid");
                }
            }
            else {
                [self performSelector:@selector(performSearch) withObject:nil afterDelay:2.0f];
            }
            
        }
    }
}

- (void)playNextSongInQueue
{
    SPTrack* track = [self.songsPlaylist objectAtIndex:0];
    
    [self.songsPlaylist removeObject:track];
    [self.tableView reloadData];
	[self sendPlaylist];
    
    self.currentTrack = [SPTrack trackForTrackURL:track.spotifyURL inSession:[SPSession sharedSession]];
    [self playTrack];
    
    long nearestSecond = lroundf( (Float32)self.playbackManager.currentTrack.duration );
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", nearestSecond / 60, nearestSecond % 60];
    
    self.songNameLabel.text = [NSString stringWithFormat:@"%@ - %@", [(SPArtist*)[track.artists objectAtIndex:0] name], [track name]];
    
    if ( [self.songsInSearchQueue count] < 2 && [self.songsPlaylist count] < 10 ) {
        [self addSearches];
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"search.searchInProgress"]) {
        if ( self.search.searchInProgress == NO ) {
            if ( [self.search.tracks count] > 0 ) {
                if ( [self.previouslyQueuedTracks containsObject:[self.search.tracks objectAtIndex:0]] == NO ) {
                    [self.songsPlaylist insertObject:[self.search.tracks objectAtIndex:0] atIndex:0];
                    [self.previouslyQueuedTracks addObject:[self.search.tracks objectAtIndex:0]];
                    [self.tableView reloadData];
					[self sendPlaylist];
                }
                
                if ( !self.playbackManager.isPlaying ) {
                    [self playNextSongInQueue];
                }
            }
            else {
                if ( [self.songsPlaylist count] < 50 ) {
                    [self performSelectorInBackground:@selector(performSearch) withObject:nil];
                }
            }
            
            if ( [self.songsInSearchQueue count] > 0 ) {
                [self performSelectorInBackground:@selector(performSearch) withObject:nil];
            }
        }
    }
    if ( [keyPath isEqualToString:@"playbackManager.trackPosition"] ) {
        long nearestSecond = lroundf( (Float32)self.playbackManager.trackPosition );
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", nearestSecond / 60, nearestSecond % 60];
        
        self.progressView.progress = self.playbackManager.trackPosition / self.playbackManager.currentTrack.duration;
		
		NSDictionary *timeInfos = [NSDictionary dictionaryWithObjectsAndKeys:self.currentTimeLabel.text, @"currentTimeLabel", [NSNumber numberWithFloat:self.progressView.progress], @"progress",  self.totalTimeLabel.text, @"totalTimeLabel", self.songNameLabel.text, @"songNameLabel", nil];
		[self sendDataToClients:@"timeInfos" object:timeInfos];
    }
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.songsPlaylist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SPTrack* track = [self.songsPlaylist objectAtIndex:indexPath.row];
    
    cell.textLabel.text = track.name;
    cell.detailTextLabel.text = [(SPArtist*)[track.artists objectAtIndex:0] name];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
// Return NO if you do not want the specified item to be editable.
return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
    {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.songsPlaylist removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// // Override to support rearranging the table view.
// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
// {
// }
 

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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

- (void)sessionDidEndPlayback:(id<SPSessionPlaybackProvider>)aSession
{
    [self skipButtonPressed:nil];
}

#pragma mark - Data Handler

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	NSError *error = NULL;
	NSDictionary* receivedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (receivedData) {
		NSString *type = [receivedData objectForKey:@"type"];
		NSObject *object = [receivedData objectForKey:@"object"];
		
		if ([type isEqualToString:@"likeSong"]) {
			NSLog(@"Like Song");
			[self newFeedbackRecieved:YES];
		}
		else if ([type isEqualToString:@"dislikeSong"]) {
			NSLog(@"Dislike song");
			[self newFeedbackRecieved:NO];
		}
		else if ([type isEqualToString:@"clientLibrary"]) {
			NSLog(@"Client library");
			[self combineListAndRequestNewPlaylist:(NSArray*)object];
		}
		else {
			NSLog(@"Unknown!!!!");
		}
	}
}

@end
