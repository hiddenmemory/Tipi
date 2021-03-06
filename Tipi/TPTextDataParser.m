//
//  TPTextDataParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTextDataParser.h"
#import "NSString+Tipi.h"

@interface TPTextDataParser () {
	NSMutableDictionary *_values;
}
- (id)initWithFile:(NSString*)path;
@end

@implementation TPTextDataParser
+ (id)parserForFile:(NSString*)path {
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
				if( ![currentKey isEqualToString:@""] ) {
					_values[currentKey] = currentValue;
					currentKey = @"";
					currentValue = [NSMutableString string];
				}
				
				currentKey = [[line substringToIndex:prefixRange.location] lowercaseString];
				[currentValue appendString:[line substringFromIndex:prefixRange.location + 1]];
			}
		}
		
		if( ![currentKey isEqualToString:@""] ) {
			_values[currentKey.lowercaseString] = currentValue;
		}
		
		for( NSString *key in [_values allKeys] ) {
			_values[key] = [_values[key] tp_stringByTrimmingWhitespace];
		}
	}
	return self;
}
- (NSDictionary*)values {
	return _values;
}
@end
