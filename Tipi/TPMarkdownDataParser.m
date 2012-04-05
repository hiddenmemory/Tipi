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
		NSMutableString *htmlSnippet = [NSMutableString stringWithString:discountToHTML([values objectForKey:key])];
		
		if( [htmlSnippet hasPrefix:@"<p>"] ) {
			[htmlSnippet deleteCharactersInRange:NSMakeRange(0, [@"<p>" length])];
		}
		if( [htmlSnippet hasSuffix:@"</p>"] ) {
			NSUInteger tagLength = [@"</p>" length];
			[htmlSnippet deleteCharactersInRange:NSMakeRange([htmlSnippet length] - tagLength, tagLength)];
		}
		
		[markdownValues setObject:htmlSnippet
						   forKey:key];
	}

	return markdownValues;
}

@end
