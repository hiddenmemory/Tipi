//
//  TPMarkdownDataParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPMarkdownDataParser.h"
#import "discountWrapper.h"

@implementation TPMarkdownDataParser

- (NSDictionary*)values {
	NSDictionary *values = [super values];
	NSMutableDictionary *markdownValues = [NSMutableDictionary dictionary];
	
	for( NSString *key in [values allKeys] ) {
		[markdownValues setObject:discountToHTML([values objectForKey:key]) forKey:key];
	}

	return markdownValues;
}

@end
