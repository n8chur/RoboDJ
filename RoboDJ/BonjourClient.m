//
//  BonjourClient.m
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "BonjourClient.h"

@implementation BonjourClient

@synthesize netServiceBrowser = _netServiceBrowser;

- (id)init
{
	self = [super init];
	if (self) {
		self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
		self.netServiceBrowser.delegate = self;
	}
	return self;
}

- (void)searchAndConnect
{
	NSLog(@"Start search...");
	[self.netServiceBrowser searchForServicesOfType:@"_robotDJ._tcp." inDomain:@"local"];
}

#pragma mark - NSNetServiceBrowserDelegate Protocol

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	NSLog(@"Found server: %@", aNetService);
}

@end
