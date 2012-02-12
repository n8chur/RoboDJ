//
//  RDJSong.m
//  RoboDJ
//
//  Created by Micha Mazaheri on 2/11/12.
//  Copyright (c) 2012 n8chur. All rights reserved.
//

#import "RDJSong.h"

@implementation RDJSong

@synthesize sections = _sections;
@synthesize beats = _beats;
@synthesize sectionIntro = _sectionIntro;
@synthesize sectionOutro = _sectionOutro;
@synthesize sectionBuildUp = _sectionBuildUp;

+ (RDJSong *)parseJSONURL:(NSURL*)JSONFile
{
	RDJSong *song = [[RDJSong alloc] init];
	
	NSData *data = [NSData dataWithContentsOfURL:JSONFile];
	
	NSDictionary *jsonSerialization = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
	
	NSArray *sectionsDicts = [jsonSerialization objectForKey:@"sections"];
	
	NSInteger i = 0;
	for (NSDictionary *sectionDict in sectionsDicts) {
		RDJSectionType type = RDJSectionTypeNormal;
		if (i == 0) {
			type = RDJSectionTypeIntro;
		}
		else if (i == 1) {
			type = RDJSectionTypeBuildUp;
		}
		else if (i == [sectionsDicts count] - 1) {
			type = RDJSectionTypeOutro;
		}
		
		NSTimeInterval startTime = [(NSNumber*)[sectionDict objectForKey:@"start"] floatValue];
		
		NSTimeInterval duration = [(NSNumber*)[sectionDict objectForKey:@"duration"] floatValue];
		
		RDJSection *section = [[RDJSection alloc] initWithType:type startTime:startTime];
		section.duration = duration;

		if (type == RDJSectionTypeIntro) {
			song.sectionIntro = section;
			
			NSLog(@"intro startTime: %f duration: %f", startTime, duration);
		}
		else if (type == RDJSectionTypeBuildUp) {
			song.sectionBuildUp = section;
			
			NSLog(@"buildup startTime: %f duration: %f", startTime, duration);
		}
		else if (type == RDJSectionTypeOutro) {
			song.sectionOutro = section;
			
			NSLog(@"outro startTime: %f duration: %f", startTime, duration);
		}
		
		i++;
	}
	return song;
}	

@end
