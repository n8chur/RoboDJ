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

@property (nonatomic, retain) SPPlaybackManager* playbackManager;
@property (nonatomic, retain) SPTrack *currentTrack;
@property (nonatomic, retain) SPSearch *search;

@property (nonatomic, retain) NSMutableArray *songsInSearchQueue;

@property (nonatomic, retain) NSMutableArray *songsPlaylist;

@property (nonatomic, retain) NSMutableArray *hostsUserSongs;

@property (nonatomic, retain) NSMutableArray *combinedSongs;

@property (nonatomic, retain) NSDictionary *likesAndDislikes;

@property (nonatomic, retain) NSMutableSet *previouslySearchedTracks;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.songsInSearchQueue = [NSMutableArray array];
    self.songsPlaylist = [NSMutableArray array];
    self.previouslySearchedTracks = [NSMutableSet set];
    
    self.likesAndDislikes = [NSDictionary dictionaryWithObjectsAndKeys:
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
    
    [self addObserver:self forKeyPath:@"search.searchInProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:NSKeyValueObservingOptionNew context:nil];
    
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    [[SPSession sharedSession] setDelegate:self];
    
    for ( NSUInteger i = 0; i < 25; i++ ) {
        [self.songsInSearchQueue addObject:[self.hostsUserSongs objectAtIndex:i]];
    }
    self.combinedSongs = [NSMutableArray array];
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
    
    [self performSearch];
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
    }
    else {
        NSNumber* dislikes = [self.likesAndDislikes objectForKey:@"dislikes"];
        dislikes = [NSNumber numberWithUnsignedInteger:[dislikes unsignedIntegerValue]+1];
    }
    
}

- (void)combineListAndRequestNewPlaylist:(NSArray*)newClientList
{
    // add newClientList to self.combinedSongs (update keys to reflect number inside)
    // compare self.hostsUserSongs with newClientList
    // return 
    
    for ( NSString* string in newClientList ) {
        for ( NSMutableSet* set in self.combinedSongs ) {
            if ( [set containsObject:string] ) {
                [set removeObject:string];
                NSMutableSet* setAtNextIndex = [self.combinedSongs objectAtIndex:[self.combinedSongs indexOfObject:set]];
                if ( setAtNextIndex == nil ) {
                    [setAtNextIndex addObject:string];
                    [self.combinedSongs addObject:setAtNextIndex];
                }
                else {
                    [setAtNextIndex addObject:string];
                }
            }
            else {
                [set addObject:string];
            }
        }
    }
    NSUInteger maxSearchCount = 25;
    NSUInteger searchCount = maxSearchCount;
    NSUInteger i = [self.combinedSongs indexOfObject:[self.combinedSongs lastObject]];
    while ( i > 0 ) {
        NSMutableSet* set = [self.combinedSongs objectAtIndex:i];
        for ( NSString * string in set ) {
            [self.songsInSearchQueue insertObject:string atIndex:0];
        }
        i --;
        searchCount --;
    }
    if ( searchCount == maxSearchCount - 1 ) {
        [self performSearch];
    }
    else {
        NSLog(@"No matches!");
    }
}

- (void)performSearch
{
    if ( [self.songsInSearchQueue count] != 0 ) {
        NSString* searchString = [self.songsInSearchQueue objectAtIndex:0];
        if ( [self.previouslySearchedTracks containsObject:searchString] == NO ) {
            [self.previouslySearchedTracks addObject:searchString];
            self.search = [SPSearch searchWithSearchQuery:searchString inSession:[SPSession sharedSession]];
        }
        else {
            [self performSearch];
        }
        [self.songsInSearchQueue removeObjectAtIndex:0];
        
    }
}

- (void)playNextSongInQueue
{
    SPTrack* track = [self.songsPlaylist objectAtIndex:0];
    
    [self.songsPlaylist removeObject:track];
    [self.tableView reloadData];
    
    self.currentTrack = [SPTrack trackForTrackURL:track.spotifyURL inSession:[SPSession sharedSession]];
    [self playTrack];
    
    long nearestSecond = lroundf( (Float32)self.playbackManager.currentTrack.duration );
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", nearestSecond / 60, nearestSecond % 60];
    
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"search.searchInProgress"]) {
        if ( self.search.searchInProgress == NO ) {
            if ( [self.search.tracks count] > 0 ) {
                
                [self.songsPlaylist addObject:[self.search.tracks objectAtIndex:0]];
                [self.tableView reloadData];
                
                if ( !self.playbackManager.isPlaying ) {
                    [self playNextSongInQueue];
                }
            }
            else {
                NSLog(@"Done finding tracks!");
                
                if ( [self.songsPlaylist count] < 5 ) {
                    [self performSearch];
                }
            }
            
            if ( [self.songsInSearchQueue count] > 0 ) {
                [self performSearch];
            }
        }
    }
    if ( [keyPath isEqualToString:@"playbackManager.trackPosition"] ) {
        long nearestSecond = lroundf( (Float32)self.playbackManager.trackPosition );
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", nearestSecond / 60, nearestSecond % 60];
        
        self.progressView.progress = self.playbackManager.trackPosition / self.playbackManager.currentTrack.duration;
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

@end