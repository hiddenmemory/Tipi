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
#import "TPMarkdownDataParser.h"

@interface TPTemplateParser () {
	TPTemplateNode *root;
	
	NSString *tagStart, *tagEnd;
	NSString *tagBlockOpen, *tagBlockClose;
}
- (id)initWithFileAtPath:(NSString*)path;
- (void)parseContent:(NSMutableString*)content parent:(TPTemplateNode*)parent;
- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent;
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
	NSMutableDictionary *globals = [NSMutableDictionary dictionary];
	
	[globals setObject:[^NSString*( TPTemplateNode *node, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) {
		[global setObject:[^NSString*( TPTemplateNode *_, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) {
			NSMutableString *expansion = [NSMutableString string];
			NSMutableDictionary *environment = [NSMutableDictionary dictionary];
			
			[[node.values subarrayWithRange:NSMakeRange(1, [node.values count] - 1)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				[environment setObject:[parameters objectAtIndex:idx] forKey:[obj lowercaseString]];
			}];
			
			for( TPTemplateNode *childNode in _.childNodes ) {
				if( [childNode.name isEqualToString:@"bind"] ) {
					[environment setObject:[childNode expansionUsingValues:[NSDictionary dictionary] global:global]
									forKey:[[childNode.values objectAtIndex:0] lowercaseString]];
				}
			}
			
			NSLog(@"Environment: %@", environment);
			
			for( TPTemplateNode *childNode in node.childNodes ) {
				[expansion appendString:[childNode expansionUsingValues:environment global:global]];
			}
			
			return expansion;
		} copy]
				   forKey:[[node.values objectAtIndex:0] lowercaseString]];
		
		return @"";
	} copy]
				forKey:@"template"];

	[globals setObject:[^NSString*( TPTemplateNode *node, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) {
		[global setObject:[^NSString*( TPTemplateNode *_, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) {
			return [node.values objectAtIndex:1];
		} copy]
				   forKey:[[node.values objectAtIndex:0] lowercaseString]];
		
		NSLog(@"Globals: %@", global);
		
		return @"";
	} copy]
				forKey:@"global"];

	[globals setObject:[^NSString*( TPTemplateNode *node, NSDictionary *values, NSMutableDictionary *global, NSArray *parameters ) {
		NSMutableString *expansion = [NSMutableString string];
		TPMarkdownDataParser *parser = [TPMarkdownDataParser parserForFile:[node.values objectAtIndex:0]];
		NSDictionary *environment = parser.values;
		
		NSLog(@"Environment: %@", environment);
		
		for( TPTemplateNode *childNode in node.childNodes ) {
			[expansion appendString:[childNode expansionUsingValues:environment global:global]];
		}
		
		return expansion;
	} copy]
				forKey:@"include"];
	
	return [root expansionUsingValues:values
							   global:globals];
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
			if( [self parseTag:content parent:parent] ) {
				return;
			}
		}
	}
}
- (BOOL)parseTag:(NSMutableString*)content parent:(TPTemplateNode*)parent {
	if( [content hasPrefix:tagStart] ) {
		NSRange tagContentRange = [content rangeOfString:tagEnd];
		
		if( tagContentRange.location != NSNotFound ) {
			TPTemplateNode *node = [TPTemplateNode node];
			node.originalValue = [content substringToIndex:tagContentRange.location + tagEnd.length];
			
			
			NSMutableArray *parts = [NSMutableArray array];
			NSString *stringToParse = [node.originalValue removePrefix:tagStart suffix:tagEnd];
			
			while( [stringToParse length] ) {
				stringToParse = [stringToParse stringByTrimmingWhitespace];
				
				NSLog(@"String to parse: %@ (%@)", stringToParse, parts);
				
				
				if( [stringToParse hasPrefix:@"\""] ) {
					NSUInteger i = 0; 
					for( i = 1; i < [stringToParse length]; i++ ) {
						unichar c = [stringToParse characterAtIndex:i];
						if( c == '"' && [stringToParse characterAtIndex:i - 1] != '\\' ) {
							[parts addObject:[stringToParse substringWithRange:NSMakeRange(1, i - 1)]];
							stringToParse = [stringToParse substringFromIndex:i + 1];
							break;
						}
					}
				}
				else if( [stringToParse hasPrefix:@"'"] ) {
					NSUInteger i = 0; 
					for( i = 1; i < [stringToParse length]; i++ ) {
						unichar c = [stringToParse characterAtIndex:i];
						if( c == '\'' && [stringToParse characterAtIndex:i - 1] != '\\' ) {
							[parts addObject:[stringToParse substringWithRange:NSMakeRange(1, i - 1)]];
							stringToParse = [stringToParse substringFromIndex:i + 1];
							break;
						}
					}
				}
				else {
					NSRange range = [stringToParse rangeOfString:@" "];
					NSString *nextToken = (range.location == NSNotFound ? stringToParse : [stringToParse substringToIndex:range.location]);
					
					[parts addObject:nextToken];
					
					if( range.location != NSNotFound ) {
						stringToParse = [stringToParse substringFromIndex:[nextToken length]];
					}
					else {
						break;
					}
				}
			}
			
			NSLog(@"Parts: %@", parts);
			
			[content deleteCharactersInRange:NSMakeRange(0, node.originalValue.length)];
			
			if( [[parts objectAtIndex:0] hasPrefix:tagBlockOpen] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockOpen] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagBlockOpen suffix:nil]];
				}
				
				NSLog(@"Parts: %@", parts);
				
				node.type = TPNodeDefinition;
				node.name = [parts objectAtIndex:0];
				
				if( [parts count] > 1 ) {
					[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				}
				
				[parent.childNodes addObject:node];
				[self parseContent:content parent:node];
			}
			else if( [[parts objectAtIndex:0] hasPrefix:tagBlockClose] ) {
				if( [[parts objectAtIndex:0] isEqualToString:tagBlockClose] ) {
					[parts removeObjectAtIndex:0];
				}
				else {
					[parts replaceObjectAtIndex:0 withObject:[[parts objectAtIndex:0] removePrefix:tagBlockClose suffix:nil]];
				}
				
				return YES;
			}
			else {
				node.type = TPNodeApplication;
				node.name = [parts objectAtIndex:0];
				if( [parts count] > 1 ) {
					[node.values addObjectsFromArray:[parts subarrayWithRange:NSMakeRange(1, [parts count] - 1)]];
				}
				
				[parent.childNodes addObject:node];
			}
		}
		else {
			[NSException raise:@"TagParseError" format:@"Error parsing tag"];
		}
	}
	return NO;
}
@end
