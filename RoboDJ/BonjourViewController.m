//
//  BonjourViewController.m
//  RoboDJ
//
//  Created by Westin Newell on 2/12/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "BonjourViewController.h"
#import <Foundation/NSNetServices.h>

#define kRoboDJName @"RoboDJ"
#define kRoboDJPort 46969

@interface BonjourViewController () <NSNetServiceBrowserDelegate, NSNetServiceDelegate, NSStreamDelegate>

@property (nonatomic, retain) NSNetServiceBrowser* netServiceBrowser;

@property (nonatomic, retain) NSNetService* netService;

@property (nonatomic, retain) NSMutableArray* services;

@end

@implementation BonjourViewController
@synthesize connectButton = _connectButton;
@synthesize searchButton = _searchButton;

@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize netService = _netService;
@synthesize services = _services;
@synthesize server = _server;
@synthesize client = _client;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
//    self.netServiceBrowser.delegate = self;
    
//    self.netService = [[NSNetService alloc] initWithDomain:@"local" type:@"_http._tcp." name:kRoboDJName port:kRoboDJPort];
//    self.netService.delegate = self;
    
//    self.services = [NSMutableArray array];
}

- (void)viewDidUnload
{
    [self setConnectButton:nil];
    [self setSearchButton:nil];
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
	//    [self.netService publish];
	//    [self.netService resolveWithTimeout:10.0f];
	
	if (self.server == nil) {
		self.server = [[BonjourServer alloc] init];
		NSLog(@"Server: %@", self.server);
	}
	else {
		[self.server run];
		NSLog(@"Server run");
	}
}

- (IBAction)searchButtonPressed:(id)sender {
	//    NSLog(@"currently available services: %@", self.services);
	//    [self.netServiceBrowser searchForServicesOfType:@"_http._tcp" inDomain:@"local"];
	
	
	BonjourClient *client = [[BonjourClient alloc] init];
	[client searchAndConnect];
}

- (IBAction)connectButtonPressed:(id)sender {
    NSNetService* service = [self.services objectAtIndex:0];
    [service resolveWithTimeout:10.0f];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService: %@", service);
    if ( [service.name isEqualToString:kRoboDJName]) {
        service.delegate = self;
        self.connectButton.hidden = YES;
        [self.services removeObject:service];
    }
}	


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"didFindService: %@", service);
    NSLog(@"service.port: %i", service.port);
    if ( [service.name isEqualToString:kRoboDJName] ) {
        service.delegate = self;
        [self.services addObject:service];
        NSLog(@"added: %@", service);
        self.connectButton.hidden = NO;
    }
}	

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"didNotPublish");
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"didResolveAddress");
    
    NSLog(@"addresses: %@", service.addresses);
    
    NSInputStream *istream = nil;
    istream.delegate = self;
    NSOutputStream *ostream = nil;
    ostream.delegate = self;
    
    [service getInputStream:&istream outputStream:&ostream];
    if (istream && ostream)
    {
        // Use the streams as you like for reading and writing.
        NSLog(@"stream!");
        
        [ostream open];
    }
    else
    {
        NSLog(@"Failed to acquire valid streams");
    }
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"didPublish");
    self.searchButton.hidden = YES;
    
    [self.netService startMonitoring];
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSLog(@"didUpdateTXTRecordData");
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"stream: %@, eventCode: %@", aStream, eventCode);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            // do nothing
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSInteger   bytesWritten;
            NSLog(@"bytesWritten: %i", bytesWritten);
            
#if ! defined(NDEBUG)
			//            if (self.debugStallSend) {
			//                return;
			//            }
#endif
            
            // If the buffer has no more data to send, refill it.
            
			//            if (self.bufferOffset == [self.buffer length]) {
			//                self.bufferOffset = 0;
			
			//                switch (self.sendState) {
			//                    case kFileSendOperationStateStart: {
			//                        uint64_t    header;
			//                        
			//                        // Set up the buffer to send the header.
			//                        
			//                        header = OSSwapHostToBigInt64(self.fileLength);
			//                        [self.buffer setLength:0];
			//                        [self.buffer appendBytes:&header length:sizeof(header)];
			//                        
			//                        self.sendState = kFileSendOperationStateHeader;
			//                    } break;
			//                    case kFileSendOperationStateHeader:
			//                        self.sendState = kFileSendOperationStateBody;
			//                        // fall through
			//                    case kFileSendOperationStateBody: {
			//                        if (self.fileOffset < self.fileLength) {
			//                            NSUInteger  bytesToRead;
			//                            NSInteger   bytesRead;
			//                            
			//                            // Set up the buffer to send the next chunk of body data.
			//                            
			//                            if ( (self.fileLength - self.fileOffset) < (off_t) kFileSendOperationBufferSize ) {
			//                                bytesToRead = (NSUInteger) (self.fileLength - self.fileOffset);
			//                            } else {
			//                                bytesToRead = kFileSendOperationBufferSize;
			//                            }
			//                            [self.buffer setLength:bytesToRead];
			//                            bytesRead = [self.fileStream read:[self.buffer mutableBytes] maxLength:bytesToRead];
			//                            if (bytesRead < 0) {
			//                                [self finishWithError:[self.fileStream streamError]];
			//                            } else if (bytesRead == 0) {
			//                                // The file must have shrunk while we were reading it!
			//                                [self finishWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:EPIPE userInfo:nil]];
			//                            } else {
			//                                [self.buffer setLength:bytesRead];
			//                                
			//                                self.crc = crc32(self.crc, [self.buffer bytes], (uInt) [self.buffer length]);
			//                                
			//                                self.fileOffset += bytesRead;
			//                            }
			//                        } else {
			//                            uint32_t    trailer;
			//                            
			//                            // Set up the buffer to send the trailer.
			//                            
			//                            trailer = OSSwapHostToBigInt32( (uint32_t) self.crc );
			//#if ! defined(NDEBUG)
			//                            if (self.debugSendBadChecksum) {
			//                                trailer ^= 1;
			//                            }
			//#endif
			//                            [self.buffer setLength:0];
			//                            [self.buffer appendBytes:&trailer length:sizeof(trailer)];
			//                            
			//                            self.sendState = kFileSendOperationStateTrailer;
			//                        }
			//                    } break;
			//                    case kFileSendOperationStateTrailer: {
			//                        [self finishWithError:nil];
			//                    } break;
			//                }
			//            }
            
            // Try to send the remaining bytes in the buffer.
            
			//            if ( ! [self isFinished] ) {
			//                assert(self.bufferOffset < [self.buffer length]);
			//                bytesWritten = [self.outputStream write:((const uint8_t *) [self.buffer bytes]) + self.bufferOffset maxLength:[self.buffer length] - self.bufferOffset];
			//                if (bytesWritten < 0) {
			//                    [self finishWithError:[self.outputStream streamError]];
			//                } else {
			//                    self.bufferOffset += bytesWritten;
			//                }
			//            }
        } break;
        case NSStreamEventErrorOccurred: {
			//            assert([self.outputStream streamError] != nil);
			//            [self finishWithError:[self.outputStream streamError]];
        } break;
        case NSStreamEventEndEncountered: {
            assert(NO);
        } break;
        default: {
            assert(NO);
        } break;
    }
}


@end
