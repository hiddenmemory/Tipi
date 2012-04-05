//
//  TPTextDataParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTextDataParser.h"
#import "NSString+HiddenMemory.h"

@interface TPTextDataParser () {
	NSMutableDictionary *_values;
}
- (id)initWithFile:(NSString*)path;
@end

@implementation TPTextDataParser
+ (TPTextDataParser*)parserForFile:(NSString*)path {
	return [[[self class] alloc] initWithFile:path];
}
- (id)initWithFile:(NSString *)path {
	self = [super init];
	if( self ) {
		NSString *content = [NSString stringWithContentsOfFile:path
													  encoding:NSUTF8StringEncoding
														 error:nil];
		
		NSArray *lines = [content componentsSeparatedByString:@"\n"];
		
		_values = [NSMutableDictionary dictionary];
		
		NSString *currentKey = @"";
		NSMutableString *currentValue = [NSMutableString string];
		
		for( NSString *line in lines ) {
			NSRange prefixRange = [line rangeOfString:@":"];
			
			if( prefixRange.location == NSNotFound ) {
				[currentValue appendFormat:@"\n%@", line];
			}
			else {
				if( [currentKey isEqualToString:@""] == NO ) {
					[_values setObject:currentValue forKey:currentKey];
					currentKey = @"";
					currentValue = [NSMutableString string];
				}
				
				currentKey = [[line substringToIndex:prefixRange.location] lowercaseString];
				[currentValue appendString:[line substringFromIndex:prefixRange.location + 1]];
			}
		}
		
		if( [currentKey isEqualToString:@""] == NO ) {
			[_values setObject:currentValue forKey:[currentKey lowercaseString]];
		}
		
		for( NSString *key in [_values allKeys] ) {
			[_values setObject:[[_values objectForKey:key] stringByTrimmingWhitespace] forKey:key];
		}
	}
	return self;
}
- (NSDictionary*)values {
	return _values;
}
@end
