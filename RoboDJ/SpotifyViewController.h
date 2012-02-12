//
//  SpotifyViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CocoaLibSpotify.h"

@interface SpotifyViewController : UIViewController <SPSessionDelegate, SPSessionPlaybackDelegate>

@property (nonatomic, retain) SPTrack *track;

- (IBAction)checkTrack:(id)sender;
- (IBAction)playTrack:(id)sender;

@end
