//
//  SpotifyViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpotifyViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

@property (retain, nonatomic) IBOutlet UILabel *loginStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView *queueTextView;
@property (weak, nonatomic) IBOutlet UILabel *currentSongLabel;
- (IBAction)skipButtonPressed:(id)sender;

@end
