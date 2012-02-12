//
//  EchonestViewController.h
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EchonestViewController : UIViewController <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *endpointTextField;
@property (retain, nonatomic) IBOutlet UITextField *parameterTextField;
@property (retain, nonatomic) IBOutlet UITextField *valueTextField;
@property (retain, nonatomic) IBOutlet UITextView *responseTextView;

- (IBAction)sendButtonPressed:(id)sender;

@end
