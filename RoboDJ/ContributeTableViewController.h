//
//  ContributeViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface ContributeViewController : UITableViewController <GKSessionDelegate>

@property (strong, nonatomic) GKSession *session;
@property (strong, nonatomic) NSString *serverPeerID;

@end
