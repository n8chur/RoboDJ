//
//  BonjourViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "BonjourViewController.h"
#import <Foundation/NSNetServices.h>

@interface BonjourViewController () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, retain) NSNetServiceBrowser* netServiceBrowser;

@property (nonatomic, retain) NSNetService* netService;

@property (nonatomic, retain) NSMutableArray* services;

@end

@implementation BonjourViewController
@synthesize connectButton = _connectButton;

@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize netService = _netService;
@synthesize services = _services;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.delegate = self;
    
    self.netService = [[NSNetService alloc] initWithDomain:@"local" type:@"_http._tcp." name:@"RoboDJ" port:46969];
    
    self.services = [NSMutableArray array];
}

- (void)viewDidUnload
{
    [self setConnectButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (IBAction)hostButtonPressed:(id)sender {
    [self.netService publish];
}

- (IBAction)searchButtonPressed:(id)sender {
    NSLog(@"currently available services: %@", self.services);
    [self.netServiceBrowser searchForServicesOfType:@"_http._tcp" inDomain:@"local"];
}

- (IBAction)connectButtonPressed:(id)sender {
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService: %@", service);
    [self.services removeObject:service];
    if ([service.name isEqualToString:@"RoboDJ"]) {
        self.connectButton.hidden = YES;
    }
}	


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didFindService: %@", service);
    [self.services addObject:service];
    
    if ([service.name isEqualToString:@"RoboDJ"]) {
        self.connectButton.hidden = NO;
    }
}	


- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve");
}


- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"didResolveAddress");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"didPublish");
}
@end
