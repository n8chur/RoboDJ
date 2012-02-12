//
//  BonjourClient.h
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BonjourClient : NSObject <NSNetServiceBrowserDelegate>

@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;

- (void)searchAndConnect;

@end
