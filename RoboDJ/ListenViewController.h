//
//  ListenViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListenViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)likeButtonPressed:(id)sender;
- (IBAction)dislikeButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *contributorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dislikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
