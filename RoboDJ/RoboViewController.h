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

- (IBAction)mixerSliderValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *volumeALabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeBLabel;


- (IBAction)playAButtonPressed:(id)sender;
- (IBAction)playBButtonPressed:(id)sender;

- (IBAction)stopAButtonPressed:(id)sender;
- (IBAction)stopBButtonPressed:(id)sender;

@end
