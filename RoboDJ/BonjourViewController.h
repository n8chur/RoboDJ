//
//  BonjourViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BonjourViewController : UIViewController 
- (IBAction)hostButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;
- (IBAction)connectButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end
