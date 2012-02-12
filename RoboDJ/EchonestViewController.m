//
//  EchonestViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "EchonestViewController.h"
#import "ENAPIRequest.h"

@interface EchonestViewController () <ENAPIRequestDelegate>

@property (nonatomic, retain) ENAPIRequest* enapiRequest;
@property (nonatomic, retain) NSMutableArray* enapiResults;

@end

@implementation EchonestViewController
@synthesize tableView = _tableView;
@synthesize endpointTextField = _queryTextField;
@synthesize parameterTextField = _parameterTextField;
@synthesize valueTextField = _valueTextField;

@synthesize enapiRequest = _enapiRequest;
@synthesize enapiResults = _enapiResults;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.enapiResults = [NSMutableArray array];
    
}

- (void)viewDidUnload
{
    [self setEnapiResults:nil];
    [self setEndpointTextField:nil];
    [self setParameterTextField:nil];
    [self setValueTextField:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    self.enapiRequest = nil;
    [self setEnapiResults:nil];
    [super dealloc];
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

- (IBAction)sendButtonPressed:(id)sender {
    
    if ( self.enapiRequest != nil && !self.enapiRequest.complete ) {
        [self.enapiRequest cancel];
        [self.enapiRequest release];
        self.enapiRequest = nil;
    }
    
    self.enapiRequest = [[ENAPIRequest alloc] initWithEndpoint:self.endpointTextField.text];
    [self.enapiRequest setValue:self.valueTextField.text forParameter:self.parameterTextField.text];
    self.enapiRequest.delegate = self;
    [self.enapiRequest startAsynchronous];
    
    [self.parameterTextField resignFirstResponder];
    [self.valueTextField resignFirstResponder];
    [self.endpointTextField resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return the current number of `artist/suggest` results
    return self.enapiResults.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
	// Set up the cell with the artist's name.
    NSDictionary *artist = [self.enapiResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [artist valueForKey:self.parameterTextField.text];
    return cell;
}

#pragma mark - ENAPIRequestDelegate

- (void)requestFinished:(ENAPIRequest *)request {
	// The Echo Nest server has repsonded. 
	
	// There are handy accessors for the Echo Nest status
	// code and status message
	if (0 != request.echonestStatusCode) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Echo Nest Error", @"")
														message:request.echonestStatusMessage
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[request release];
		return;
	}
    NSArray *artists = [request.response valueForKeyPath:@"response.artists"];
    [self.enapiResults removeAllObjects];
    for (int ii=0; ii<artists.count; ++ii) {
        [self.enapiResults addObject:[artists objectAtIndex:ii]];        
    }
    self.enapiRequest = nil;
    NSLog(@"self.enapiResults: %@", self.enapiResults);
    [self.tableView reloadData];
    [request release];
}

- (void)requestFailed:(ENAPIRequest *)request {
    // The request or connection failed at a low level, use
	// the request's error property to get information on the
	// failure
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Error", @"")
													message:[request.error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK", @"")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[request release];	
}

@end
