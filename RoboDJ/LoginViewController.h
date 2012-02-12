//
//  LoginViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface LoginViewController : UIViewController <GKSessionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)usernameTextFieldDidEndEditing:(id)sender;
- (IBAction)passwordTextFieldDidEndEditing:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;


@property (strong, nonatomic) GKSession *session;

@end
