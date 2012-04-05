//
//  TPTemplateParser.m
//  Tipi
//
//  Created by Chris Ross on 05/04/2012.
//  Copyright (c) 2012 hiddenMemory Ltd. All rights reserved.
//

#import "TPTemplateParser.h"
#import "TPTemplateNode.h"
#import "NSString+HiddenMemory.h"

@interface TPTemplateParser () {
	TPTemplateNode *root;
	
	NSString *tagStart, *tagEnd;
	NSString *tagBlockOpen, *tagBlockClose;
}
- (id)initWithFileAtPath:(NSString*)path;
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent;
- (void)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent;
@end

@implementation TPTemplateParser
+ (TPTemplateParser*)parserForFile:(NSString*)path {
	return [[[self class] alloc] initWithFileAtPath:path];
}
- (id)initWithFileAtPath:(NSString*)path {
	self = [super init];
	if( self ) {
		root = [TPTemplateNode node];
		
		tagStart = @"{{";
		tagBlockOpen = @"#";
		tagBlockClose = @"/";
		tagEnd = @"}}";
		
		NSMutableString *content = [NSMutableString stringWithContentsOfFile:path 
																	encoding:NSUTF8StringEncoding
																	   error:nil];
		
		[self parseContent:content parent:root];
		
		NSLog(@"Node: %@", [root description]);
	}
	return self;
}
- (NSString*)expansionUsingValues:(NSDictionary*)values {
	return [root expansionUsingValues:values];
}
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent {
	while( [content length] ) {
		NSLog(@"Content: '%@'", content);
		
		NSRange range = [content rangeOfString:tagStart];
		BOOL shouldParseTag = YES;
		
		if( range.location == NSNotFound ) {
			range.location = [content length];
			shouldParseTag = NO;
		}
		
		TPTemplateNode *node = [TPTemplateNode node];
		node.type = TPNodeText;
		node.name = @"";
		node.originalValue = [content substringToIndex:range.location];
		[node.values addObject:node.originalValue];
		[parent.childNodes addObject:node];
		
		[content deleteCharactersInRange:NSMakeRange(0, range.location)];
		
		if( shouldParseTag ) {
			[self parseTag:content parent:parent];
		}
	}
}
- (void)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent {
	if( [content hasPrefix:tagStart] ) {
		NSRange tagContentRange = [content rangeOfString:tagEnd];
		
		if( tagContentRange.location != NSNotFound ) {
			TPTemplateNode *node = [TPTemplateNode node];
			node.originalValue = [content substringToIndex:tagContentRange.location + tagEnd.length];
			
			NSMutableArray *parts = [NSMutableArray arrayWithArray:[[[node.originalValue removePrefix:tagStart suffix:tagEnd] stringByTrimmingWhitespace] componentsSeparatedByString:@" "]];
			
			[content deleteCharactersInRange:NSMakeRange(0, node.originalValue.length)];
			
			[parent.childNodes addObject:node];
			
			if( [[parts objectAtIndex:0] hasPrefix:tagBlockOpen] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockOpen] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagStart suffix:nil]];
				}
				
				node.type = TPNodeDefinition;
				node.name = [parts objectAtIndex:0];
				
				if( [parts count] > 1 ) {
					[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				}
				
				[self parseContent:content parent:node];
			}
			else if( [[parts objectAtIndex:0] hasPrefix:tagBlockClose] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockClose] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagBlockClose suffix:nil]];
				}
			}
			else {
				node.type = TPNodeApplication;
				node.name = [parts objectAtIndex:0];
				if( [parts count] > 1 ) {
					[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				}
			}
		}
		else {
			[NSException raise:@"TagParseError" format:@"Error parsing tag"];
		}
	}
}
@end
