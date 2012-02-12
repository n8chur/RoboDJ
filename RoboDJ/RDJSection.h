//
//  RDJSection.h
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RDJSectionTypeBuildUp = 0,
    RDJSectionTypeIntro,
    RDJSectionTypeOutro,
	RDJSectionTypeNormal
} RDJSectionType;

@interface RDJSection : NSObject

@property (nonatomic) RDJSectionType type;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval duration;

-(id)initWithType:(RDJSectionType)aType startTime:(NSTimeInterval)aStartTime;

@end
