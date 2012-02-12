//
//  BonjourViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BonjourClient.h"
#import "BonjourServer.h"
#import <GameKit/GameKit.h>

@interface BonjourViewController : UIViewController 
- (IBAction)hostButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;
- (IBAction)connectButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) BonjourServer *server;
@property (strong, nonatomic) BonjourClient *client;

@property (strong, nonatomic) GKSession *session;

@end
