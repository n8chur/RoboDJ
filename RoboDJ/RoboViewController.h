//
//  RoboViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoboViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *mixerSlider;

@property (weak, nonatomic) IBOutlet UILabel *volumeALabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeBLabel;

- (IBAction)startButtonPressed:(id)sender;

@end
