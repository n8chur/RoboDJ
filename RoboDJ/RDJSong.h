//
//  RDJSong.h
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDJSection.h"

@interface RDJSong : NSObject

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *beats;
@property (nonatomic, strong) RDJSection *sectionIntro;
@property (nonatomic, strong) RDJSection *sectionBuildUp;
@property (nonatomic, strong) RDJSection *sectionOutro;

+ (RDJSong *)parse;

@end
