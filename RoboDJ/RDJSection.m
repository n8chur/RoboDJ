//
//  RDJSection.m
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "RDJSection.h"

@implementation RDJSection

@synthesize type = _type;
@synthesize startTime = _startTime;
@synthesize duration = _duration;

-(id)initWithType:(RDJSectionType)aType startTime:(NSTimeInterval)aStartTime
{
    self = [super init];
    if (self) {
        self.type = aType;
        self.startTime = aStartTime;
    }
    return self;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"type: %i, startTime: %f, duration: %f", self.type, self.startTime, self.duration];
}

@end

