//
//  SpotifyViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CocoaLibSpotify.h"

@interface SpotifyViewController : UIViewController <SPSessionDelegate, SPSessionPlaybackDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) SPTrack *track;
@property (retain, nonatomic) IBOutlet UIButton *checkTrackButton;
@property (retain, nonatomic) IBOutlet UIButton *playTrackButton;
@property (retain, nonatomic) IBOutlet UILabel *loginStatusLabel;

- (IBAction)checkTrack:(id)sender;
- (IBAction)playTrack:(id)sender;

@end
