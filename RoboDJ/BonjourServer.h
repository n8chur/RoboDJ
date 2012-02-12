//
//  BonjourServer.h
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BonjourServer : NSObject <NSNetServiceDelegate>

@property (nonatomic, strong) NSNetService* netService;

- (void)run;

@end
