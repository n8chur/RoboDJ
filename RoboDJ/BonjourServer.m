//
//  BonjourServer.m
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "BonjourServer.h"

@implementation BonjourServer

@synthesize netService = _netService;

- (id)init
{
	self = [super init];
	if (self) {
		self.netService = [[NSNetService alloc] initWithDomain:@"local" type:@"_robotDJ._tcp." name:@"RobotDJ" port:46969];
		self.netService.delegate = self;

	}
	return self;
}

- (void)run
{
	NSLog(@"Service publishing (%@)...", self.netService);
	[self.netService publish];
	[self.netService resolveWithTimeout:10.0f];
}

#pragma mark - NSNetServiceDelegate Protocol

- (void)netServiceWillPublish:(NSNetService *)sender
{
	NSLog(@"Service is going to be published...?");
}

- (void)netServiceDidPublish:(NSNetService *)sender
{
	NSLog(@"Service published");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	NSLog(@"Service published FAILED");
}

- (void)netServiceDidStop:(NSNetService *)sender
{
	NSLog(@"Service stoped");	
}

@end
